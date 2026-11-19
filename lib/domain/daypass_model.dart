class DayPassModel {
  final int id;
  final String slug;
  final int gymId;
  final String gymName;
  final int planId;
  final String planName;
  final double planPrice;
  final String fullName;
  final String email;
  final String phone;
  final String visitDate;
  final bool isPaid;
  final bool isUsed;

  const DayPassModel({
    this.id = 0,
    this.slug = '',
    this.gymId = 0,
    this.gymName = '',
    this.planId = 0,
    this.planName = '',
    this.planPrice = 0.0,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.visitDate = '',
    this.isPaid = false,
    this.isUsed = false,
  });

  DayPassModel copyWith({
    int? id,
    String? slug,
    int? gymId,
    String? gymName,
    int? planId,
    String? planName,
    double? planPrice,
    String? fullName,
    String? email,
    String? phone,
    String? visitDate,
    bool? isPaid,
    bool? isUsed,
  }) {
    return DayPassModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      planPrice: planPrice ?? this.planPrice,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      visitDate: visitDate ?? this.visitDate,
      isPaid: isPaid ?? this.isPaid,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

class RegisterGuestDayPassPayload {
  final int gymId;
  final int planId;
  final String fullName;
  final String phone;
  final String email;
  final String? visitDate;

  const RegisterGuestDayPassPayload({
    required this.gymId,
    required this.planId,
    required this.fullName,
    required this.phone,
    required this.email,
    this.visitDate,
  });
}

