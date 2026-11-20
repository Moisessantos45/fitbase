import 'package:fitbase/domain/checkin_model.dart';

class CheckInMapper {
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

  static CheckInResult fromMap(Map<String, dynamic> map, {String defaultMessage = ''}) {
    final rawAllowed = map['allowed'];
    final bool allowed = rawAllowed is bool
        ? rawAllowed
        : (rawAllowed?.toString().toLowerCase() == 'true');

    return CheckInResult(
      allowed: allowed,
      message: map['message']?.toString() ?? defaultMessage,
      userName: map['user_name']?.toString() ?? '',
      accessType: map['access_type']?.toString() ?? '',
      planName: map['plan_name']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      needPayment: false,
    );
  }
}

