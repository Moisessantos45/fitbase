import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/analytics_model.dart';
import 'package:fitbase/infrastructure/mappers/analytics_mapper.dart';

class AnalyticsNotifier extends AsyncNotifier<DashboardSummary?> {
  @override
  Future<DashboardSummary?> build() async {
    return null;
  }

  Future<DashboardSummary?> getDashboardSummary(int gymId) async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/gyms/$gymId/analytics/dashboard-summary');
      final resMap = AnalyticsMapper.toSafeMap(res.data);
      final dataMap = AnalyticsMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        state = const AsyncData(null);
        return null;
      }

      final summary = AnalyticsMapper.dashboardSummaryFromMap(dataMap);
      state = AsyncData(summary);
      return summary;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final analyticsProvider =
    AsyncNotifierProvider<AnalyticsNotifier, DashboardSummary?>(
  AnalyticsNotifier.new,
);

class AttendanceNotifier extends AsyncNotifier<AttendanceReport?> {
  @override
  Future<AttendanceReport?> build() async {
    return null;
  }

  Future<AttendanceReport?> getAttendanceMetrics(
    int gymId, {
    String? from,
    String? to,
  }) async {
    state = const AsyncLoading();
    try {
      final queryParams = <String, dynamic>{};
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;

      final res = await apiAuth.get(
        '/gyms/$gymId/analytics/attendance',
        queryParameters: queryParams,
      );
      final resMap = AnalyticsMapper.toSafeMap(res.data);
      final dataMap = AnalyticsMapper.toNullableMap(resMap['data']);
      if (dataMap == null) {
        state = const AsyncData(null);
        return null;
      }

      final report = AnalyticsMapper.attendanceReportFromMap(dataMap);
      state = AsyncData(report);
      return report;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, AttendanceReport?>(
  AttendanceNotifier.new,
);

