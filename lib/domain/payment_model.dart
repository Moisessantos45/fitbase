class DayPassTicketModel {
  final int id;
  final String slug;
  final int gymId;
  final String gymName;
  final int planId;
  final String planName;
  final double planPrice;
  final bool isPaid;
  final String fullName;
  final String phone;
  final String email;
  final String visitDate;
  final bool isUsed;
  final String createdAt;

  const DayPassTicketModel({
    this.id = 0,
    this.slug = '',
    this.gymId = 0,
    this.gymName = '',
    this.planId = 0,
    this.planName = '',
    this.planPrice = 0.0,
    this.isPaid = false,
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.visitDate = '',
    this.isUsed = false,
    this.createdAt = '',
  });
}

class StripeSessionModel {
  final String sessionId;
  final String checkoutUrl;
  final int paymentId;
  final double amount;

  const StripeSessionModel({
    this.sessionId = '',
    this.checkoutUrl = '',
    this.paymentId = 0,
    this.amount = 0.0,
  });
}