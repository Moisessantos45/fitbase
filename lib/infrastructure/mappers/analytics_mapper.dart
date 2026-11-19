import 'package:fitbase/domain/analytics_model.dart';

class AnalyticsMapper {
  static Map<String, dynamic> toSafeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? toNullableMap(dynamic value) {
    if (value == null) return null;
    final map = toSafeMap(value);
    return map.isEmpty ? null : map;
  }

  static DashboardKPIs kpisFromMap(Map<String, dynamic> map) {
    final rawPeakHour = map['peak_hour'] != null
        ? int.tryParse(map['peak_hour'].toString())
        : null;

    return DashboardKPIs(
      totalRevenue: double.tryParse(map['total_revenue']?.toString() ?? '') ?? 0.0,
      totalTransactions: int.tryParse(map['total_transactions']?.toString() ?? '') ?? 0,
      activeSubscribers: int.tryParse(map['active_subscribers']?.toString() ?? '') ?? 0,
      totalCheckIns: int.tryParse(map['total_check_ins']?.toString() ?? '') ?? 0,
      peakHour: rawPeakHour,
      peakHourCount: int.tryParse(map['peak_hour_count']?.toString() ?? '') ?? 0,
    );
  }

  static DashboardRecentPayment recentPaymentFromMap(Map<String, dynamic> map) {
    return DashboardRecentPayment(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      paymentMethodName: map['payment_method_name']?.toString() ?? '',
      paymentStatusName: map['payment_status_name']?.toString() ?? '',
      paymentDate: map['payment_date']?.toString() ?? '',
    );
  }

  static DashboardRecentShift recentShiftFromMap(Map<String, dynamic> map) {
    return DashboardRecentShift(
      shiftId: int.tryParse(map['shift_id']?.toString() ?? '') ?? 0,
      managerName: map['manager_name']?.toString() ?? '',
      openTime: map['open_time']?.toString() ?? '',
      closeTime: map['close_time']?.toString(),
      openCash: double.tryParse(map['open_cash']?.toString() ?? '') ?? 0.0,
      status: map['status']?.toString() ?? '',
    );
  }

  static DashboardSummary dashboardSummaryFromMap(Map<String, dynamic> map) {
    final kpisMap = toNullableMap(map['kpis']) ?? <String, dynamic>{};

    final rawPayments = map['recent_payments'];
    final List<DashboardRecentPayment> recentPayments = [];
    if (rawPayments is List) {
      for (final p in rawPayments) {
        final pMap = toNullableMap(p);
        if (pMap != null) {
          recentPayments.add(recentPaymentFromMap(pMap));
        }
      }
    }

    final rawShifts = map['recent_shifts'];
    final List<DashboardRecentShift> recentShifts = [];
    if (rawShifts is List) {
      for (final s in rawShifts) {
        final sMap = toNullableMap(s);
        if (sMap != null) {
          recentShifts.add(recentShiftFromMap(sMap));
        }
      }
    }

    return DashboardSummary(
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      kpis: kpisFromMap(kpisMap),
      recentPayments: recentPayments,
      recentShifts: recentShifts,
    );
  }

  static HourlyDistributionItem hourlyItemFromMap(Map<String, dynamic> map) {
    return HourlyDistributionItem(
      hour: int.tryParse(map['hour']?.toString() ?? '') ?? 0,
      count: int.tryParse(map['count']?.toString() ?? '') ?? 0,
    );
  }

  static AttendanceReport attendanceReportFromMap(Map<String, dynamic> map) {
    final rawHourly = map['hourly_distribution'];
    final List<HourlyDistributionItem> hourlyDistribution = [];
    if (rawHourly is List) {
      for (final h in rawHourly) {
        final hMap = toNullableMap(h);
        if (hMap != null) {
          hourlyDistribution.add(hourlyItemFromMap(hMap));
        }
      }
    }

    return AttendanceReport(
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      gymName: map['gym_name']?.toString() ?? '',
      totalCheckIns: int.tryParse(map['total_check_ins']?.toString() ?? '') ?? 0,
      peakHour: int.tryParse(map['peak_hour']?.toString() ?? '') ?? 0,
      peakHourCount: int.tryParse(map['peak_hour_count']?.toString() ?? '') ?? 0,
      membershipsCount: int.tryParse(map['memberships_count']?.toString() ?? '') ?? 0,
      dayPassesCount: int.tryParse(map['day_passes_count']?.toString() ?? '') ?? 0,
      guestsCount: int.tryParse(map['guests_count']?.toString() ?? '') ?? 0,
      hourlyDistribution: hourlyDistribution,
    );
  }
}

