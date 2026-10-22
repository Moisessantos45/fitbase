import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/infrastructure/mappers/gym_mapper.dart';

class GymNotifier extends AsyncNotifier<GymModel?> {
  @override
  Future<GymModel?> build() async {
    return null;
  }

  Future<GymModel?> getMyGym() async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/gyms/my-gym');
      final resMap = GymMapper.toSafeMap(res.data);
      final dataMap = GymMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        state = const AsyncData(null);
        return null;
      }

      final gym = GymMapper.fromMap(dataMap);
      state = AsyncData(gym);
      return gym;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> updateGym({
    required int id,
    required String name,
    required String address,
    required String phone,
    required String email,
    double? latitude,
    double? longitude,
  }) async {
    state = const AsyncLoading();
    try {
      final payload = <String, dynamic>{
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
      };
      if (latitude != null) {
        payload['latitude'] = latitude;
      }
      if (longitude != null) {
        payload['longitude'] = longitude;
      }

      final res = await apiAuth.put(
        '/gyms/$id',
        data: payload,
      );

      final resMap = GymMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Gimnasio actualizado exitosamente';
      await getMyGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<GymModel> createGym({
    required String name,
    required String address,
    required String phone,
    required String email,
    required double latitude,
    required double longitude,
    String? coverPath,
    List<String>? photoPaths,
  }) async {
    state = const AsyncLoading();
    try {
      dynamic requestData;

      if (coverPath != null || (photoPaths != null && photoPaths.isNotEmpty)) {
        final formMap = <String, dynamic>{
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        };

        if (coverPath != null && coverPath.isNotEmpty) {
          final fileName = coverPath.split('/').last;
          formMap['cover'] =
              await MultipartFile.fromFile(coverPath, filename: fileName);
        }

        if (photoPaths != null && photoPaths.isNotEmpty) {
          final files = <MultipartFile>[];
          for (final path in photoPaths) {
            final fileName = path.split('/').last;
            files.add(await MultipartFile.fromFile(path, filename: fileName));
          }
          formMap['images'] = files;
        }

        requestData = FormData.fromMap(formMap);
      } else {
        requestData = {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      final res = await apiAuth.post('/gyms', data: requestData);
      final resMap = GymMapper.toSafeMap(res.data);
      final dataMap = GymMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al registrar gimnasio');
      }

      final gym = GymMapper.fromMap(dataMap);
      state = AsyncData(gym);
      return gym;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> updateSchedule({
    required int gymId,
    required int scheduleId,
    required int openMinutes,
    required int closeMinutes,
    required bool isClosed,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.put(
        '/gyms/$gymId/schedules/$scheduleId',
        data: {
          'open_minutes': openMinutes,
          'close_minutes': closeMinutes,
          'is_closed': isClosed,
        },
      );

      final resMap = GymMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Horario actualizado exitosamente';
      await getMyGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> uploadCover({
    required int gymId,
    required String filePath,
  }) async {
    state = const AsyncLoading();
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'cover': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final res = await apiAuth.post('/gyms/$gymId/cover', data: formData);
      final resMap = GymMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Foto de portada actualizada exitosamente';
      await getMyGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> uploadPhotos({
    required int gymId,
    required List<String> filePaths,
  }) async {
    state = const AsyncLoading();
    try {
      final files = <MultipartFile>[];
      for (final path in filePaths) {
        final fileName = path.split('/').last;
        files.add(await MultipartFile.fromFile(path, filename: fileName));
      }

      final formData = FormData.fromMap({
        'images': files,
      });

      final res = await apiAuth.post('/gyms/$gymId/photos', data: formData);
      final resMap = GymMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Imágenes subidas exitosamente';
      await getMyGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> deletePhoto({
    required int gymId,
    required int photoId,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.delete('/gyms/$gymId/photos/$photoId');
      final resMap = GymMapper.toSafeMap(res.data);
      final message =
          resMap['message']?.toString() ?? 'Fotografía eliminada exitosamente';
      await getMyGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final gymProvider = AsyncNotifierProvider<GymNotifier, GymModel?>(
  GymNotifier.new,
);
