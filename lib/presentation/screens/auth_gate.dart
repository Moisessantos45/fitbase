import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/screens/auth/login_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_main_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_profile_screen.dart';
import 'package:fitbase/presentation/screens/manger/manager_profile_screen.dart';
import 'package:fitbase/presentation/screens/user/user_main_screen.dart';
import 'package:fitbase/presentation/screens/user/user_profile_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final _isCheckingStoredSession = ValueNotifier<bool>(true);
  final _hasStoredSession = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  @override
  void dispose() {
    _isCheckingStoredSession.dispose();
    _hasStoredSession.dispose();
    super.dispose();
  }

  Future<void> _checkInitialSession() async {
    final isAuth = ref.read(authProvider).value?.authenticated ?? false;
    if (isAuth) {
      _hasStoredSession.value = true;
      _isCheckingStoredSession.value = false;
      return;
    }

    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refresh_token');
    final hasToken = refreshToken != null && refreshToken.isNotEmpty;

    if (!hasToken) {
      _hasStoredSession.value = false;
      _isCheckingStoredSession.value = false;
      return;
    }

    _hasStoredSession.value = true;
    _isCheckingStoredSession.value = true;

    try {
      await ref.read(authProvider.notifier).getSession();
    } finally {
      if (mounted) {
        _isCheckingStoredSession.value = false;
      }
    }
  }

  Widget _buildLoadingSplash() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FITBASE',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Iniciando sesión...',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: _isCheckingStoredSession,
      builder: (context, checking, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _hasStoredSession,
          builder: (context, hasSession, _) {
            if (checking && hasSession) {
              return _buildLoadingSplash();
            }

            return authAsync.when(
              data: (state) {
                if (!state.authenticated) {
                  return const LoginScreen();
                }

                final user = state.authData;
                final roleId = user?.roleId ?? 0;
                final isProfileComplete = user?.fullProfile ?? false;

                if (!isProfileComplete) {
                  if (roleId == 2) {
                    return const AdminProfileScreen();
                  }
                  if (roleId == 3) {
                    return const ManagerProfileScreen();
                  }
                  return const UserProfileScreen();
                }

                if (roleId == 2 || roleId == 3) {
                  return const AdminMainScreen();
                }

                return const UserMainScreen();
              },
              loading: () =>
                  hasSession ? _buildLoadingSplash() : const LoginScreen(),
              error: (_, _) => const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
