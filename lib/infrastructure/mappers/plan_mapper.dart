import 'package:fitbase/domain/plan_model.dart';

class PlanMapper {
  static Map<String, dynamic> toSafeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? toNullableMap(dynamic value) {
    if (value == null) return null;
    final map = toSafeMap(value);
    return map.isEmpty ? null : map;
  }

  static PlanItemModel itemFromMap(Map<String, dynamic> map) {
    return PlanItemModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> itemToMap(PlanItemModel item) {
    return {
      'name': item.name,
      'description': item.description,
    };
  }

  static PlanModel fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final List<PlanItemModel> items = [];
    if (rawItems is List) {
      for (final raw in rawItems) {
        final itemMap = toNullableMap(raw);
        if (itemMap != null) {
          items.add(itemFromMap(itemMap));
        }
      }
    }

    final rawPrice = double.tryParse(map['price']?.toString() ?? '') ?? 0.0;
    final rawDiscount = double.tryParse(map['discount']?.toString() ?? '') ?? 0.0;
    final rawFinalPrice = double.tryParse(map['final_price']?.toString() ?? '') ??
        (rawPrice * (1 - (rawDiscount / 100)));

    final rawMaxVisits = map['max_visits'] != null
        ? int.tryParse(map['max_visits'].toString())
        : null;

    final rawActive = map['active'];
    final bool active = rawActive is bool
        ? rawActive
        : (rawActive?.toString().toLowerCase() == 'true');

    final rawIsCurrent = map['is_current'];
    final bool isCurrent = rawIsCurrent is bool
        ? rawIsCurrent
        : (rawIsCurrent?.toString().toLowerCase() == 'true');

    return PlanModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: rawPrice,
      discount: rawDiscount,
      finalPrice: rawFinalPrice,
      duration: int.tryParse(map['duration']?.toString() ?? '') ?? 0,
      planType: map['plan_type']?.toString() ?? '',
      maxVisits: rawMaxVisits,
      active: active,
      isCurrent: isCurrent,
      items: items,
    );
  }

  static ActiveSubscriptionInfo activeSubFromMap(Map<String, dynamic> map) {
    final rawAuto = map['auto_renew'];
    final bool autoRenew = rawAuto is bool
        ? rawAuto
        : (rawAuto?.toString().toLowerCase() == 'true');
    return ActiveSubscriptionInfo(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      slug: map['slug']?.toString() ?? '',
      planId: int.tryParse(map['plan_id']?.toString() ?? '') ?? 0,
      planName: map['plan_name']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      statusName: map['status_name']?.toString() ?? '',
      autoRenew: autoRenew,
    );
  }

  static GymEnrollmentData enrollmentFromMap(Map<String, dynamic> map) {
    final rawHas = map['has_active_subscription'];
    final bool hasActive = rawHas is bool
        ? rawHas
        : (rawHas?.toString().toLowerCase() == 'true');

    final subMap = toNullableMap(map['active_subscription']);
    final activeSub = subMap != null ? activeSubFromMap(subMap) : null;

    final rawPlans = map['plans'];
    final List<PlanModel> plans = [];
    if (rawPlans is List) {
      for (final p in rawPlans) {
        final pMap = toNullableMap(p);
        if (pMap != null) {
          plans.add(fromMap(pMap));
        }
      }
    }

    return GymEnrollmentData(
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      hasActiveSubscription: hasActive,
      activeSubscription: activeSub,
      plans: plans,
    );
  }

  static Map<String, dynamic> createPayloadToMap(CreatePlanPayload payload) {
    return {
      'gym_id': payload.gymId,
      'name': payload.name,
      'description': payload.description,
      'price': payload.price,
      'discount': payload.discount,
      'duration': payload.duration,
      'plan_type': payload.planType,
      if (payload.maxVisits != null) 'max_visits': payload.maxVisits,
      'items': payload.items.map(itemToMap).toList(),
    };
  }
}

