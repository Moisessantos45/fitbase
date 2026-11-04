import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/infrastructure/mappers/plan_mapper.dart';

class GymPlansNotifier extends AsyncNotifier<List<PlanModel>> {
  GymPlansNotifier(this.gymId);

  final int gymId;

  @override
  Future<List<PlanModel>> build() async {
    return fetchPlans(gymId);
  }

  Future<List<PlanModel>> fetchPlans(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiPublic.get('/gyms/$gymId/plans');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataObj = resMap['data'];

      final List rawList;
      if (dataObj is List) {
        rawList = dataObj;
      } else {
        rawList = const [];
      }

      final plans = <PlanModel>[];
      for (final item in rawList) {
        final itemMap = PlanMapper.toNullableMap(item);
        if (itemMap != null) {
          plans.add(PlanMapper.fromMap(itemMap));
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

final gymPlansProvider = AsyncNotifierProvider.family<GymPlansNotifier, List<PlanModel>, int>(
  GymPlansNotifier.new,
);