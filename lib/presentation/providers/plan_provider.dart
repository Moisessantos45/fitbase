import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/infrastructure/mappers/plan_mapper.dart';

class PublicPlansNotifier extends AsyncNotifier<List<PlanModel>> {
  @override
  Future<List<PlanModel>> build() async {
    return const [];
  }

  Future<List<PlanModel>> getPlansByGym(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiPublic.get('/gyms/$gymId/plans');
      final resMap = PlanMapper.toSafeMap(res.data);
      final rawList = resMap['data'];

      final List<PlanModel> plans = [];
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = PlanMapper.toNullableMap(item);
          if (itemMap != null) {
            plans.add(PlanMapper.fromMap(itemMap));
          }
        }
      }

      state = AsyncData(plans);
      return plans;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final publicPlansProvider =
    AsyncNotifierProvider<PublicPlansNotifier, List<PlanModel>>(
  PublicPlansNotifier.new,
);

class AdminPlansNotifier extends AsyncNotifier<List<PlanModel>> {
  @override
  Future<List<PlanModel>> build() async {
    return const [];
  }

  Future<List<PlanModel>> getAllPlans(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/gyms/$gymId/all-plans');
      final resMap = PlanMapper.toSafeMap(res.data);
      final rawList = resMap['data'];

      final List<PlanModel> plans = [];
      if (rawList is List) {
        for (final item in rawList) {
          final itemMap = PlanMapper.toNullableMap(item);
          if (itemMap != null) {
            plans.add(PlanMapper.fromMap(itemMap));
          }
        }
      }

      state = AsyncData(plans);
      return plans;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<PlanModel> createPlan(CreatePlanPayload payload) async {
    try {
      final res = await apiAuth.post(
        '/plans',
        data: PlanMapper.createPayloadToMap(payload),
      );
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataMap = PlanMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Respuesta inválida al crear el plan');
      }

      final created = PlanMapper.fromMap(dataMap);
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, created]);
      return created;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> togglePlanActive({
    required int gymId,
    required int planId,
    required bool active,
  }) async {
    try {
      await apiAuth.put(
        '/plans/$planId',
        data: {'active': active},
      );
      await getAllPlans(gymId);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> addPlanItem({
    required int gymId,
    required int planId,
    required String name,
    required String description,
  }) async {
    try {
      await apiAuth.post(
        '/plans/$planId/items',
        data: {
          'name': name,
          'description': description,
        },
      );
      await getAllPlans(gymId);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> deletePlanItem({
    required int gymId,
    required int planId,
    required int itemId,
  }) async {
    try {
      await apiAuth.delete('/plans/$planId/items/$itemId');
      await getAllPlans(gymId);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final adminPlansProvider =
    AsyncNotifierProvider<AdminPlansNotifier, List<PlanModel>>(
  AdminPlansNotifier.new,
);

class GymEnrollmentNotifier extends AsyncNotifier<GymEnrollmentData?> {
  @override
  Future<GymEnrollmentData?> build() async {
    return null;
  }

  Future<GymEnrollmentData?> getEnrollmentPlans(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/gyms/$gymId/plans/enrollment');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataMap = PlanMapper.toNullableMap(resMap['data']) ?? resMap;
      final enrollment = PlanMapper.enrollmentFromMap(dataMap);
      state = AsyncData(enrollment);
      return enrollment;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final gymEnrollmentProvider =
    AsyncNotifierProvider<GymEnrollmentNotifier, GymEnrollmentData?>(
  GymEnrollmentNotifier.new,
);
