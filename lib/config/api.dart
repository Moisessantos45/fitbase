import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:fitbase/config/env.dart';

class ApiClientConfig {
  static String Function()? tokenProvider;
  static Future<String> Function()? refreshTokenProvider;
  static void Function()? clearAuthProvider;
}

final Map<String, String> _pendingRequests = {};
final Set<String> _retriedRequests = {};
bool _isRefreshing = false;
List<_FailedRequestQueueItem> _failedQueue = [];

class _FailedRequestQueueItem {
  final Completer<String> completer;
  _FailedRequestQueueItem(this.completer);
}

void _processQueue(dynamic error, [String? token]) {
  for (final item in _failedQueue) {
    if (error != null) {
      if (!item.completer.isCompleted) {
        item.completer.completeError(error);
      }
    } else if (token != null) {
      if (!item.completer.isCompleted) {
        item.completer.complete(token);
      }
    }
  }
  _failedQueue = [];
}

String _generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

String _requestFingerprint(RequestOptions options) {
  final url = options.path;
  final method = options.method.toUpperCase();
  final dynamic data = options.data;
  final body = data == null
      ? ''
      : (data is String
          ? data
          : (data is FormData ? data.fields.toString() : jsonEncode(data)));
  return '$method:$url:$body';
}

RequestOptions _attachIdempotencyKey(RequestOptions options) {
  final method = options.method.toUpperCase();
  if (method != 'POST' && method != 'PUT' && method != 'PATCH') {
    return options;
  }
  if (options.headers.containsKey('X-Idempotency-Key')) {
    return options;
  }
  final fp = _requestFingerprint(options);
  final existing = _pendingRequests[fp];
  if (existing != null) {
    options.headers['X-Idempotency-Key'] = existing;
  } else {
    final newKey = _generateUuidV4();
    _pendingRequests[fp] = newKey;
    options.headers['X-Idempotency-Key'] = newKey;
  }
  return options;
}

void _cleanupIdempotencyKey(RequestOptions options) {
  _pendingRequests.remove(_requestFingerprint(options));
}

bool _shouldSkipAuthHeader(String? url) {
  if (url == null || url.isEmpty) return false;
  const paths = [
    '/auth/login',
    '/auth/login-mobile',
    '/auth/2fa/verify',
    '/auth/refresh-token',
    '/auth/refresh-token-mobile',
  ];
  return paths.any((path) => url.contains(path));
}

bool _shouldSkipRefreshRetry(String? url) {
  if (url == null || url.isEmpty) return false;
  const paths = [
    '/auth/refresh-token',
    '/auth/refresh-token-mobile',
    '/auth/login',
    '/auth/login-mobile',
    '/auth/logout',
    '/auth/logout-mobile',
    '/auth/2fa/verify',
  ];
  return paths.any((path) => url.contains(path));
}

Dio _createPublicDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseV1,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.baseUrl = Env.apiBaseV1;
        _attachIdempotencyKey(options);
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _cleanupIdempotencyKey(response.requestOptions);
        return handler.next(response);
      },
      onError: (error, handler) {
        _cleanupIdempotencyKey(error.requestOptions);
        return handler.next(error);
      },
    ),
  );

  return dio;
}

Dio _createAuthDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseV1,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.baseUrl = Env.apiBaseV1;
        final token = ApiClientConfig.tokenProvider?.call();
        if (token != null &&
            token.isNotEmpty &&
            !options.headers.containsKey('Authorization') &&
            !_shouldSkipAuthHeader(options.path)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (options.data is FormData) {
          options.headers.remove('Content-Type');
        }
        _attachIdempotencyKey(options);
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _cleanupIdempotencyKey(response.requestOptions);
        _retriedRequests.remove(_requestFingerprint(response.requestOptions));
        return handler.next(response);
      },
      onError: (error, handler) async {
        final originalRequest = error.requestOptions;
        _cleanupIdempotencyKey(originalRequest);
        final fp = _requestFingerprint(originalRequest);

        if (error.response?.statusCode == 401 &&
            !_retriedRequests.contains(fp) &&
            !_shouldSkipRefreshRetry(originalRequest.path)) {
          if (_isRefreshing) {
            final completer = Completer<String>();
            _failedQueue.add(_FailedRequestQueueItem(completer));
            try {
              final token = await completer.future;
              originalRequest.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(originalRequest);
              return handler.resolve(response);
            } catch (_) {
              return handler.reject(error);
            }
          }

          _retriedRequests.add(fp);
          _isRefreshing = true;

          try {
            final refreshProvider = ApiClientConfig.refreshTokenProvider;
            if (refreshProvider == null) {
              throw Exception('No refresh token provider configured');
            }
            final newToken = await refreshProvider();
            originalRequest.headers['Authorization'] = 'Bearer $newToken';
            _processQueue(null, newToken);
            final response = await dio.fetch(originalRequest);
            return handler.resolve(response);
          } catch (refreshError) {
            _processQueue(refreshError, null);
            ApiClientConfig.clearAuthProvider?.call();
            return handler.reject(error);
          } finally {
            _isRefreshing = false;
          }
        }

        _retriedRequests.remove(fp);
        return handler.next(error);
      },
    ),
  );

  return dio;
}

final Dio apiPublic = _createPublicDio();
final Dio apiAuth = _createAuthDio();
