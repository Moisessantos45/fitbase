class SubscriptionHistoryModel {
  final int id;
  final String gymName;
  final String planName;
  final double planPrice;
  final String statusName;
  final String startDate;
  final String endDate;
  final bool autoRenew;
  final bool isActive;

  const SubscriptionHistoryModel({
    this.id = 0,
    this.gymName = '',
    this.planName = '',
    this.planPrice = 0.0,
    this.statusName = '',
    this.startDate = '',
    this.endDate = '',
    this.autoRenew = false,
    this.isActive = false,
  });
}

class CheckInHistoryModel {
  final int id;
  final String gymName;
  final String accessTypeName;
  final String checkedInAt;

  const CheckInHistoryModel({
    this.id = 0,
    this.gymName = '',
    this.accessTypeName = '',
    this.checkedInAt = '',
  });
}

class PaymentHistoryModel {
  final int id;
  final String gymName;
  final String paymentMethodName;
  final String paymentStatusName;
  final double amount;
  final String paymentDate;
  final String concept;

  const PaymentHistoryModel({
    this.id = 0,
    this.gymName = '',
    this.paymentMethodName = '',
    this.paymentStatusName = '',
    this.amount = 0.0,
    this.paymentDate = '',
    this.concept = '',
  });
}