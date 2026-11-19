import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/infrastructure/mappers/subscription_mapper.dart';

class UserSubscriptionsNotifier extends AsyncNotifier<List<SubscriptionItem>> {
  @override
  Future<List<SubscriptionItem>> build() async {
    return const [];
  }

  Future<List<SubscriptionItem>> getMySubscriptions({
    int page = 1,
    int pageSize = 20,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get(
        '/subscriptions/my-subscriptions',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final resMap = SubscriptionMapper.toSafeMap(res.data);
      dynamic rawList = resMap['data'];
      if (rawList is Map) {
        rawList =
            rawList['data'] ?? rawList['items'] ?? rawList['subscriptions'];
      }
      if (rawList is! List && res.data is List) {
        rawList = res.data;
      }

      final Map<String, SubscriptionItem> uniqueMap = {};
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = SubscriptionMapper.toNullableMap(item);
          if (itemMap != null) {
            final sub = SubscriptionMapper.fromMap(itemMap);
            final String key;
            if (sub.slug.isNotEmpty) {
              key = sub.slug;
            } else if (sub.id > 0) {
              key = 'id_${sub.id}';
            } else {
              key = '${sub.gymId}_${sub.planId}_${sub.startDate}_${sub.endDate}';
            }
            uniqueMap[key] = sub;
          }
        }
      }

      final items = uniqueMap.values.toList();
      state = AsyncData(items);
      return items;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<SubscriptionTicket> subscribe(
      PurchaseSubscriptionPayload payload) async {
    try {
      final res = await apiAuth.post(
        '/subscriptions/subscribe',
        data: SubscriptionMapper.purchasePayloadToMap(payload),
      );
      final resMap = SubscriptionMapper.toSafeMap(res.data);
      final dataMap = SubscriptionMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al procesar la suscripción');
      }

      final ticket = SubscriptionMapper.ticketFromMap(dataMap);
      await getMySubscriptions();
      return ticket;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelSubscription(int id) async {
    try {
      await apiAuth.put('/subscriptions/$id/cancel');
      await getMySubscriptions();
    } catch (e) {
      rethrow;
    }
  }
}

final userSubscriptionsProvider =
    AsyncNotifierProvider<UserSubscriptionsNotifier, List<SubscriptionItem>>(
  UserSubscriptionsNotifier.new,
);

class GymSubscriptionsNotifier extends AsyncNotifier<List<SubscriptionItem>> {
  @override
  Future<List<SubscriptionItem>> build() async {
    return const [];
  }

  Future<List<SubscriptionItem>> getGymSubscriptions(
    int gymId, {
    int? statusId,
    int page = 1,
    int pageSize = 20,
  }) async {
    state = const AsyncLoading();
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'status_id': ?statusId,
      };

      final res = await apiAuth.get(
        '/gyms/$gymId/subscriptions',
        queryParameters: queryParams,
      );
      final resMap = SubscriptionMapper.toSafeMap(res.data);
      dynamic rawList = resMap['data'];
      if (rawList is Map) {
        rawList =
            rawList['data'] ?? rawList['items'] ?? rawList['subscriptions'];
      }
      if (rawList is! List && res.data is List) {
        rawList = res.data;
      }

      final Map<String, SubscriptionItem> uniqueMap = {};
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = SubscriptionMapper.toNullableMap(item);
          if (itemMap != null) {
            final sub = SubscriptionMapper.fromMap(itemMap);
            final String key;
            if (sub.slug.isNotEmpty) {
              key = sub.slug;
            } else if (sub.id > 0) {
              key = 'id_${sub.id}';
            } else {
              key = '${sub.gymId}_${sub.planId}_${sub.startDate}_${sub.endDate}';
            }
            uniqueMap[key] = sub;
          }
        }
      }

      final items = uniqueMap.values.toList();
      state = AsyncData(items);
      return items;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> cancelGymSubscription({
    required int gymId,
    required int subscriptionId,
    int? currentStatusId,
  }) async {
    try {
      await apiAuth.put('/subscriptions/$subscriptionId/cancel');
      await getGymSubscriptions(gymId, statusId: currentStatusId);
    } catch (e) {
      rethrow;
    }
  }
}

final gymSubscriptionsProvider =
    AsyncNotifierProvider<GymSubscriptionsNotifier, List<SubscriptionItem>>(
  GymSubscriptionsNotifier.new,
);

class Client360Notifier extends AsyncNotifier<Client360History?> {
  @override
  Future<Client360History?> build() async {
    return null;
  }

  Future<Client360History?> getClientHistory(int gymId, int userId) async {
    state = const AsyncLoading();
    try {
      final res =
          await apiAuth.get('/gyms/$gymId/analytics/clients/$userId');
      final resMap = SubscriptionMapper.toSafeMap(res.data);
      final dataMap = SubscriptionMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        state = const AsyncData(null);
        return null;
      }

      final history = SubscriptionMapper.client360FromMap(dataMap);
      state = AsyncData(history);
      return history;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final client360Provider =
    AsyncNotifierProvider<Client360Notifier, Client360History?>(
  Client360Notifier.new,
);
