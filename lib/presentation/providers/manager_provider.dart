import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/manager_model.dart';
import 'package:fitbase/infrastructure/mappers/manager_mapper.dart';

class ManagerNotifier extends AsyncNotifier<ManagerState> {
  ManagerState get _current => state.value ?? const ManagerState();

  @override
  Future<ManagerState> build() async {
    return const ManagerState();
  }

  Future<ManagerDetail> getManager() async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.get('/managers/me');
      final resMap = ManagerMapper.toSafeMap(res.data);
      final dataMap = ManagerMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        throw Exception('Error al obtener datos del encargado');
      }

      final detail = ManagerMapper.fromDetailMap(dataMap);
      state = AsyncData(_current.copyWith(
        managerMe: detail,
        loading: false,
      ));
      return detail;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> getManagersByGym({
    int? page,
    int? pageSize,
    String? search,
  }) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final currentPage = page ?? _current.pagination.page;
      final currentSize = pageSize ?? _current.pagination.pageSize;
      final currentSearch = search ?? _current.pagination.search;

      final res = await apiAuth.get('/gyms/managers', queryParameters: {
        'page': currentPage,
        'page_size': currentSize,
        if (currentSearch.isNotEmpty) 'search': currentSearch,
      });

      final resMap = ManagerMapper.toSafeMap(res.data);
      final dataObj = ManagerMapper.toNullableMap(resMap['data']);
      final rawList = dataObj?['data'];
      final rawPaginate = dataObj?['paginate'] ?? dataObj?['pagination'];

      List<ManagerItem> items = [];
      if (rawList is List) {
        items = rawList
            .whereType<Map>()
            .map((e) => ManagerMapper.fromItemMap(ManagerMapper.toSafeMap(e)))
            .toList();
      }

      PaginationManager pagination = _current.pagination;
      if (rawPaginate != null) {
        pagination = ManagerMapper.fromPaginationMap(
          ManagerMapper.toSafeMap(rawPaginate),
        );
      }

      state = AsyncData(_current.copyWith(
        managers: items,
        pagination: pagination,
        loading: false,
      ));
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> createManager([ManagerForm? form]) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final payload = form ?? _current.managerForm;
      final res = await apiAuth.post(
        '/managers',
        data: ManagerMapper.formToMap(payload),
      );

      final resMap = ManagerMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Encargado registrado exitosamente';
      await getManagersByGym();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> updateManager({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final res = await apiAuth.put('/managers/me', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      final resMap = ManagerMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Perfil actualizado exitosamente';
      await getManager();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    state = AsyncData(_current.copyWith(loading: true));
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final res = await apiAuth.post('/managers/me/upload-avatar', data: formData);
      final resMap = ManagerMapper.toSafeMap(res.data);
      final message = resMap['message']?.toString() ?? 'Avatar actualizado exitosamente';
      await getManager();
      return message;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  void resetForm() {
    state = AsyncData(_current.copyWith(
      managerForm: const ManagerForm(),
    ));
  }
}

final managerProvider = AsyncNotifierProvider<ManagerNotifier, ManagerState>(
  ManagerNotifier.new,
);
