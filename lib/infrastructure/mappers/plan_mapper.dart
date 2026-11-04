import 'package:fitbase/domain/plan_model.dart';

class PlanMapper {
  static Map<String, dynamic>? toNullableMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static Map<String, dynamic> toSafeMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return {};
  }

  static PlanItemModel itemFromMap(Map<String, dynamic> map) {
    return PlanItemModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  static PlanModel fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final itemsList = <PlanItemModel>[];
    
    if (rawItems is List) {
      for (final item in rawItems) {
        final itemMap = toNullableMap(item);
        if (itemMap != null) {
          itemsList.add(itemFromMap(itemMap));
        }
      }
    }

    return PlanModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(map['discount']?.toString() ?? '') ?? 0.0,
      finalPrice: double.tryParse(map['final_price']?.toString() ?? '') ?? 0.0,
      duration: int.tryParse(map['duration']?.toString() ?? '') ?? 0,
      planType: map['plan_type']?.toString() ?? '',
      maxVisits: int.tryParse(map['max_visits']?.toString() ?? ''),
      active: map['active'] == true || map['active']?.toString().toLowerCase() == 'true',
      isCurrent: map['is_current'] == true || map['is_current']?.toString().toLowerCase() == 'true',
      items: itemsList,
    );
  }

  static Map<String, dynamic> toMap(PlanModel plan) {
    return {
      'id': plan.id,
      'gym_id': plan.gymId,
      'name': plan.name,
      'description': plan.description,
      'price': plan.price,
      'discount': plan.discount,
      'duration': plan.duration,
      'plan_type': plan.planType,
      'max_visits': plan.maxVisits,
      'active': plan.active,
    };
  }
}