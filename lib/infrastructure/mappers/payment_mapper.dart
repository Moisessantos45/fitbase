import 'package:fitbase/domain/payment_model.dart';

class PaymentMapper {
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

  static PaymentItem fromMap(Map<String, dynamic> map) {
    final rawSubId = map['subscription_id'] != null
        ? int.tryParse(map['subscription_id'].toString())
        : null;
    final rawDayPassId = map['day_pass_id'] != null
        ? int.tryParse(map['day_pass_id'].toString())
        : null;
    final rawCashRegisterId = map['cash_register_id'] != null
        ? int.tryParse(map['cash_register_id'].toString())
        : null;

    final methodId =
        int.tryParse(map['payment_method_id']?.toString() ?? '') ?? 0;
    final statusId =
        int.tryParse(map['payment_status_id']?.toString() ?? '') ?? 0;

    String methodName = map['payment_method_name']?.toString() ?? '';
    if (methodName.isEmpty) {
      if (methodId == 1) {
        methodName = 'Efectivo';
      } else if (methodId == 2) {
        methodName = 'Tarjeta de Crédito';
      } else if (methodId == 3) {
        methodName = 'Tarjeta de Débito';
      } else {
        methodName = methodId > 0 ? 'Método #$methodId' : 'Efectivo';
      }
    }

    String statusName = map['payment_status_name']?.toString() ?? '';
    if (statusName.isEmpty) {
      if (statusId == 2) {
        statusName = 'Pagado';
      } else if (statusId == 1) {
        statusName = 'Pendiente';
      } else if (statusId == 3) {
        statusName = 'Fallido';
      } else {
        statusName = 'Pagado';
      }
    }

    final pDate = map['payment_date']?.toString() ??
        map['created_at']?.toString() ??
        '';

    return PaymentItem(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      paymentMethodId: methodId,
      paymentMethodName: methodName,
      paymentStatusId: statusId,
      paymentStatusName: statusName,
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      subscriptionId: rawSubId,
      dayPassId: rawDayPassId,
      cashRegisterId: rawCashRegisterId,
      paymentDate: pDate,
      createdAt: map['created_at']?.toString() ?? pDate,
    );
  }

  static GymRevenueSummary revenueSummaryFromMap(Map<String, dynamic> map) {
    return GymRevenueSummary(
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      totalRevenue:
          double.tryParse(map['total_revenue']?.toString() ?? '') ??
          double.tryParse(map['total']?.toString() ?? '') ??
          double.tryParse(map['revenue']?.toString() ?? '') ??
          0.0,
      totalTransactions:
          int.tryParse(map['total_transactions']?.toString() ?? '') ??
          int.tryParse(map['transactions']?.toString() ?? '') ??
          int.tryParse(map['count']?.toString() ?? '') ??
          0,
    );
  }

  static StripeCheckoutSession stripeSessionFromMap(Map<String, dynamic> map) {
    return StripeCheckoutSession(
      sessionId: map['session_id']?.toString() ?? '',
      checkoutUrl: map['checkout_url']?.toString() ?? '',
      paymentId: int.tryParse(map['payment_id']?.toString() ?? '') ?? 0,
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
    );
  }

  static StripeSessionStatus stripeStatusFromMap(Map<String, dynamic> map) {
    return StripeSessionStatus(
      sessionId: map['session_id']?.toString() ?? '',
      paymentStatus: map['payment_status']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      paymentId: int.tryParse(map['payment_id']?.toString() ?? '') ?? 0,
      amountTotal:
          double.tryParse(map['amount_total']?.toString() ?? '') ?? 0.0,
      currency: map['currency']?.toString() ?? '',
    );
  }
}

