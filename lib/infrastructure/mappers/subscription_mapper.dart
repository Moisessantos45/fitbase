import 'package:fitbase/domain/subscription_model.dart';

class SubscriptionMapper {
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

  static SubscriptionItem fromMap(Map<String, dynamic> map) {
    final rawAutoRenew = map['auto_renew'];
    final bool autoRenew = rawAutoRenew is bool
        ? rawAutoRenew
        : (rawAutoRenew?.toString().toLowerCase() == 'true');

    final rawId = int.tryParse(map['id']?.toString() ?? '') ??
        int.tryParse(map['subscription_id']?.toString() ?? '') ??
        0;
    final rawStatusId =
        int.tryParse(map['status_id']?.toString() ?? '') ?? 0;
    String statusName = map['status_name']?.toString() ?? '';
    if (statusName.isEmpty) {
      statusName = rawStatusId == 1 ? 'Activo' : 'Inactivo';
    }

    return SubscriptionItem(
      id: rawId,
      slug: map['slug']?.toString() ?? '',
      userId: int.tryParse(map['user_id']?.toString() ?? '') ?? 0,
      userFullName: map['user_full_name']?.toString() ??
          map['full_name']?.toString() ??
          '',
      userEmail: map['user_email']?.toString() ?? '',
      userPhone: map['user_phone']?.toString() ?? '',
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      planId: int.tryParse(map['plan_id']?.toString() ?? '') ?? 0,
      planName: map['plan_name']?.toString() ?? '',
      planPrice: double.tryParse(map['plan_price']?.toString() ?? '') ?? 0.0,
      statusId: rawStatusId,
      statusName: statusName,
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      paymentMethodId:
          int.tryParse(map['payment_method_id']?.toString() ?? '') ?? 0,
      paymentMethodName: map['payment_method_name']?.toString() ?? '',
      autoRenew: autoRenew,
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  static SubscriptionTicket ticketFromMap(Map<String, dynamic> map) {
    return SubscriptionTicket(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      slug: map['slug']?.toString() ?? '',
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      planId: int.tryParse(map['plan_id']?.toString() ?? '') ?? 0,
      planName: map['plan_name']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      statusId: int.tryParse(map['status_id']?.toString() ?? '') ?? 0,
      statusName: map['status_name']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> purchasePayloadToMap(
      PurchaseSubscriptionPayload payload) {
    return {
      'plan_id': payload.planId,
      'payment_method_id': payload.paymentMethodId,
      if (payload.startDate != null && payload.startDate!.isNotEmpty)
        'start_date': payload.startDate,
      'auto_renew': payload.autoRenew,
    };
  }

  static Client360History client360FromMap(Map<String, dynamic> map) {
    final rawSubs = map['subscriptions'];
    final List<Client360Subscription> subs = [];
    if (rawSubs is List) {
      for (final s in rawSubs) {
        final sMap = toNullableMap(s);
        if (sMap != null) {
          subs.add(
            Client360Subscription(
              id: int.tryParse(sMap['id']?.toString() ?? '') ?? 0,
              planName: sMap['plan_name']?.toString() ?? '',
              status: sMap['status']?.toString() ?? '',
              startDate: sMap['start_date']?.toString() ?? '',
              endDate: sMap['end_date']?.toString() ?? '',
            ),
          );
        }
      }
    }

    final rawPayments = map['payments'];
    final List<Client360Payment> payments = [];
    if (rawPayments is List) {
      for (final p in rawPayments) {
        final pMap = toNullableMap(p);
        if (pMap != null) {
          payments.add(
            Client360Payment(
              id: int.tryParse(pMap['id']?.toString() ?? '') ?? 0,
              amount:
                  double.tryParse(pMap['amount']?.toString() ?? '') ?? 0.0,
              method: pMap['method']?.toString() ?? '',
              status: pMap['status']?.toString() ?? '',
              date: pMap['date']?.toString() ?? '',
            ),
          );
        }
      }
    }

    final rawCheckins = map['recent_check_ins'];
    final List<Client360CheckIn> checkins = [];
    if (rawCheckins is List) {
      for (final c in rawCheckins) {
        final cMap = toNullableMap(c);
        if (cMap != null) {
          checkins.add(
            Client360CheckIn(
              id: int.tryParse(cMap['id']?.toString() ?? '') ?? 0,
              accessType: cMap['access_type']?.toString() ?? '',
              date: cMap['date']?.toString() ?? '',
            ),
          );
        }
      }
    }

    return Client360History(
      userId: int.tryParse(map['user_id']?.toString() ?? '') ?? 0,
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      totalSpent:
          double.tryParse(map['total_spent']?.toString() ?? '') ?? 0.0,
      totalCheckIns:
          int.tryParse(map['total_check_ins']?.toString() ?? '') ?? 0,
      subscriptions: subs,
      payments: payments,
      recentCheckIns: checkins,
    );
  }
}

