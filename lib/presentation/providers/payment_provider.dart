import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/infrastructure/mappers/plan_mapper.dart';

class PaymentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<DayPassTicketModel> purchaseGuestDayPass({
    required int gymId,
    required int planId,
    required String fullName,
    required String phone,
    required String email,
    required String visitDate,
    required bool payWithStripe,
  }) async {
    state = const AsyncLoading();
    try {
      final endpoint = payWithStripe ? '/payments/stripe/guest-checkout' : '/daypass/guest';
      
      final payload = {
        'gym_id': gymId,
        'plan_id': planId,
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'visit_date': visitDate,
      };

      final res = await apiPublic.post(endpoint, data: payload);
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataMap = PlanMapper.toNullableMap(resMap['data']);

      if (dataMap == null) throw Exception('Error al crear el pase');

      final ticket = DayPassTicketModel(
        id: int.tryParse(dataMap['id']?.toString() ?? '') ?? 0,
        slug: dataMap['slug']?.toString() ?? '',
        gymId: gymId,
        planId: planId,
        planPrice: double.tryParse(dataMap['plan_price']?.toString() ?? '') ?? 0.0,
        isPaid: dataMap['is_paid'] == true,
        fullName: fullName,
        email: email,
        visitDate: visitDate,
      );
      
      state = const AsyncData(null);
      return ticket;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final paymentProvider = AsyncNotifierProvider<PaymentNotifier, void>(
  PaymentNotifier.new,
);