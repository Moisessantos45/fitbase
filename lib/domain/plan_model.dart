class PlanItemModel {
  final int id;
  final String name;
  final String description;

  const PlanItemModel({
    this.id = 0,
    this.name = '',
    this.description = '',
  });

  PlanItemModel copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return PlanItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

class PlanModel {
  final int id;
  final int gymId;
  final String gymName;
  final String name;
  final String description;
  final double price;
  final double discount;
  final double finalPrice;
  final int duration;
  final String planType;
  final int? maxVisits;
  final bool active;
  final bool isCurrent;
  final List<PlanItemModel> items;

  const PlanModel({
    this.id = 0,
    this.gymId = 0,
    this.gymName = '',
    this.name = '',
    this.description = '',
    this.price = 0.0,
    this.discount = 0.0,
    this.finalPrice = 0.0,
    this.duration = 0,
    this.planType = '',
    this.maxVisits,
    this.active = true,
    this.isCurrent = false,
    this.items = const [],
  });

  PlanModel copyWith({
    int? id,
    int? gymId,
    String? gymName,
    String? name,
    String? description,
    double? price,
    double? discount,
    double? finalPrice,
    int? duration,
    String? planType,
    int? maxVisits,
    bool? active,
    bool? isCurrent,
    List<PlanItemModel>? items,
  }) {
    return PlanModel(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      finalPrice: finalPrice ?? this.finalPrice,
      duration: duration ?? this.duration,
      planType: planType ?? this.planType,
      maxVisits: maxVisits ?? this.maxVisits,
      active: active ?? this.active,
      isCurrent: isCurrent ?? this.isCurrent,
      items: items ?? this.items,
    );
  }
}

class ActiveSubscriptionInfo {
  final int id;
  final String slug;
  final int planId;
  final String planName;
  final String startDate;
  final String endDate;
  final String statusName;
  final bool autoRenew;

  const ActiveSubscriptionInfo({
    this.id = 0,
    this.slug = '',
    this.planId = 0,
    this.planName = '',
    this.startDate = '',
    this.endDate = '',
    this.statusName = '',
    this.autoRenew = false,
  });
}

class GymEnrollmentData {
  final int gymId;
  final String gymName;
  final bool hasActiveSubscription;
  final ActiveSubscriptionInfo? activeSubscription;
  final List<PlanModel> plans;

  const GymEnrollmentData({
    this.gymId = 0,
    this.gymName = '',
    this.hasActiveSubscription = false,
    this.activeSubscription,
    this.plans = const [],
  });
}

class CreatePlanPayload {
  final int gymId;
  final String name;
  final String description;
  final double price;
  final double discount;
  final int duration;
  final String planType;
  final int? maxVisits;
  final List<PlanItemModel> items;

  const CreatePlanPayload({
    required this.gymId,
    required this.name,
    required this.description,
    required this.price,
    this.discount = 0.0,
    required this.duration,
    required this.planType,
    this.maxVisits,
    this.items = const [],
  });
}

