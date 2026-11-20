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

  String _extractError(Object e, String fallback) {
    if (e is DioException && e.response?.data != null) {
      final errMap = UserMapper.toSafeMap(e.response?.data);
      final rawErrors = errMap['errors'];
      if (rawErrors is List && rawErrors.isNotEmpty) {
        return rawErrors.map((item) => item.toString()).join(', ');
      }
      final msg = errMap['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return e.toString().replaceAll('Exception:', '').trim().isNotEmpty
        ? e.toString().replaceAll('Exception:', '').trim()
        : fallback;
  }

  Future<UserProfile> getUser() async {
    state = const AsyncLoading();
    try {
      Response? res;
      try {
        res = await apiAuth.get('/users/me');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          try {
            res = await apiAuth.get('/user/me');
          } on DioException catch (e2) {
            if (e2.response?.statusCode == 404) {
              const emptyUser = UserProfile();
              state = const AsyncData(emptyUser);
              return emptyUser;
            }
            rethrow;
          }
        } else {
          rethrow;
        }
      }
      final resMap = UserMapper.toSafeMap(res.data);
      final dataMap = UserMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        const emptyUser = UserProfile();
        state = const AsyncData(emptyUser);
        return emptyUser;
      }

      final user = UserMapper.fromMap(dataMap);
      state = AsyncData(user);
      return user;
    } catch (e) {
      state = const AsyncData(UserProfile());
      return const UserProfile();
    }
  }

  Future<UserProfile> addUser({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final prevUser = state.value ?? const UserProfile();
    state = const AsyncLoading();
    try {
      final payload = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };
      Response res;
      try {
        res = await apiAuth.post('/users', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          res = await apiAuth.post('/user', data: payload);
        } else {
          rethrow;
        }
      }

      final resMap = UserMapper.toSafeMap(res.data);
      final dataMap = UserMapper.toNullableMap(resMap['data']);
      final user = dataMap != null
          ? UserMapper.fromMap(dataMap)
          : UserProfile(firstName: firstName, lastName: lastName, phone: phone ?? '');
      state = AsyncData(user);
      await ref.read(authProvider.notifier).getSession();
      return user;
    } catch (e) {
      state = AsyncData(prevUser);
      throw Exception(_extractError(e, 'Error al registrar datos de usuario'));
    }
  }

  Future<String> updateUser({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final prevUser = state.value ?? const UserProfile();
    state = const AsyncLoading();
    try {
      final payload = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };
      Response res;
      try {
        res = await apiAuth.put('/users/me', data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          res = await apiAuth.put('/user/me', data: payload);
        } else {
          rethrow;
        }
      }

      final resMap = UserMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Perfil actualizado exitosamente';
      await getUser();
      return message;
    } catch (e) {
      state = AsyncData(prevUser);
      throw Exception(_extractError(e, 'Error al actualizar perfil'));
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    final prevUser = state.value ?? const UserProfile();
    state = const AsyncLoading();
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      Response res;
      try {
        res = await apiAuth.post('/users/me/upload-avatar', data: formData);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          res = await apiAuth.post('/user/me/upload-avatar', data: formData);
        } else {
          rethrow;
        }
      }

      final resMap = UserMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Avatar actualizado exitosamente';
      await getUser();
      return message;
    } catch (e) {
      state = AsyncData(prevUser);
      throw Exception(_extractError(e, 'Error al subir avatar'));
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserProfile>(
  UserNotifier.new,
);
