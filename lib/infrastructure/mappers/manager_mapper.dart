import 'package:fitbase/domain/manager_model.dart';

class ManagerMapper {
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

  static ManagerItem fromItemMap(Map<String, dynamic> map) {
    return ManagerItem(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      authId: int.tryParse(map['auth_id']?.toString() ?? '') ?? 0,
      firstName: (map['first_name'] ?? map['firstName'])?.toString() ?? '',
      lastName: (map['last_name'] ?? map['lastName'])?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'])?.toString() ?? '',
      gymName: (map['gym_name'] ?? map['gymName'])?.toString() ?? '',
    );
  }

  static ManagerDetail fromDetailMap(Map<String, dynamic> map) {
    return ManagerDetail(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      authId: int.tryParse(map['auth_id']?.toString() ?? '') ?? 0,
      firstName: (map['first_name'] ?? map['firstName'])?.toString() ?? '',
      lastName: (map['last_name'] ?? map['lastName'])?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'])?.toString() ?? '',
    );
  }

  static PaginationManager fromPaginationMap(Map<String, dynamic> map) {
    return PaginationManager(
      page: int.tryParse(map['page']?.toString() ?? '') ?? 1,
      pageSize: int.tryParse(map['page_size']?.toString() ?? map['pageSize']?.toString() ?? '') ?? 10,
      search: map['search']?.toString() ?? '',
      total: int.tryParse(map['total']?.toString() ?? '') ?? 0,
      totalPages: int.tryParse(map['total_pages']?.toString() ?? map['totalPages']?.toString() ?? '') ?? 1,
    );
  }

  static Map<String, dynamic> formToMap(ManagerForm form) {
    return {
      'first_name': form.firstName,
      'last_name': form.lastName,
      'phone': form.phone,
      'email': form.email,
      'password': form.password,
    };
  }
}
