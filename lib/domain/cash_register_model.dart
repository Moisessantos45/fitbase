class CashRegisterModel {
  final int id;
  final int gymId;
  final int managerId;
  final double openCash;
  final double? closeCash;
  final String openTime;
  final String? closeTime;
  final bool isOpen;

  const CashRegisterModel({
    this.id = 0,
    this.gymId = 0,
    this.managerId = 0,
    this.openCash = 0.0,
    this.closeCash,
    this.openTime = '',
    this.closeTime,
    this.isOpen = false,
  });

  CashRegisterModel copyWith({
    int? id,
    int? gymId,
    int? managerId,
    double? openCash,
    double? closeCash,
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return CashRegisterModel(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      managerId: managerId ?? this.managerId,
      openCash: openCash ?? this.openCash,
      closeCash: closeCash ?? this.closeCash,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

