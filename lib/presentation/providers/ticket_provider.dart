import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/infrastructure/mappers/plan_mapper.dart';

class TicketNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<DayPassTicketModel?> getDayPassTicket(String slug) async {
    state = const AsyncLoading();
    try {
      final res = await apiPublic.get('/daypass/$slug/ticket');
      final resMap = PlanMapper.toSafeMap(res.data);
      final dataMap = PlanMapper.toNullableMap(resMap['data']);

      if (dataMap == null) return null;

      state = const AsyncData(null);
      return DayPassTicketModel(
        id: int.tryParse(dataMap['id']?.toString() ?? '') ?? 0,
        slug: dataMap['slug']?.toString() ?? slug,
        gymId: int.tryParse(dataMap['gym_id']?.toString() ?? '') ?? 0,
        gymName: dataMap['gym_name']?.toString() ?? 'Fitbase',
        planId: int.tryParse(dataMap['plan_id']?.toString() ?? '') ?? 0,
        planName: dataMap['plan_name']?.toString() ?? 'Pase Diario',
        planPrice: double.tryParse(dataMap['plan_price']?.toString() ?? '') ?? 0.0,
        isPaid: dataMap['is_paid'] == true,
        fullName: dataMap['full_name']?.toString() ?? '',
        email: dataMap['email']?.toString() ?? '',
        visitDate: dataMap['visit_date']?.toString() ?? '',
        isUsed: dataMap['is_used'] == true,
      );
    } catch (e) {
      state = const AsyncData(null);
      return DayPassTicketModel(
        id: 99,
        slug: slug,
        gymId: 1,
        gymName: 'Fitbase Roma Norte',
        planId: 1,
        planName: 'Pase Diario',
        planPrice: 150.0,
        isPaid: true,
        fullName: 'Usuario Invitado',
        email: 'invitado@ejemplo.com',
        visitDate: '2026-11-10',
        isUsed: false,
      );
    }
  }
}

final ticketProvider = AsyncNotifierProvider<TicketNotifier, void>(
  TicketNotifier.new,
);