import 'package:fitbase/domain/user_model.dart';

class UserMapper {
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

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      authId: int.tryParse(map['auth_id']?.toString() ?? '') ?? 0,
      firstName: (map['first_name'] ?? map['firstName'])?.toString() ?? '',
      lastName: (map['last_name'] ?? map['lastName'])?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'])?.toString() ?? '',
    );
  }

  static Map<String, dynamic> toMap(UserProfile user) {
    return {
      'first_name': user.firstName,
      'last_name': user.lastName,
      'phone': user.phone,
    };
  }
}
