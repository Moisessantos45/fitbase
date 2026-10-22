import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
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

class AdminDashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const AdminDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).value?.authData;
    final owner = ref.watch(ownerProvider).value;

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

            return ListView(
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
                                    authUser?.email ?? 'Fitbase Hub • En Vivo',
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
                GridView.count(
                  crossAxisCount: gridColumns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: gridRatio,
                  children: const [
                    MetricSummaryCard(
                      title: 'Total Usuarios',
                      value: '1,248',
                      subtitle: '+24 esta semana',
                      icon: Icons.people_alt_rounded,
                    ),
                    MetricSummaryCard(
                      title: 'Suscripciones Activas',
                      value: '892',
                      subtitle: '71.4% de retención',
                      icon: Icons.card_membership_rounded,
                    ),
                    MetricSummaryCard(
                      title: 'Ingresos del Mes',
                      value: '\$142.8k',
                      subtitle: '+14% vs mes anterior',
                      icon: Icons.attach_money_rounded,
                    ),
                    MetricSummaryCard(
                      title: 'Aforo Actual',
                      value: '78 / 250',
                      subtitle: '31% de capacidad',
                      icon: Icons.fitness_center_rounded,
                    ),
                  ],
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
                        'Últimas Actividades y Pagos',
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
                _buildActivityItem(
                  'Carlos Mendoza',
                  'Renovó Plan Black Pro',
                  '+\$499',
                  'Hace 10 min',
                ),
                _buildActivityItem(
                  'Lucía Morales',
                  'Nuevo Registro Plan Anual VIP',
                  '+\$4,990',
                  'Hace 45 min',
                ),
                _buildActivityItem(
                  'Rodrigo Sánchez',
                  'Acceso registrado en torniquete',
                  'Check-in',
                  'Hace 1 hora',
                ),
                _buildActivityItem(
                  'Valeria Gómez',
                  'Pago de membresía en mostrador',
                  '+\$499',
                  'Hace 2 horas',
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
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

  Widget _buildActivityItem(
    String name,
    String action,
    String amount,
    String time,
  ) {
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
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
