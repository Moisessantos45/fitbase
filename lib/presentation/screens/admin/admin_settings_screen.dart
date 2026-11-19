import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/providers/owner_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/screens/admin/admin_managers_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_profile_screen.dart';
import 'package:fitbase/presentation/screens/manger/manager_profile_screen.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/widgets/manger/close_cash_dialog.dart';
import 'package:fitbase/presentation/screens/common/change_password_screen.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _capacityAlerts = ValueNotifier<bool>(true);
  final _dailyReportEmail = ValueNotifier<bool>(true);
  final _autoBackup = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authProvider).value?.authData;
      if (user?.roleId == 2) {
        ref.read(ownerProvider.notifier).getOwner();
      }
    });
  }

  @override
  void dispose() {
    _capacityAlerts.dispose();
    _dailyReportEmail.dispose();
    _autoBackup.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    final user = ref.read(authProvider).value?.authData;
    if (user?.roleId == 2) {
      CustomNavigator.pushFade(context, const AdminProfileScreen());
    } else {
      CustomNavigator.pushFade(context, const ManagerProfileScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).value?.authData;
    final owner = ref.watch(ownerProvider).value;

    final displayName = (owner != null &&
            (owner.firstName.isNotEmpty || owner.lastName.isNotEmpty))
        ? '${owner.firstName} ${owner.lastName}'.trim()
        : (authUser?.roleId == 2
            ? 'Propietario de Gimnasio'
            : 'Encargado de Sucursal');

    final displayEmail = authUser?.email.isNotEmpty == true
        ? authUser!.email
        : 'admin@fitbase.io';

    final displayRole = authUser?.roleId == 2
        ? 'Rol: Propietario (Owner)'
        : 'Rol: Encargado (Manager)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToProfile,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: (owner != null && owner.avatarUrl.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                owner.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  authUser?.roleId == 2
                                      ? Icons.business_center_rounded
                                      : Icons.manage_accounts_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              authUser?.roleId == 2
                                  ? Icons.business_center_rounded
                                  : Icons.manage_accounts_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayRole,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Alertas del Gimnasio'),
          ValueListenableBuilder<bool>(
            valueListenable: _capacityAlerts,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Alertas de Aforo Máximo',
              subtitle: 'Notificar cuando se supere el 80% de capacidad',
              value: val,
              onChanged: (newVal) => _capacityAlerts.value = newVal,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _dailyReportEmail,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Resumen Diario por Correo',
              subtitle: 'Enviar reporte diario de nuevos pagos y accesos',
              value: val,
              onChanged: (newVal) => _dailyReportEmail.value = newVal,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _autoBackup,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Respaldo Automático',
              subtitle: 'Copia de seguridad nocturna de usuarios y pagos',
              value: val,
              onChanged: (newVal) => _autoBackup.value = newVal,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Gestión y Seguridad'),
          _buildNavTile(
            title: authUser?.roleId == 2
                ? 'Ver Perfil de Propietario'
                : 'Ver Perfil de Encargado',
            icon: Icons.person_outline_rounded,
            onTap: _navigateToProfile,
          ),
          _buildNavTile(
            title: 'Gestionar Encargados y Personal',
            icon: Icons.badge_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminManagersScreen(isModal: true)),
              );
            },
          ),
          _buildNavTile(
            title: 'Cambiar Contraseña',
            icon: Icons.lock_outline_rounded,
            onTap: () {
              CustomNavigator.pushFade(context, const ChangePasswordScreen());
            },
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Cerrar Sesión',
            isOutlined: true,
            icon: Icons.logout_rounded,
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          activeThumbColor: AppColors.onPrimary,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: AppColors.textSecondary,
          inactiveTrackColor: AppColors.surfaceLight,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Icon(icon, color: AppColors.textSecondary, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textSecondary,
            size: 14,
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Se cerrará la sesión de administrador y regresarás a la pantalla de inicio.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final authUser = ref.read(authProvider).value?.authData;
              if (authUser?.roleId == 3) {
                final box = await ref.read(cashRegisterProvider.notifier).checkCurrent();
                if (box != null && box.isOpen && context.mounted) {
                  CloseCashDialog.show(
                    context,
                    onClosed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
                      }
                    },
                  );
                  return;
                }
              }
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
