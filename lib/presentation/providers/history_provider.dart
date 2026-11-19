import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/history_model.dart';
import 'package:fitbase/infrastructure/mappers/plan_mapper.dart';

class HistoryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<List<SubscriptionHistoryModel>> getMySubscriptions() async {
    try {
      final res = await apiAuth.get('/subscriptions/my-subscriptions');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataObj = resMap['data'];
      
      final List rawList;
      if (dataObj is Map && dataObj['data'] is List) {
        rawList = dataObj['data'] as List;
      } else if (dataObj is List) {
        rawList = dataObj;
      } else {
        rawList = const [];
      }

      return rawList.whereType<Map>().map((item) {
        final map = PlanMapper.toSafeMap(item);
        return SubscriptionHistoryModel(
          id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
          gymName: map['gym_name']?.toString() ?? '',
          planName: map['plan_name']?.toString() ?? '',
          planPrice: double.tryParse(map['plan_price']?.toString() ?? '') ?? 0.0,
          statusName: map['status_name']?.toString() ?? '',
          startDate: map['start_date']?.toString() ?? '',
          endDate: map['end_date']?.toString() ?? '',
          autoRenew: map['auto_renew'] == true,
          isActive: map['status_id'] == 1,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CheckInHistoryModel>> getMyHistory() async {
    try {
      final res = await apiAuth.get('/checkin/my-history');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataObj = resMap['data'];

      final List rawList;
      if (dataObj is Map && dataObj['data'] is List) {
        rawList = dataObj['data'] as List;
      } else if (dataObj is List) {
        rawList = dataObj;
      } else {
        rawList = const [];
      }

      return rawList.whereType<Map>().map((item) {
        final map = PlanMapper.toSafeMap(item);
        return CheckInHistoryModel(
          id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
          gymName: map['gym_name']?.toString() ?? '',
          accessTypeName: map['access_type_name']?.toString() ?? '',
          checkedInAt: map['checked_in_at']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PaymentHistoryModel>> getMyPayments() async {
    try {
      final res = await apiAuth.get('/payments/my-payments');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataObj = resMap['data'];

      final List rawList;
      if (dataObj is Map && dataObj['data'] is List) {
        rawList = dataObj['data'] as List;
      } else if (dataObj is List) {
        rawList = dataObj;
      } else {
        rawList = const [];
      }

      return rawList.whereType<Map>().map((item) {
        final map = PlanMapper.toSafeMap(item);
        final amount = double.tryParse(map['amount']?.toString() ?? '') ?? 0.0;
        final subId = map['subscription_id'];
        final dayPassId = map['day_pass_id'];
        
        String concept = 'Pago de Servicio';
        if (subId != null) {
          concept = 'Pago de Membresía';
        } else if (dayPassId != null) {
          concept = 'Pase de Visita';
        }

        return PaymentHistoryModel(
          id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
          gymName: map['gym_name']?.toString() ?? '',
          paymentMethodName: map['payment_method_name']?.toString() ?? '',
          paymentStatusName: map['payment_status_name']?.toString() ?? '',
          amount: amount,
          paymentDate: map['payment_date']?.toString() ?? '',
          concept: concept,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, void>(
  HistoryNotifier.new,
);