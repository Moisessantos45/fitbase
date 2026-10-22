import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/auth_models.dart';
import 'package:fitbase/domain/auth_state.dart';
import 'package:fitbase/infrastructure/mappers/auth_user_mapper.dart';

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _storage = FlutterSecureStorage();
  Timer? _alertTimer;
  Future<void>? _sessionRequest;

  AuthState get _current => state.value ?? const AuthState();

  @override
  Future<AuthState> build() async {
    ApiClientConfig.tokenProvider = () => getToken();
    ApiClientConfig.refreshTokenProvider = () => getRefreshToken();
    ApiClientConfig.clearAuthProvider = () => clearAuthData();
    return const AuthState();
  }

  void setAuthenticated(bool value) {
    state = AsyncData(_current.copyWith(authenticated: value));
  }

  void setAlertMessage(AlertState message) {
    _alertTimer?.cancel();
    state = AsyncData(_current.copyWith(alertMessage: message));
    _alertTimer = Timer(const Duration(seconds: 5), () {
      state = AsyncData(
        _current.copyWith(
          alertMessage: const AlertState(error: false, msg: ''),
        ),
      );
    });
  }

  void clearAlert() {
    _alertTimer?.cancel();
    _alertTimer = Timer(const Duration(seconds: 5), () {
      state = AsyncData(
        _current.copyWith(
          alertMessage: const AlertState(error: false, msg: ''),
        ),
      );
    });
  }

  String getToken() {
    final current = _current;
    if (current.token.isNotEmpty) {
      return current.token;
    }
    if (current.authData?.token.isNotEmpty ?? false) {
      return current.authData!.token;
    }
    return '';
  }

  void setToken(String newToken) {
    final current = _current;
    final updatedAuthData = current.authData != null
        ? AuthUser(
            id: current.authData!.id,
            roleId: current.authData!.roleId,
            email: current.authData!.email,
            twoFactorEnabled: current.authData!.twoFactorEnabled,
            firstSession: current.authData!.firstSession,
            fullProfile: current.authData!.fullProfile,
            emailConfirmed: current.authData!.emailConfirmed,
            active: current.authData!.active,
            token: newToken,
            createdAt: current.authData!.createdAt,
            updatedAt: current.authData!.updatedAt,
          )
        : null;

    state = AsyncData(
      current.copyWith(
        token: newToken,
        authData: updatedAuthData,
        suppressAutoRefresh: false,
      ),
    );
  }

  Map<String, String> getHeaders() {
    return {'Authorization': 'Bearer ${getToken()}'};
  }

  Future<String> getRefreshToken() async {
    final storedRefreshToken = await _storage.read(key: 'refresh_token');
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      state = AsyncData(_current.copyWith(authenticated: false));
      throw Exception('No se pudo obtener un nuevo token');
    }

    try {
      final res = await apiPublic.post(
        '/auth/refresh-token-mobile',
        options: Options(
          headers: {'Authorization': 'Bearer $storedRefreshToken'},
        ),
      );

      final resMap = AuthUserMapper.toSafeMap(res.data);
      final extractedData = AuthUserMapper.toNullableMap(resMap['data']);

      final newAccessToken =
          (extractedData?['access_token'] ?? extractedData?['token'])
              ?.toString() ??
          '';
      final newRefreshToken = extractedData?['refresh_token']?.toString() ?? '';

      if (newAccessToken.isEmpty) {
        state = AsyncData(_current.copyWith(authenticated: false));
        throw Exception(
          'Error al refrescar el token. Por favor, intenta de nuevo.',
        );
      }

      if (newRefreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      setToken(newAccessToken);
      return newAccessToken;
    } catch (e) {
      await clearAuthData();
      state = AsyncData(_current.copyWith(authenticated: false));
      rethrow;
    }
  }

  Future<void> getSession() async {
    if (_sessionRequest != null) return _sessionRequest!;

    _sessionRequest = () async {
      if (_current.suppressAutoRefresh && getToken().isEmpty) {
        return;
      }

      if (getToken().isEmpty) {
        try {
          await getRefreshToken();
        } catch (_) {
          await clearAuthData();
          return;
        }
      }

      try {
        state = AsyncData(_current.copyWith(loading: true));
        final res = await apiAuth.get('/auth/session');
        final resMap = AuthUserMapper.toSafeMap(res.data);
        final extractedData = AuthUserMapper.toNullableMap(resMap['data']);

        if (extractedData != null) {
          final user = AuthUserMapper.fromMap(extractedData);
          state = AsyncData(
            _current.copyWith(
              authData: user,
              authenticated: true,
              loading: false,
            ),
          );
        } else {
          state = AsyncData(
            _current.copyWith(authenticated: false, loading: false),
          );
        }
      } catch (e) {
        state = AsyncData(
          _current.copyWith(authenticated: false, loading: false),
        );
      }
    }();

    try {
      await _sessionRequest;
    } finally {
      _sessionRequest = null;
    }
  }

  Future<String> register(String email, String password, bool isOwner) async {
    state = AsyncData(_current.copyWith(loading: true));
    final endpoint = isOwner ? '/auth/register-owner' : '/auth/register';

    try {
      final res = await apiPublic.post(
        endpoint,
        data: {'email': email, 'password': password},
      );

      final resMap = AuthUserMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Registro exitoso...';
      setAlertMessage(AlertState(error: false, msg: message));
      state = AsyncData(_current.copyWith(loading: false));
      return message;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error en el registro';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    } catch (e) {
      setAlertMessage(AlertState(error: true, msg: e.toString()));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> forwardEmailVerification(String email) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiPublic.post(
        '/auth/forward-email-verification',
        data: {'email': email},
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Correo de verificación reenviado...';
      setAlertMessage(AlertState(error: false, msg: msg));
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al reenviar correo';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
    } finally {
      state = AsyncData(_current.copyWith(loading: false));
      clearAlert();
    }
  }

  Future<void> verifyAccount(String token) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiPublic.get(
        '/auth/confirm-account',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ?? 'Cuenta verificada exitosamente...';
      setAlertMessage(AlertState(error: false, msg: msg));
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al verificar cuenta';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
    } finally {
      state = AsyncData(_current.copyWith(loading: false));
      clearAlert();
    }
  }

  Future<TotpData> generateTwoFactor() async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.patch('/auth/enable-two-factor');
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final data = AuthUserMapper.toNullableMap(resMap['data']);
      final uri = data?['uri']?.toString() ?? '';
      final secret = data?['secret']?.toString() ?? '';

      if (uri.isEmpty || secret.isEmpty) {
        throw Exception(
          'Error al generar datos de autenticación de dos factores.',
        );
      }

      final totp = TotpData(uri: uri, secret: secret);
      state = AsyncData(_current.copyWith(totpData: totp, loading: false));
      return totp;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al habilitar 2FA';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<String> verifyTwoFactor(String code) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.post(
        '/auth/verify-two-factor',
        data: {'code': code},
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Autenticación de dos factores verificada exitosamente.';
      setAlertMessage(AlertState(error: false, msg: msg));
      state = AsyncData(_current.copyWith(loading: false));
      return msg;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al verificar 2FA';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    state = AsyncData(
      _current.copyWith(
        accountNotVerified: false,
        requiresTwoFactor: false,
        loading: true,
        email: email,
        password: password,
      ),
    );

    try {
      final res = await apiPublic.post(
        '/auth/login-mobile',
        data: {'email': email, 'password': password},
      );

      final statusCode = res.statusCode ?? 200;
      final bodyMap = AuthUserMapper.toSafeMap(res.data);
      final code = bodyMap['code']?.toString();

      if (statusCode == 202 && code == 'PENDING_2FA') {
        await clearAuthData();
        state = AsyncData(
          _current.copyWith(
            requiresTwoFactor: true,
            loading: false,
            email: email,
            password: password,
          ),
        );
        setAlertMessage(
          const AlertState(error: false, msg: 'Verificación 2FA pendiente.'),
        );
        return {'status': 'PENDING_2FA', 'token': ''};
      }

      final data = AuthUserMapper.toNullableMap(bodyMap['data']);
      final accessToken =
          (data?['access_token'] ?? data?['token'])?.toString() ?? '';
      final refreshToken = data?['refresh_token']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw Exception(
          'Error al iniciar sesión. Por favor, intenta de nuevo.',
        );
      }

      if (refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      AuthUser? user;
      final userRaw = data?['user'];
      if (userRaw != null) {
        user = AuthUserMapper.fromMap(AuthUserMapper.toSafeMap(userRaw));
      } else if (data?['id'] != null) {
        user = AuthUserMapper.fromMap(data!);
      }

      if (user == null) {
        try {
          final resSession = await apiAuth.get(
            '/auth/session',
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
          final resSessionMap = AuthUserMapper.toSafeMap(resSession.data);
          final ext = AuthUserMapper.toNullableMap(resSessionMap['data']);
          if (ext != null) {
            user = AuthUserMapper.fromMap(ext);
          }
        } catch (_) {}
      }

      if (user != null && user.token.isEmpty) {
        user = user.copyWith(token: accessToken);
      }

      setToken(accessToken);
      state = AsyncData(
        _current.copyWith(
          authenticated: true,
          suppressAutoRefresh: false,
          requiresTwoFactor: false,
          accountNotVerified: false,
          authData: user,
          loading: false,
        ),
      );

      setAlertMessage(
        const AlertState(error: false, msg: 'Inicio de sesión exitoso.'),
      );
      return {'status': 'AUTHENTICATED', 'token': accessToken};
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errCode = errMap['code']?.toString();
      final isEmailNotVerified =
          statusCode == 403 && errCode == 'EMAIL_NOT_VERIFIED';
      final msg = isEmailNotVerified
          ? 'EMAIL_NOT_VERIFIED'
          : (errMap['message']?.toString() ?? 'Error al iniciar sesión');

      state = AsyncData(
        _current.copyWith(
          accountNotVerified: isEmailNotVerified,
          requiresTwoFactor: false,
          loading: false,
        ),
      );
      setAlertMessage(AlertState(error: true, msg: msg));
      rethrow;
    } catch (e) {
      state = AsyncData(_current.copyWith(loading: false));
      setAlertMessage(AlertState(error: true, msg: e.toString()));
      rethrow;
    }
  }

  Future<String> verifyLoginTwoFactor(String code) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiPublic.post(
        '/auth/2fa/verify',
        data: {'code': code},
      );

      final bodyMap = AuthUserMapper.toSafeMap(res.data);
      final data = AuthUserMapper.toNullableMap(bodyMap['data']);
      final accessToken =
          (data?['access_token'] ?? data?['token'] ?? bodyMap['token'])
              ?.toString() ??
          '';
      final refreshToken = data?['refresh_token']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw Exception(
          'Error al verificar el código 2FA. Por favor, intenta de nuevo.',
        );
      }

      if (refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      setToken(accessToken);
      state = AsyncData(
        _current.copyWith(
          authenticated: true,
          suppressAutoRefresh: false,
          requiresTwoFactor: false,
          loading: false,
        ),
      );

      setAlertMessage(
        const AlertState(
          error: false,
          msg: 'Código 2FA verificado correctamente.',
        ),
      );
      return accessToken;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al verificar 2FA';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> disableTwoFactor() async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.patch('/auth/disable-two-factor');
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Autenticación de dos factores deshabilitada.';
      setAlertMessage(AlertState(error: false, msg: msg));
      state = AsyncData(
        _current.copyWith(totpData: const TotpData(), loading: false),
      );
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al deshabilitar 2FA';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiAuth.post('/auth/logout-mobile');
    } catch (_) {}

    state = AsyncData(_current.copyWith(suppressAutoRefresh: true));
    await clearAuthData();
    clearAlert();
  }

  Future<String> forgotPassword(String email) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiPublic.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Se ha enviado un correo con un enlace para restablecer tu contraseña.';
      setAlertMessage(AlertState(error: false, msg: msg));
      state = AsyncData(_current.copyWith(loading: false));
      return msg;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ??
          'Error al solicitar restablecimiento';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<String> resetPassword(String token, String newPassword) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiPublic.patch(
        '/auth/reset-password',
        data: {'new_password': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Contraseña restablecida exitosamente. Ahora puedes iniciar sesión.';
      setAlertMessage(AlertState(error: false, msg: msg));
      state = AsyncData(_current.copyWith(loading: false));
      return msg;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al restablecer contraseña';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<String> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.patch(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      final resMap = AuthUserMapper.toSafeMap(res.data);
      final msg =
          resMap['message']?.toString() ??
          'Contraseña actualizada exitosamente.';
      setAlertMessage(AlertState(error: false, msg: msg));
      state = AsyncData(_current.copyWith(loading: false));
      return msg;
    } on DioException catch (e) {
      final errorMap = AuthUserMapper.toSafeMap(e.response?.data);
      final errorMsg =
          errorMap['message']?.toString() ?? 'Error al actualizar contraseña';
      setAlertMessage(AlertState(error: true, msg: errorMsg));
      state = AsyncData(_current.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: 'refresh_token');
    state = const AsyncData(AuthState());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
