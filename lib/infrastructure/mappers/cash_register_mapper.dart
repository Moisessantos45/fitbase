import 'package:fitbase/domain/cash_register_model.dart';

class CashRegisterMapper {
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

  static CashRegisterModel fromMap(Map<String, dynamic> map) {
    final rawCloseCash = map['close_cash'] != null
        ? double.tryParse(map['close_cash'].toString())
        : null;

    final rawIsOpen = map['is_open'];
    final bool isOpen = rawIsOpen is bool
        ? rawIsOpen
        : (rawIsOpen?.toString().toLowerCase() == 'true');

    return CashRegisterModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      managerId: int.tryParse(map['manager_id']?.toString() ?? '') ?? 0,
      openCash: double.tryParse(map['open_cash']?.toString() ?? '') ?? 0.0,
      closeCash: rawCloseCash,
      openTime: map['open_time']?.toString() ?? '',
      closeTime: map['close_time']?.toString(),
      isOpen: isOpen,
    );
  }
}

