import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/screens/user/user_subscriptions_screen.dart';
import 'package:fitbase/presentation/screens/user/user_payments_screen.dart';
import 'package:fitbase/presentation/screens/user/user_plans_screen.dart';
import 'package:fitbase/presentation/screens/user/gym_map_screen.dart';
import 'package:fitbase/presentation/screens/common/ticket_screen.dart';
import 'package:fitbase/presentation/screens/user/user_attendance_screen.dart';


class UserHomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const UserHomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
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

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, Carlos 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Membresía Activa • Black Pro',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TicketScreen(
                      title: 'Carlos Mendoza',
                      subtitle: 'Membresía Black Anual',
                      slug: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                      dateInfo: 'Vigencia: 01 Ene 2026 - 01 Ene 2027',
                      isActive: true,
                      isMembership: true,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF222904), AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withAlpha(120)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Pase Digital de Acceso',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'QR LISTO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 48,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fitbase Central Hub',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Muestra este código al torniquete para ingresar.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.calendar_month_rounded,
                  label: 'Suscripción',
                  onTap: () {
                    CustomNavigator.pushFade(context, const UserSubscriptionsScreen(isModal: true));
                  },
                ),
                const SizedBox(width: 12),
                _buildActionItem(
                  context,
                  icon: Icons.credit_card_rounded,
                  label: 'Pagos',
                  onTap: () {
                    CustomNavigator.pushFade(context, const UserPaymentsScreen(isModal: true));
                  },
                ),
                const SizedBox(width: 12),
                _buildActionItem(
                  context,
                  icon: Icons.card_membership_rounded,
                  label: 'Planes',
                  onTap: () {
                    CustomNavigator.pushFade(context, const UserPlansScreen(isModal: true));
                  },
                ),
                const SizedBox(width: 12),
                _buildActionItem(
                  context,
                  icon: Icons.map_rounded,
                  label: 'Sedes',
                  onTap: () {
                    CustomNavigator.pushFade(context, const GymMapScreen(isModal: true));
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Agendas y Visitas Recientes',
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
                    CustomNavigator.pushFade(context, const UserAttendanceScreen(isModal: true));
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildAgendaItem(
              title: 'Entrenamiento de Pecho y Tríceps',
              gym: 'Fitbase Central Hub',
              date: 'Hoy, 18:30 - 20:00',
              status: 'Confirmado',
              statusColor: AppColors.primary,
              icon: Icons.fitness_center_rounded,
            ),
            _buildAgendaItem(
              title: 'Clase de Spinning Intensivo',
              gym: 'Fitbase Polanco Elite',
              date: 'Mañana, 07:00 - 08:00',
              status: 'Agendado',
              statusColor: AppColors.info,
              icon: Icons.pedal_bike_rounded,
            ),
            _buildAgendaItem(
              title: 'Sesión de Funcional & HIIT',
              gym: 'Fitbase Central Hub',
              date: 'Ayer, 19:00 - 20:15',
              status: 'Completado',
              statusColor: AppColors.textSecondary,
              icon: Icons.timer_rounded,
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    ),
  ),
);
}

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
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
      ),
    );
  }

  Widget _buildAgendaItem({
    required String title,
    required String gym,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gym,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}