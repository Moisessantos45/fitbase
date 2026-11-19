class PaymentItem {
  final int id;
  final int gymId;
  final String gymName;
  final int paymentMethodId;
  final String paymentMethodName;
  final int paymentStatusId;
  final String paymentStatusName;
  final double amount;
  final int? subscriptionId;
  final int? dayPassId;
  final int? cashRegisterId;
  final String paymentDate;
  final String createdAt;

  const PaymentItem({
    this.id = 0,
    this.gymId = 0,
    this.gymName = '',
    this.paymentMethodId = 0,
    this.paymentMethodName = '',
    this.paymentStatusId = 0,
    this.paymentStatusName = '',
    this.amount = 0.0,
    this.subscriptionId,
    this.dayPassId,
    this.cashRegisterId,
    this.paymentDate = '',
    this.createdAt = '',
  });

  bool get isPaid =>
      paymentStatusId == 2 || paymentStatusName.toLowerCase() == 'pagado';
}

class GymRevenueSummary {
  final int gymId;
  final String gymName;
  final double totalRevenue;
  final int totalTransactions;

  const GymRevenueSummary({
    this.gymId = 0,
    this.gymName = '',
    this.totalRevenue = 0.0,
    this.totalTransactions = 0,
  });
}

class StripeCheckoutSession {
  final String sessionId;
  final String checkoutUrl;
  final int paymentId;
  final double amount;

  const StripeCheckoutSession({
    this.sessionId = '',
    this.checkoutUrl = '',
    this.paymentId = 0,
    this.amount = 0.0,
  });
}

class StripeSessionStatus {
  final String sessionId;
  final String paymentStatus;
  final String status;
  final int paymentId;
  final double amountTotal;
  final String currency;

  const StripeSessionStatus({
    this.sessionId = '',
    this.paymentStatus = '',
    this.status = '',
    this.paymentId = 0,
    this.amountTotal = 0.0,
    this.currency = '',
  });

  bool get isCompleted => status == 'complete' && paymentStatus == 'paid';
}

