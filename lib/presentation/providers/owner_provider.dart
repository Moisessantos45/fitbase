import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/owner_model.dart';
import 'package:fitbase/infrastructure/mappers/owner_mapper.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';

class OwnerNotifier extends AsyncNotifier<OwnerProfile> {
  @override
  Future<OwnerProfile> build() async {
    return const OwnerProfile();
  }

  Future<OwnerProfile> getOwner() async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/owner/me');
      final resMap = OwnerMapper.toSafeMap(res.data);
      final dataMap = OwnerMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al obtener el perfil de propietario');
      }

      final owner = OwnerMapper.fromMap(dataMap);
      state = AsyncData(owner);
      return owner;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<OwnerProfile> create({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.post('/owner/complete-profile', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      final resMap = OwnerMapper.toSafeMap(res.data);
      final dataMap = OwnerMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al completar el perfil');
      }

      final owner = OwnerMapper.fromMap(dataMap);
      state = AsyncData(owner);
      ref.read(authProvider.notifier).getSession();
      return owner;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> updateOwner({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.put('/owner/me', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      final resMap = OwnerMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Perfil actualizado exitosamente';
      await getOwner();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    state = const AsyncLoading();
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final res = await apiAuth.post('/owner/me/upload-avatar', data: formData);
      final resMap = OwnerMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Avatar actualizado exitosamente';
      await getOwner();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final ownerProvider = AsyncNotifierProvider<OwnerNotifier, OwnerProfile>(
  OwnerNotifier.new,
);
