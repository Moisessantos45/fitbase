class DashboardKPIs {
  final double totalRevenue;
  final int totalTransactions;
  final int activeSubscribers;
  final int totalCheckIns;
  final int? peakHour;
  final int peakHourCount;

  const DashboardKPIs({
    this.totalRevenue = 0.0,
    this.totalTransactions = 0,
    this.activeSubscribers = 0,
    this.totalCheckIns = 0,
    this.peakHour,
    this.peakHourCount = 0,
  });

  DashboardKPIs copyWith({
    double? totalRevenue,
    int? totalTransactions,
    int? activeSubscribers,
    int? totalCheckIns,
    int? peakHour,
    int? peakHourCount,
  }) {
    return DashboardKPIs(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      activeSubscribers: activeSubscribers ?? this.activeSubscribers,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      peakHour: peakHour ?? this.peakHour,
      peakHourCount: peakHourCount ?? this.peakHourCount,
    );
  }
}

class DashboardRecentPayment {
  final int id;
  final double amount;
  final String paymentMethodName;
  final String paymentStatusName;
  final String paymentDate;

  const DashboardRecentPayment({
    this.id = 0,
    this.amount = 0.0,
    this.paymentMethodName = '',
    this.paymentStatusName = '',
    this.paymentDate = '',
  });

  DashboardRecentPayment copyWith({
    int? id,
    double? amount,
    String? paymentMethodName,
    String? paymentStatusName,
    String? paymentDate,
  }) {
    return DashboardRecentPayment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentStatusName: paymentStatusName ?? this.paymentStatusName,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}

class DashboardRecentShift {
  final int shiftId;
  final String managerName;
  final String openTime;
  final String? closeTime;
  final double openCash;
  final String status;

  const DashboardRecentShift({
    this.shiftId = 0,
    this.managerName = '',
    this.openTime = '',
    this.closeTime,
    this.openCash = 0.0,
    this.status = '',
  });

  DashboardRecentShift copyWith({
    int? shiftId,
    String? managerName,
    String? openTime,
    String? closeTime,
    double? openCash,
    String? status,
  }) {
    return DashboardRecentShift(
      shiftId: shiftId ?? this.shiftId,
      managerName: managerName ?? this.managerName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      openCash: openCash ?? this.openCash,
      status: status ?? this.status,
    );
  }
}

class DashboardSummary {
  final int gymId;
  final String gymName;
  final DashboardKPIs kpis;
  final List<DashboardRecentPayment> recentPayments;
  final List<DashboardRecentShift> recentShifts;

  const DashboardSummary({
    this.gymId = 0,
    this.gymName = '',
    this.kpis = const DashboardKPIs(),
    this.recentPayments = const [],
    this.recentShifts = const [],
  });

  DashboardSummary copyWith({
    int? gymId,
    String? gymName,
    DashboardKPIs? kpis,
    List<DashboardRecentPayment>? recentPayments,
    List<DashboardRecentShift>? recentShifts,
  }) {
    return DashboardSummary(
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      kpis: kpis ?? this.kpis,
      recentPayments: recentPayments ?? this.recentPayments,
      recentShifts: recentShifts ?? this.recentShifts,
    );
  }
}

class HourlyDistributionItem {
  final int hour;
  final int count;

  const HourlyDistributionItem({
    this.hour = 0,
    this.count = 0,
  });
}

class AttendanceReport {
  final int gymId;
  final String gymName;
  final int totalCheckIns;
  final int peakHour;
  final int peakHourCount;
  final int membershipsCount;
  final int dayPassesCount;
  final int guestsCount;
  final List<HourlyDistributionItem> hourlyDistribution;

  const AttendanceReport({
    this.gymId = 0,
    this.gymName = '',
    this.totalCheckIns = 0,
    this.peakHour = 0,
    this.peakHourCount = 0,
    this.membershipsCount = 0,
    this.dayPassesCount = 0,
    this.guestsCount = 0,
    this.hourlyDistribution = const [],
  });
}

