import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/screens/common/change_password_screen.dart';
import 'package:fitbase/presentation/screens/user/user_profile_screen.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _pushNotifications = ValueNotifier<bool>(true);
  final _biometrics = ValueNotifier<bool>(false);
  final _autoRenew = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _pushNotifications.dispose();
    _biometrics.dispose();
    _autoRenew.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader('Preferencias'),
          ValueListenableBuilder<bool>(
            valueListenable: _pushNotifications,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Notificaciones Push',
              subtitle: 'Alertas de horarios y recordatorios',
              value: val,
              onChanged: (newVal) => _pushNotifications.value = newVal,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _biometrics,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Acceso Biométrico',
              subtitle: 'Ingreso rápido con huella o Face ID',
              value: val,
              onChanged: (newVal) => _biometrics.value = newVal,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _autoRenew,
            builder: (context, val, _) => _buildSwitchTile(
              title: 'Renovación Automática',
              subtitle: 'Cobro recurrente al vencer membresía',
              value: val,
              onChanged: (newVal) => _autoRenew.value = newVal,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Cuenta y Seguridad'),
          _buildNavTile(
            title: 'Ver Mi Perfil',
            icon: Icons.person_outline_rounded,
            onTap: () {
              CustomNavigator.pushFade(context, const UserProfileScreen());
            },
          ),
          _buildNavTile(
            title: 'Cambiar Contraseña',
            icon: Icons.lock_outline_rounded,
            onTap: () {
              CustomNavigator.pushFade(context, const ChangePasswordScreen());
            },
          ),
          _buildNavTile(
            title: 'Métodos de Pago Guardados',
            icon: Icons.credit_card_rounded,
            onTap: () {},
          ),
          _buildNavTile(
            title: 'Términos y Condiciones',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildNavTile(
            title: 'Política de Privacidad',
            icon: Icons.shield_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Soporte'),
          _buildNavTile(
            title: 'Ayuda y Preguntas Frecuentes',
            icon: Icons.help_outline_rounded,
            onTap: () {},
          ),
          _buildNavTile(
            title: 'Contactar al Gimnasio',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {},
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Cerrar Sesión',
            isOutlined: true,
            icon: Icons.logout_rounded,
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Fitbase App v1.0.0',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Se cerrará tu sesión actual y regresarás a la pantalla de inicio.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
              }
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
}
