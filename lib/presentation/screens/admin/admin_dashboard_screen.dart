import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/domain/analytics_model.dart';
import 'package:fitbase/presentation/providers/analytics_provider.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/owner_provider.dart';
import 'package:fitbase/presentation/widgets/metric_summary_card.dart';
import 'package:fitbase/presentation/screens/admin/admin_subscribers_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_managers_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_plans_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_payments_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_gym_edit_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_settings_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_profile_screen.dart';
import 'package:fitbase/presentation/screens/manger/manager_profile_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminDashboardScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    final gym = ref.read(gymProvider).value ??
        await ref.read(gymProvider.notifier).getMyGym();
    if (gym != null && gym.id > 0) {
      await Future.wait([
        ref.read(analyticsProvider.notifier).getDashboardSummary(gym.id),
        ref.read(attendanceProvider.notifier).getAttendanceMetrics(gym.id),
      ]);
    }
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month • $hour:$minute hrs';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).value?.authData;
    final owner = ref.watch(ownerProvider).value;
    final gym = ref.watch(gymProvider).value;
    final analyticsAsync = ref.watch(analyticsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    void navigateToProfile() {
      if (authUser?.roleId == 2) {
        CustomNavigator.pushFade(context, const AdminProfileScreen());
      } else {
        CustomNavigator.pushFade(context, const ManagerProfileScreen());
      }
    }

    final title = (owner != null && owner.firstName.isNotEmpty)
        ? 'Hola, ${owner.firstName}'
        : (authUser?.roleId == 2
            ? 'Panel de Propietario'
            : 'Panel de Encargado');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isTablet =
                constraints.maxWidth >= 600 &&
                constraints.maxHeight >= 600 &&
                constraints.maxWidth < 1024;

            final horizontalPadding = isTablet || isLandscape ? 80.0 : 20.0;
            final gridColumns = isTablet || isLandscape ? 4 : 2;
            final gridRatio = isTablet || isLandscape ? 1.3 : 1.05;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: navigateToProfile,
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  authUser?.roleId == 2
                                      ? Icons.business_center_rounded
                                      : Icons.manage_accounts_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      gym?.name.isNotEmpty == true
                                          ? gym!.name
                                          : (authUser?.email ??
                                              'Fitbase Hub • En Vivo'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: navigateToProfile,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminSettingsScreen(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  analyticsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                    error: (err, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'No fue posible cargar las métricas en tiempo real: $err',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    data: (summary) {
                      final kpis = summary?.kpis ?? const DashboardKPIs();
                      final peakText = kpis.peakHour != null
                          ? '${kpis.peakHour}:00 hrs'
                          : 'Pendiente';

                      return GridView.count(
                        crossAxisCount: gridColumns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: gridRatio,
                        children: [
                          MetricSummaryCard(
                            title: 'Total Recaudado',
                            value: '\$${kpis.totalRevenue.toStringAsFixed(2)}',
                            subtitle:
                                '${kpis.totalTransactions} transacciones',
                            icon: Icons.attach_money_rounded,
                            accentColor: AppColors.primary,
                          ),
                          MetricSummaryCard(
                            title: 'Socios Activos',
                            value: '${kpis.activeSubscribers}',
                            subtitle: 'Membresías vigentes',
                            icon: Icons.card_membership_rounded,
                            accentColor: AppColors.success,
                          ),
                          MetricSummaryCard(
                            title: 'Accesos Registrados',
                            value: '${kpis.totalCheckIns}',
                            subtitle: 'Check-ins en sede',
                            icon: Icons.qr_code_scanner_rounded,
                            accentColor: const Color(0xFF38BDF8),
                          ),
                          MetricSummaryCard(
                            title: 'Hora Pico',
                            value: peakText,
                            subtitle: '${kpis.peakHourCount} entradas',
                            icon: Icons.access_time_filled_rounded,
                            accentColor: AppColors.warning,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  attendanceAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (attendance) {
                      if (attendance == null) return const SizedBox.shrink();
                      return _buildAttendanceCard(attendance);
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Gestión Rápida',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildActionItem(
                          icon: Icons.group_outlined,
                          label: 'Socios',
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminSubscribersScreen(isModal: true),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionItem(
                          icon: Icons.badge_outlined,
                          label: 'Staff',
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminManagersScreen(isModal: true),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionItem(
                          icon: Icons.layers_outlined,
                          label: 'Planes',
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminPlansScreen(isModal: true),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionItem(
                          icon: Icons.payments_outlined,
                          label: 'Pagos',
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminPaymentsScreen(isModal: true),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionItem(
                          icon: Icons.edit_location_alt_outlined,
                          label: 'Sede Gym',
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const AdminGymEditScreen(isModal: true),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Transacciones y Pagos Recientes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          CustomNavigator.pushFade(
                            context,
                            const AdminPaymentsScreen(isModal: true),
                          );
                        },
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  analyticsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (summary) {
                      final payments = summary?.recentPayments ?? [];
                      if (payments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Aún no hay transacciones financieras registradas.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: payments.map((p) {
                          return _buildRealPaymentItem(p);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Turnos de Caja Recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  analyticsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (summary) {
                      final shifts = summary?.recentShifts ?? [];
                      if (shifts.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'No hay turnos de caja registrados recientemente.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: shifts.map((s) {
                          return _buildRealShiftItem(s);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceReport report) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Desglose de Afluencia',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${report.totalCheckIns} Visitas',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStat(
                  'Membresías',
                  '${report.membershipsCount}',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStat(
                  'Pases de Día',
                  '${report.dayPassesCount}',
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStat(
                  'Invitados',
                  '${report.guestsCount}',
                  const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealPaymentItem(DashboardRecentPayment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cobro #${payment.id} • ${payment.paymentMethodName}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(payment.paymentDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                payment.paymentStatusName,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRealShiftItem(DashboardRecentShift shift) {
    final isBalanced = shift.status.toLowerCase().contains('cuadrad');
    final statusColor = isBalanced ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.point_of_sale_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.managerName.isNotEmpty
                        ? shift.managerName
                        : 'Turno #${shift.shiftId}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Inicio: ${_formatDate(shift.openTime)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Fondo: \$${shift.openCash.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shift.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
