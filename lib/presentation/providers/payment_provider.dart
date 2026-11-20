import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/infrastructure/mappers/payment_mapper.dart';

class UserPaymentsNotifier extends AsyncNotifier<List<PaymentItem>> {
  @override
  Future<List<PaymentItem>> build() async {
    return const [];
  }

  Future<List<PaymentItem>> getMyPayments({
    int page = 1,
    int pageSize = 20,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get(
        '/payments/my-payments',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final resMap = PaymentMapper.toSafeMap(res.data);
      dynamic rawList =
          resMap['data'] ?? resMap['payments'] ?? resMap['items'];
      if (rawList is Map) {
        rawList = rawList['data'] ??
            rawList['items'] ??
            rawList['payments'] ??
            rawList['rows'] ??
            rawList['records'];
      }
      if (rawList is! List && res.data is List) {
        rawList = res.data;
      }

      final Map<int, PaymentItem> uniqueMap = {};
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = PaymentMapper.toNullableMap(item);
          if (itemMap != null) {
            final p = PaymentMapper.fromMap(itemMap);
            if (p.id > 0) {
              uniqueMap[p.id] = p;
            } else {
              uniqueMap[uniqueMap.length] = p;
            }
          }
        }
      }

      final items = uniqueMap.values.toList();
      state = AsyncData(items);
      return items;
    } on DioException catch (e, stack) {
      if (e.response?.statusCode == 404) {
        state = const AsyncData([]);
        return const [];
      }
      state = AsyncError(e, stack);
      return const [];
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final userPaymentsProvider =
    AsyncNotifierProvider<UserPaymentsNotifier, List<PaymentItem>>(
  UserPaymentsNotifier.new,
);

class GymPaymentsNotifier extends AsyncNotifier<List<PaymentItem>> {
  @override
  Future<List<PaymentItem>> build() async {
    return const [];
  }

  Future<List<PaymentItem>> getGymPayments(
    int gymId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get(
        '/gyms/$gymId/payments',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final resMap = PaymentMapper.toSafeMap(res.data);
      dynamic rawList =
          resMap['data'] ?? resMap['payments'] ?? resMap['items'];
      if (rawList is Map) {
        rawList = rawList['data'] ??
            rawList['items'] ??
            rawList['payments'] ??
            rawList['rows'] ??
            rawList['records'];
      }
      if (rawList is! List && res.data is List) {
        rawList = res.data;
      }

      final Map<int, PaymentItem> uniqueMap = {};
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = PaymentMapper.toNullableMap(item);
          if (itemMap != null) {
            final p = PaymentMapper.fromMap(itemMap);
            if (p.id > 0) {
              uniqueMap[p.id] = p;
            } else {
              uniqueMap[uniqueMap.length] = p;
            }
          }
        }
      }

      final items = uniqueMap.values.toList();
      state = AsyncData(items);
      return items;
    } on DioException catch (e, stack) {
      if (e.response?.statusCode == 404) {
        state = const AsyncData([]);
        return const [];
      }
      state = AsyncError(e, stack);
      return const [];
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> registerCashPayment({
    required int gymId,
    required int paymentMethodId,
    required double amount,
    int? subscriptionId,
    int? dayPassId,
  }) async {
    try {
      final res = await apiAuth.post(
        '/payments/cash',
        data: {
          'gym_id': gymId,
          'payment_method_id': paymentMethodId,
          'amount': amount,
          'subscription_id': ?subscriptionId,
          'day_pass_id': ?dayPassId,
        },
      );
      final resMap = PaymentMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Pago registrado exitosamente';
      await getGymPayments(gymId);
      return message;
    } catch (e) {
      rethrow;
    }
  }
}

final gymPaymentsProvider =
    AsyncNotifierProvider<GymPaymentsNotifier, List<PaymentItem>>(
  GymPaymentsNotifier.new,
);

class GymRevenueNotifier extends AsyncNotifier<GymRevenueSummary?> {
  @override
  Future<GymRevenueSummary?> build() async {
    return null;
  }

  Future<GymRevenueSummary?> getGymRevenue(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/gyms/$gymId/payments/revenue');
      final resMap = PaymentMapper.toSafeMap(res.data);
      final dataMap =
          PaymentMapper.toNullableMap(resMap['data']) ?? resMap;

      final summary = PaymentMapper.revenueSummaryFromMap(dataMap);
      state = AsyncData(summary);
      return summary;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return null;
    }
  }
}

final gymRevenueProvider =
    AsyncNotifierProvider<GymRevenueNotifier, GymRevenueSummary?>(
  GymRevenueNotifier.new,
);

class StripeCheckoutNotifier {
  static Future<StripeCheckoutSession> createSession({
    required int gymId,
    required int planId,
    required String type,
    bool autoRenew = false,
  }) async {
    try {
      final res = await apiAuth.post(
        '/payments/stripe/checkout-session',
        data: {
          'gym_id': gymId,
          'plan_id': planId,
          'type': type,
          'auto_renew': autoRenew,
        },
      );
      final resMap = PaymentMapper.toSafeMap(res.data);
      final dataMap = PaymentMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al generar sesión de pago con Stripe');
      }

      return PaymentMapper.stripeSessionFromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  static Future<StripeCheckoutSession> createGuestCheckout({
    required int gymId,
    required int planId,
    required String fullName,
    required String phone,
    required String email,
    required String visitDate,
  }) async {
    try {
      final res = await apiPublic.post(
        '/payments/stripe/guest-checkout',
        data: {
          'gym_id': gymId,
          'plan_id': planId,
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'visit_date': visitDate,
        },
      );
      final resMap = PaymentMapper.toSafeMap(res.data);
      final dataMap = PaymentMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al generar sesión de pago con Stripe');
      }

      return PaymentMapper.stripeSessionFromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  static Future<StripeSessionStatus> checkPublicStatus(String sessionId) async {
    try {
      final res = await apiPublic.get('/payments/stripe/session/$sessionId');
      final resMap = PaymentMapper.toSafeMap(res.data);
      final dataMap = PaymentMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al verificar sesión de Stripe');
      }

      return PaymentMapper.stripeStatusFromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  static Future<StripeSessionStatus> checkStatus(String sessionId) async {
    try {
      final res = await apiAuth.get('/payments/stripe/session/$sessionId');
      final resMap = PaymentMapper.toSafeMap(res.data);
      final dataMap = PaymentMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al verificar sesión de Stripe');
      }

      return PaymentMapper.stripeStatusFromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }
}
