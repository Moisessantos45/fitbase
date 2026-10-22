import 'package:fitbase/domain/auth_models.dart';

class AuthUserMapper {
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

  static AuthUser fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      roleId: int.tryParse(map['role_id']?.toString() ?? '') ?? 0,
      email: map['email']?.toString() ?? '',
      twoFactorEnabled:
          map['two_factor_enabled'] == true ||
          map['two_factor_enabled']?.toString().toLowerCase() == 'true',
      firstSession:
          map['first_session'] == true ||
          map['first_session']?.toString().toLowerCase() == 'true',
      fullProfile:
          map['full_profile'] == true ||
          map['full_profile']?.toString().toLowerCase() == 'true',
      emailConfirmed:
          map['email_confirmed'] == true ||
          map['email_confirmed']?.toString().toLowerCase() == 'true',
      active:
          map['active'] == true ||
          map['active']?.toString().toLowerCase() == 'true',
      token: map['token']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> toMap(AuthUser user) {
    return {
      'id': user.id,
      'role_id': user.roleId,
      'email': user.email,
      'two_factor_enabled': user.twoFactorEnabled,
      'first_session': user.firstSession,
      'full_profile': user.fullProfile,
      'email_confirmed': user.emailConfirmed,
      'active': user.active,
      'token': user.token,
      'created_at': user.createdAt,
      'updated_at': user.updatedAt,
    };
  }
}
