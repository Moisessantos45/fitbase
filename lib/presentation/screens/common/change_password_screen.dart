import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _obscureCurrent = ValueNotifier<bool>(true);
  final _obscureNew = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);
  final _loading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _obscureCurrent.dispose();
    _obscureNew.dispose();
    _obscureConfirm.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Por favor completa todos los campos requeridos.'),
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('La nueva contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Las contraseñas no coinciden.'),
        ),
      );
      return;
    }

    if (currentPassword == newPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('La nueva contraseña no puede ser igual a la actual.'),
        ),
      );
      return;
    }

    _loading.value = true;

    try {
      final message = await ref.read(authProvider.notifier).updatePassword(
            currentPassword,
            newPassword,
          );

      if (mounted) {
        _loading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(message),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _loading.value = false;
        final authState = ref.read(authProvider).value;
        final msg = authState?.alertMessage.msg ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(msg.isNotEmpty ? msg : 'Error al actualizar contraseña'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Cambiar Contraseña',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Tu nueva contraseña debe tener un mínimo de 6 caracteres para proteger tu cuenta.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _obscureCurrent,
                builder: (context, obscure, _) {
                  return CustomTextField(
                    label: 'Contraseña Actual',
                    controller: _currentPasswordController,
                    hintText: '••••••••',
                    obscureText: obscure,
                    prefixIcon: Icons.lock_clock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _obscureCurrent.value = !_obscureCurrent.value;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: _obscureNew,
                builder: (context, obscure, _) {
                  return CustomTextField(
                    label: 'Nueva Contraseña',
                    controller: _newPasswordController,
                    hintText: '••••••••',
                    obscureText: obscure,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _obscureNew.value = !_obscureNew.value;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: _obscureConfirm,
                builder: (context, obscure, _) {
                  return CustomTextField(
                    label: 'Confirmar Nueva Contraseña',
                    controller: _confirmPasswordController,
                    hintText: '••••••••',
                    obscureText: obscure,
                    prefixIcon: Icons.lock_reset_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _obscureConfirm.value = !_obscureConfirm.value;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _loading,
                builder: (context, loading, _) {
                  return CustomButton(
                    text: loading
                        ? 'Actualizando...'
                        : 'Actualizar Contraseña',
                    icon: loading ? null : Icons.save_rounded,
                    onPressed: loading ? () {} : _handleSubmit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
