import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/screens/admin/admin_plans_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_subscribers_screen.dart';
import 'package:fitbase/presentation/screens/manger/manager_counter_screen.dart';
import 'package:fitbase/presentation/screens/manger/manager_profile_screen.dart';
import 'package:fitbase/presentation/widgets/manger/open_cash_dialog.dart';

class ManagerMainScreen extends ConsumerStatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  ConsumerState<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends ConsumerState<ManagerMainScreen> {
  int _currentIndex = 0;
  final ValueNotifier<bool> _isCheckingCash = ValueNotifier<bool>(true);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ManagerCounterScreen(),
      const AdminSubscribersScreen(),
      const AdminPlansScreen(),
      const ManagerProfileScreen(),
    ];

    Future.microtask(() async {
      final gym = ref.read(gymProvider).value ??
          await ref.read(gymProvider.notifier).getMyGym();
      final box =
          await ref.read(cashRegisterProvider.notifier).checkCurrent();

      _isCheckingCash.value = false;

      if (mounted && (box == null || !box.isOpen) && gym != null && gym.id > 0) {
        OpenCashDialog.show(
          context,
          gymId: gym.id,
          onOpened: () =>
              ref.read(cashRegisterProvider.notifier).checkCurrent(),
        );
      }
    });
  }

  @override
  void dispose() {
    _isCheckingCash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.point_of_sale_rounded, 'Mostrador'),
                  _buildNavItem(1, Icons.people_alt_rounded, 'Socios'),
                  _buildNavItem(2, Icons.layers_rounded, 'Planes'),
                  _buildNavItem(3, Icons.badge_rounded, 'Mi Perfil'),
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
          horizontal: isSelected ? 16 : 10,
          vertical: 10,
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
              size: 22,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
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

