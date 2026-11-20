class SubscriptionItem {
  final int id;
  final String slug;
  final int userId;
  final String userFullName;
  final String userEmail;
  final String userPhone;
  final int gymId;
  final String gymName;
  final int planId;
  final String planName;
  final double planPrice;
  final int statusId;
  final String statusName;
  final String startDate;
  final String endDate;
  final int paymentMethodId;
  final String paymentMethodName;
  final bool autoRenew;
  final String createdAt;

  const SubscriptionItem({
    this.id = 0,
    this.slug = '',
    this.userId = 0,
    this.userFullName = '',
    this.userEmail = '',
    this.userPhone = '',
    this.gymId = 0,
    this.gymName = '',
    this.planId = 0,
    this.planName = '',
    this.planPrice = 0.0,
    this.statusId = 0,
    this.statusName = '',
    this.startDate = '',
    this.endDate = '',
    this.paymentMethodId = 0,
    this.paymentMethodName = '',
    this.autoRenew = false,
    this.createdAt = '',
  });

  bool get isActive => statusId == 1 || statusName.toLowerCase() == 'activo';
}

class SubscriptionTicket {
  final int id;
  final String slug;
  final int gymId;
  final String gymName;
  final int planId;
  final String planName;
  final String fullName;
  final int statusId;
  final String statusName;
  final String startDate;
  final String endDate;
  final String createdAt;

  const SubscriptionTicket({
    this.id = 0,
    this.slug = '',
    this.gymId = 0,
    this.gymName = '',
    this.planId = 0,
    this.planName = '',
    this.fullName = '',
    this.statusId = 0,
    this.statusName = '',
    this.startDate = '',
    this.endDate = '',
    this.createdAt = '',
  });
}

class PurchaseSubscriptionPayload {
  final int planId;
  final int paymentMethodId;
  final String? startDate;
  final bool autoRenew;

  const PurchaseSubscriptionPayload({
    required this.planId,
    required this.paymentMethodId,
    this.startDate,
    this.autoRenew = false,
  });
}

class Client360Subscription {
  final int id;
  final String planName;
  final String status;
  final String startDate;
  final String endDate;

  const Client360Subscription({
    this.id = 0,
    this.planName = '',
    this.status = '',
    this.startDate = '',
    this.endDate = '',
  });
}

class Client360Payment {
  final int id;
  final double amount;
  final String method;
  final String status;
  final String date;

  const Client360Payment({
    this.id = 0,
    this.amount = 0.0,
    this.method = '',
    this.status = '',
    this.date = '',
  });
}

class Client360CheckIn {
  final int id;
  final String accessType;
  final String date;

  const Client360CheckIn({
    this.id = 0,
    this.accessType = '',
    this.date = '',
  });
}

class Client360History {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final double totalSpent;
  final int totalCheckIns;
  final List<Client360Subscription> subscriptions;
  final List<Client360Payment> payments;
  final List<Client360CheckIn> recentCheckIns;

  const Client360History({
    this.userId = 0,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.totalSpent = 0.0,
    this.totalCheckIns = 0,
    this.subscriptions = const [],
    this.payments = const [],
    this.recentCheckIns = const [],
  });
}

