import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/daypass_model.dart';
import 'package:fitbase/infrastructure/mappers/daypass_mapper.dart';

class DayPassNotifier extends AsyncNotifier<List<DayPassModel>> {
  @override
  Future<List<DayPassModel>> build() async {
    return const [];
  }

  Future<List<DayPassModel>> searchDaypasses(
    int gymId, {
    String? search,
    String? date,
  }) async {
    state = const AsyncLoading();
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (date != null && date.trim().isNotEmpty) {
        queryParams['date'] = date.trim();
      }

      final res = await apiAuth.get(
        '/gyms/$gymId/daypasses',
        queryParameters: queryParams,
      );
      final resMap = DayPassMapper.toSafeMap(res.data);
      final rawList = resMap['data'];

      final List<DayPassModel> items = [];
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = DayPassMapper.toNullableMap(item);
          if (itemMap != null) {
            items.add(DayPassMapper.fromMap(itemMap));
          }
        }
      }

      state = AsyncData(items);
      return items;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<DayPassModel?> getTicketBySlug(String slug) async {
    try {
      final res = await apiPublic.get('/daypass/$slug/ticket');
      final resMap = DayPassMapper.toSafeMap(res.data);
      final dataMap = DayPassMapper.toNullableMap(resMap['data']);
      if (dataMap == null) return null;
      return DayPassMapper.fromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<DayPassModel> createPublicGuestDayPass(
      RegisterGuestDayPassPayload payload) async {
    try {
      final res = await apiPublic.post(
        '/daypass/guest',
        data: DayPassMapper.registerGuestPayloadToMap(payload),
      );
      final resMap = DayPassMapper.toSafeMap(res.data);
      final dataMap = DayPassMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al registrar pase de invitado');
      }

      return DayPassMapper.fromMap(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<DayPassModel> registerGuest(
      RegisterGuestDayPassPayload payload) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.post(
        '/daypass/register-guest',
        data: DayPassMapper.registerGuestPayloadToMap(payload),
      );
      final resMap = DayPassMapper.toSafeMap(res.data);
      final dataMap = DayPassMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al registrar visitante');
      }

      final created = DayPassMapper.fromMap(dataMap);
      await searchDaypasses(payload.gymId);
      return created;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> payDayPassAtDesk({
    required int gymId,
    required int dayPassId,
    required double amount,
    required int paymentMethodId,
  }) async {
    try {
      final res = await apiAuth.post(
        '/payments/cash',
        data: {
          'gym_id': gymId,
          'payment_method_id': paymentMethodId,
          'amount': amount,
          'day_pass_id': dayPassId,
        },
      );
      final resMap = DayPassMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Pago registrado con éxito';
      await searchDaypasses(gymId);
      return message;
    } catch (e) {
      rethrow;
    }
  }
}

final dayPassProvider =
    AsyncNotifierProvider<DayPassNotifier, List<DayPassModel>>(
  DayPassNotifier.new,
);
