import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/user_model.dart';
import 'package:fitbase/infrastructure/mappers/user_mapper.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';

class UserNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    return const UserProfile();
  }

  Future<UserProfile> getUser() async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/user/me');
      final resMap = UserMapper.toSafeMap(res.data);
      final dataMap = UserMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al obtener el perfil de usuario');
      }

      final user = UserMapper.fromMap(dataMap);
      state = AsyncData(user);
      return user;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<UserProfile> addUser({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.post('/user', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      final resMap = UserMapper.toSafeMap(res.data);
      final dataMap = UserMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al registrar datos de usuario');
      }

      final user = UserMapper.fromMap(dataMap);
      state = AsyncData(user);
      ref.read(authProvider.notifier).getSession();
      return user;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> updateUser({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.put('/user/me', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      final resMap = UserMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Perfil actualizado exitosamente';
      await getUser();
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

      final res = await apiAuth.post('/user/me/upload-avatar', data: formData);
      final resMap = UserMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Avatar actualizado exitosamente';
      await getUser();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserProfile>(
  UserNotifier.new,
);
