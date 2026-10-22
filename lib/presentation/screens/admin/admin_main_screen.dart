import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';
import 'package:fitbase/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_subscribers_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_managers_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_plans_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_payments_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_gym_edit_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboardScreen(
        onNavigateTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const AdminSubscribersScreen(),
      const AdminManagersScreen(),
      const AdminPlansScreen(),
      const AdminPaymentsScreen(),
      const AdminGymEditScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    if (authState == null || !authState.authenticated) {
      return const AuthGate();
    }
    final roleId = authState.authData?.roleId ?? 0;
    if (roleId != 2 && roleId != 3) {
      return const AuthGate();
    }
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.dashboard_rounded, 'Panel'),
                  _buildNavItem(1, Icons.group_rounded, 'Socios'),
                  _buildNavItem(2, Icons.badge_rounded, 'Staff'),
                  _buildNavItem(3, Icons.layers_rounded, 'Planes'),
                  _buildNavItem(4, Icons.payments_rounded, 'Pagos'),
                  _buildNavItem(5, Icons.storefront_rounded, 'Sede'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 6,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
