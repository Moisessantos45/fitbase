import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/screens/guest/guest_home_screen.dart';
import 'package:fitbase/presentation/screens/auth/forgot_password_screen.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _loading = ValueNotifier<bool>(false);
  final _isEmailNotVerified = ValueNotifier<bool>(false);
  final _resendingEmail = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _loading.dispose();
    _isEmailNotVerified.dispose();
    _resendingEmail.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Por favor, ingresa tu correo y contraseña.'),
        ),
      );
      return;
    }

    _loading.value = true;
    _isEmailNotVerified.value = false;

    try {
      final res = await ref.read(authProvider.notifier).login(email, password);
      if (mounted) {
        if (res['status'] == 'PENDING_2FA') {
          _loading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Se requiere verificación de dos factores (2FA).'),
            ),
          );
          return;
        }
        CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
      }
    } catch (e) {
      if (mounted) {
        _loading.value = false;
        final authState = ref.read(authProvider).value;
        final isNotVerified =
            authState?.accountNotVerified == true ||
            authState?.alertMessage.msg == 'EMAIL_NOT_VERIFIED' ||
            e.toString().contains('EMAIL_NOT_VERIFIED');

        if (isNotVerified) {
          _isEmailNotVerified.value = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                'Tu cuenta aún no ha sido verificada. Revisa tu correo o solicita un reenvío.',
              ),
            ),
          );
        } else {
          final msg = authState?.alertMessage.msg ?? e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(msg.isNotEmpty ? msg : 'Error al iniciar sesión'),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResendVerification() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Por favor, ingresa tu correo electrónico.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    _resendingEmail.value = true;

    try {
      await ref.read(authProvider.notifier).forwardEmailVerification(email);
      final alert = ref.read(authProvider).value?.alertMessage;
      final isError = alert?.error ?? false;
      final msg = alert?.msg ?? 'Correo de verificación reenviado.';

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.error : AppColors.success,
          content: Text(msg),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
      );
    } finally {
      _resendingEmail.value = false;
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isTablet =
                constraints.maxWidth >= 600 &&
                constraints.maxHeight >= 600 &&
                constraints.maxWidth < 1024;

            final horizontalPadding = isTablet || isLandscape ? 80.0 : 20.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'FITBASE',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Tu centro integral de entrenamiento',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      CustomTextField(
                        label: 'Correo Electrónico',
                        controller: _emailController,
                        hintText: 'correo@ejemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscurePassword,
                        builder: (context, obscure, _) {
                          return CustomTextField(
                            label: 'Contraseña',
                            controller: _passwordController,
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
                                _obscurePassword.value =
                                    !_obscurePassword.value;
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            CustomNavigator.pushFade(
                              context,
                              const ForgotPasswordScreen(),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: _loading,
                        builder: (context, loading, _) {
                          return CustomButton(
                            text: loading
                                ? 'Iniciando sesión...'
                                : 'Iniciar Sesión',
                            icon: loading ? null : Icons.login_rounded,
                            onPressed: loading ? () {} : _handleLogin,
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isEmailNotVerified,
                        builder: (context, notVerified, _) {
                          if (!notVerified) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.error.withAlpha(120),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.mark_email_unread_outlined,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Correo no verificado',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Tu cuenta no ha sido activada. Pulsa el botón para recibir un nuevo enlace de confirmación.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ValueListenableBuilder<bool>(
                                  valueListenable: _resendingEmail,
                                  builder: (context, resending, _) {
                                    return OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: resending
                                          ? null
                                          : _handleResendVerification,
                                      icon: resending
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.send_rounded,
                                              size: 16,
                                            ),
                                      label: Text(
                                        resending
                                            ? 'Reenviando correo...'
                                            : 'Reenviar correo de verificación',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            CustomNavigator.pushFade(
                              context,
                              const GuestHomeScreen(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Entrar como invitado',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
