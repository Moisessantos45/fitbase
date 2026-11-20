import 'package:fitbase/domain/daypass_model.dart';

class DayPassMapper {
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

  static DayPassModel fromMap(Map<String, dynamic> map) {
    final rawPaid = map['is_paid'];
    final bool isPaid = rawPaid is bool
        ? rawPaid
        : (rawPaid?.toString().toLowerCase() == 'true');

    final rawUsed = map['is_used'];
    final bool isUsed = rawUsed is bool
        ? rawUsed
        : (rawUsed?.toString().toLowerCase() == 'true');

    return DayPassModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      slug: map['slug']?.toString() ?? '',
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      planId: int.tryParse(map['plan_id']?.toString() ?? '') ?? 0,
      planName: map['plan_name']?.toString() ?? '',
      planPrice: double.tryParse(map['plan_price']?.toString() ?? '') ?? 0.0,
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      visitDate: map['visit_date']?.toString() ?? '',
      isPaid: isPaid,
      isUsed: isUsed,
    );
  }

  static Map<String, dynamic> registerGuestPayloadToMap(
      RegisterGuestDayPassPayload payload) {
    return {
      'gym_id': payload.gymId,
      'plan_id': payload.planId,
      'full_name': payload.fullName,
      'phone': payload.phone,
      'email': payload.email,
      if (payload.visitDate != null && payload.visitDate!.isNotEmpty)
        'visit_date': payload.visitDate,
    };
  }
}

