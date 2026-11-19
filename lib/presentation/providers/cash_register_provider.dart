import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/cash_register_model.dart';
import 'package:fitbase/infrastructure/mappers/cash_register_mapper.dart';

class CashRegisterNotifier extends AsyncNotifier<CashRegisterModel?> {
  @override
  Future<CashRegisterModel?> build() async {
    return null;
  }

  Future<CashRegisterModel?> checkCurrent() async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/cash-register/current');
      final resMap = CashRegisterMapper.toSafeMap(res.data);
      final dataMap = CashRegisterMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        state = const AsyncData(null);
        return null;
      }

      final box = CashRegisterMapper.fromMap(dataMap);
      state = AsyncData(box);
      return box;
    } on DioException {
      state = const AsyncData(null);
      return null;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return null;
    }
  }

  Future<CashRegisterModel> openRegister({
    required int gymId,
    required double openCash,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.post(
        '/cash-register/open',
        data: {
          'gym_id': gymId,
          'open_cash': openCash,
        },
      );
      final resMap = CashRegisterMapper.toSafeMap(res.data);
      final dataMap = CashRegisterMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al abrir la caja');
      }

      final box = CashRegisterMapper.fromMap(dataMap);
      state = AsyncData(box);
      return box;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> closeRegister({required double closeCash}) async {
    state = const AsyncLoading();
    try {
      await apiAuth.post(
        '/cash-register/close',
        data: {
          'close_cash': closeCash,
        },
      );
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final cashRegisterProvider =
    AsyncNotifierProvider<CashRegisterNotifier, CashRegisterModel?>(
  CashRegisterNotifier.new,
);
