import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _acceptTerms = ValueNotifier<bool>(true);
  final _loading = ValueNotifier<bool>(false);
  final _isOwner = ValueNotifier<bool>(false);
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _acceptTerms.dispose();
    _loading.dispose();
    _isOwner.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Por favor completa todos los campos obligatorios.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Las contraseñas no coinciden.'),
        ),
      );
      return;
    }

    if (!_acceptTerms.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Debes aceptar los términos y condiciones para continuar.'),
        ),
      );
      return;
    }

    _loading.value = true;

    try {
      final msg = await ref
          .read(authProvider.notifier)
          .register(email, password, _isOwner.value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(msg),
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
            content: Text(msg.isNotEmpty ? msg : 'Error al registrar usuario'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    if (authState != null && authState.authenticated) {
      return const AuthGate();
    }

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Únete a Fitbase y transforma tu estilo de vida',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              const Text(
                'Tipo de Cuenta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: _isOwner,
                builder: (context, isOwner, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _isOwner.value = false,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: !isOwner
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !isOwner
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: !isOwner ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: !isOwner
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Usuario',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !isOwner
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Entrena en sedes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _isOwner.value = true,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isOwner
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isOwner
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isOwner ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  color: isOwner
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Dueño de Gym',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isOwner
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Administra tu sede',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Correo Electrónico *',
                controller: _emailController,
                hintText: 'ejemplo@correo.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _obscurePassword,
                builder: (context, obscure, _) {
                  return CustomTextField(
                    label: 'Contraseña *',
                    controller: _passwordController,
                    hintText: 'Mínimo 6 caracteres',
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
                        _obscurePassword.value = !_obscurePassword.value;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _obscureConfirm,
                builder: (context, obscure, _) {
                  return CustomTextField(
                    label: 'Confirmar Contraseña *',
                    controller: _confirmPasswordController,
                    hintText: 'Repite tu contraseña',
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
                        _obscureConfirm.value = !_obscureConfirm.value;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _acceptTerms,
                builder: (context, acceptTerms, _) {
                  return Row(
                    children: [
                      Checkbox(
                        value: acceptTerms,
                        activeColor: AppColors.primary,
                        checkColor: AppColors.onPrimary,
                        onChanged: (val) => _acceptTerms.value = val ?? false,
                      ),
                      const Expanded(
                        child: Text(
                          'Acepto los Términos y Condiciones y la Política de Privacidad.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _loading,
                builder: (context, loading, _) {
                  return CustomButton(
                    text: loading ? 'Registrando...' : 'Registrarme',
                    onPressed: loading ? () {} : _handleRegister,
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
