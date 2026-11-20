class CheckInResult {
  final bool allowed;
  final String message;
  final String userName;
  final String accessType;
  final String planName;
  final String timestamp;
  final bool needPayment;
  final double? pendingAmount;
  final int? dayPassId;

  const CheckInResult({
    this.allowed = false,
    this.message = '',
    this.userName = '',
    this.accessType = '',
    this.planName = '',
    this.timestamp = '',
    this.needPayment = false,
    this.pendingAmount,
    this.dayPassId,
  });

  CheckInResult copyWith({
    bool? allowed,
    String? message,
    String? userName,
    String? accessType,
    String? planName,
    String? timestamp,
    bool? needPayment,
    double? pendingAmount,
    int? dayPassId,
  }) {
    return CheckInResult(
      allowed: allowed ?? this.allowed,
      message: message ?? this.message,
      userName: userName ?? this.userName,
      accessType: accessType ?? this.accessType,
      planName: planName ?? this.planName,
      timestamp: timestamp ?? this.timestamp,
      needPayment: needPayment ?? this.needPayment,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      dayPassId: dayPassId ?? this.dayPassId,
    );
  }
}

