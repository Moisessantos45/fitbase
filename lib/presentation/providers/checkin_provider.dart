import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/checkin_model.dart';
import 'package:fitbase/infrastructure/mappers/checkin_mapper.dart';

class CheckInNotifier extends AsyncNotifier<CheckInResult?> {
  @override
  Future<CheckInResult?> build() async {
    return null;
  }

  Future<CheckInResult> scanAccess({
    required int gymId,
    String? slug,
    String? email,
  }) async {
    state = const AsyncLoading();
    try {
      final payload = <String, dynamic>{
        'gym_id': gymId,
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      };

      final res = await apiAuth.post('/checkin/scan', data: payload);
      final resMap = CheckInMapper.toSafeMap(res.data);
      final dataMap = CheckInMapper.toNullableMap(resMap['data']);
      final message = resMap['message']?.toString() ?? 'Acceso validado';

      final result = dataMap != null
          ? CheckInMapper.fromMap(dataMap, defaultMessage: message)
          : CheckInResult(allowed: true, message: message);

      state = AsyncData(result);
      return result;
    } on DioException catch (dioErr) {
      final errMap = CheckInMapper.toSafeMap(dioErr.response?.data);
      final errMsg = errMap['message']?.toString() ??
          errMap['error']?.toString() ??
          'Acceso no permitido';

      final isPaymentRequired =
          errMsg.toLowerCase().contains('pagado') ||
          errMsg.toLowerCase().contains('abonarse') ||
          errMsg.toLowerCase().contains('pago');

      final result = CheckInResult(
        allowed: false,
        message: errMsg,
        needPayment: isPaymentRequired,
      );
      state = AsyncData(result);
      return result;
    } catch (e, stack) {
      final result = CheckInResult(
        allowed: false,
        message: e.toString(),
      );
      state = AsyncError(e, stack);
      return result;
    }
  }

  void clearResult() {
    state = const AsyncData(null);
  }
}

final checkInProvider =
    AsyncNotifierProvider<CheckInNotifier, CheckInResult?>(
  CheckInNotifier.new,
);
