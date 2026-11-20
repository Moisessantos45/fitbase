import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/payment_provider.dart';
import 'package:fitbase/presentation/providers/subscription_provider.dart';
import 'package:fitbase/presentation/providers/user_provider.dart';
import 'package:fitbase/presentation/screens/user/user_subscriptions_screen.dart';
import 'package:fitbase/presentation/screens/user/user_payments_screen.dart';
import 'package:fitbase/presentation/screens/user/gym_map_screen.dart';
import 'package:fitbase/presentation/widgets/common/gym_detail_modal.dart';
import 'package:fitbase/presentation/widgets/payment/payment_receipt_modal.dart';
import 'package:fitbase/presentation/widgets/subscription/subscription_qr_modal.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const UserHomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAllData());
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      ref.read(userProvider.notifier).getUser().catchError((_) => ref.read(userProvider).value!),
      ref
          .read(userSubscriptionsProvider.notifier)
          .getMySubscriptions()
          .catchError((_) => <SubscriptionItem>[]),
      ref
          .read(userPaymentsProvider.notifier)
          .getMyPayments()
          .catchError((_) => <PaymentItem>[]),
      ref
          .read(publicGymsProvider.notifier)
          .fetchGyms()
          .catchError((_) => ref.read(publicGymsProvider).value ?? []),
    ]);
  }

  int _daysRemaining(String endDateStr) {
    final parsed = DateTime.tryParse(endDateStr);
    if (parsed == null) return 0;
    final diff = parsed.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);
    final paymentsAsync = ref.watch(userPaymentsProvider);
    final gymsAsync = ref.watch(publicGymsProvider);

    final userName = user != null && user.firstName.isNotEmpty
        ? 'Hola, ${user.firstName} 👋'
        : 'Hola deportista 👋';

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

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadAllData,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
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
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                              ),
                              child: ClipOval(
                                child: user != null && user.avatarUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: user.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(Icons.person,
                                        color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  subscriptionsAsync.when(
                                    data: (subs) {
                                      final active = subs.any((s) => s.isActive);
                                      return Text(
                                        active
                                            ? 'Membresía Activa • Fitbase'
                                            : 'Sin Membresía Activa',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: active
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                    loading: () => const Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    error: (_, _) => const Text(
                                      'Fitbase Hub',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  subscriptionsAsync.when(
                    data: (subs) {
                      final activeSub = subs.cast<SubscriptionItem?>().firstWhere(
                            (s) => s != null && s.isActive,
                            orElse: () => null,
                          );

                      if (activeSub != null) {
                        return GestureDetector(
                          onTap: () => SubscriptionQrModal.show(context,
                              item: activeSub),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF222904),
                                  AppColors.surface
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: AppColors.primary.withAlpha(140)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activeSub.gymName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_2_rounded,
                                        size: 44,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activeSub.planName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Vence: ${activeSub.endDate}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Toca para ver tu credencial QR.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
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
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_membership_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Comienza tu entrenamiento',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Elige un plan de membresía o pase diario.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                CustomNavigator.pushFade(
                                  context,
                                  const GymMapScreen(isModal: true),
                                );
                              },
                              child: const Text(
                                'Explorar Sedes',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
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
                          CustomNavigator.pushFade(
                            context,
                            const UserSubscriptionsScreen(isModal: true),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionItem(
                        context,
                        icon: Icons.credit_card_rounded,
                        label: 'Pagos',
                        onTap: () {
                          CustomNavigator.pushFade(
                            context,
                            const UserPaymentsScreen(isModal: true),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionItem(
                        context,
                        icon: Icons.map_rounded,
                        label: 'Sedes',
                        onTap: () {
                          CustomNavigator.pushFade(
                            context,
                            const GymMapScreen(isModal: true),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: subscriptionsAsync.when(
                            data: (subs) {
                              final activeList =
                                  subs.where((s) => s.isActive).toList();
                              final days = activeList.isNotEmpty
                                  ? _daysRemaining(activeList.first.endDate)
                                  : 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.card_membership_rounded,
                                      color: AppColors.primary, size: 22),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${activeList.length}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeList.isNotEmpty
                                        ? 'Activas ($days d rest.)'
                                        : 'Membresías activas',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox(
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                            error: (_, _) => const Text('—'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: paymentsAsync.when(
                            data: (payments) {
                              final totalPaid = payments
                                  .where((p) => p.isPaid)
                                  .fold<double>(0.0, (a, p) => a + p.amount);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.receipt_long_rounded,
                                      color: AppColors.success, size: 22),
                                  const SizedBox(height: 10),
                                  Text(
                                    '\$${totalPaid.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${payments.length} pagos realizados',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox(
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                            error: (_, _) => const Text('—'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  paymentsAsync.when(
                    data: (payments) {
                      if (payments.isEmpty) return const SizedBox.shrink();
                      final recent = payments.take(3).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Últimos Pagos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (widget.onNavigateTab != null) {
                                    widget.onNavigateTab!(3);
                                  } else {
                                    CustomNavigator.pushFade(
                                      context,
                                      const UserPaymentsScreen(isModal: true),
                                    );
                                  }
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
                          ...recent.map((p) => GestureDetector(
                                onTap: () =>
                                    PaymentReceiptModal.show(context, p),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.gymName.isNotEmpty
                                                  ? p.gymName
                                                  : 'Pago #${p.id}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${p.paymentMethodName} • ${p.paymentDate}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${p.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  gymsAsync.when(
                    data: (gyms) {
                      if (gyms.isEmpty) return const SizedBox.shrink();
                      final topGyms = gyms.take(3).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sedes Disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (widget.onNavigateTab != null) {
                                    widget.onNavigateTab!(1);
                                  } else {
                                    CustomNavigator.pushFade(
                                      context,
                                      const GymMapScreen(isModal: true),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Explorar mapa',
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
                          ...topGyms.map((gym) => GestureDetector(
                                onTap: () => GymDetailModal.show(
                                  context,
                                  gym: gym,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
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
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              gym.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              gym.address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
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
      ),
    );
  }
}
