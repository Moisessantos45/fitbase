import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/presentation/providers/subscription_provider.dart';
import 'package:fitbase/presentation/screens/user/gym_map_screen.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/subscription/subscription_qr_modal.dart';

class UserSubscriptionsScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const UserSubscriptionsScreen({super.key, this.isModal = false});

  @override
  ConsumerState<UserSubscriptionsScreen> createState() =>
      _UserSubscriptionsScreenState();
}

class _UserSubscriptionsScreenState
    extends ConsumerState<UserSubscriptionsScreen> {
  final _cancellingId = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userSubscriptionsProvider.notifier).getMySubscriptions();
    });
  }

  @override
  void dispose() {
    _cancellingId.dispose();
    super.dispose();
  }

  Future<void> _handleCancelSubscription(SubscriptionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cancelar Membresía?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de cancelar "${item.planName}"? Perderás el acceso una vez vencido el periodo actual (${item.endDate}).',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mantener Membresía',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, Cancelar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _cancellingId.value = item.id;
    try {
      await ref
          .read(userSubscriptionsProvider.notifier)
          .cancelSubscription(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Membresía cancelada correctamente.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error al cancelar: $e'),
          ),
        );
      }
    } finally {
      _cancellingId.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Mis Suscripciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: AppColors.primary),
            onPressed: () {
              CustomNavigator.pushFade(
                context,
                const GymMapScreen(isModal: true),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(userSubscriptionsProvider.notifier).getMySubscriptions(),
        child: subscriptionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text('Error al cargar suscripciones: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () => ref
                        .read(userSubscriptionsProvider.notifier)
                        .getMySubscriptions(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (subs) {
            final Map<String, SubscriptionItem> uniqueSubsMap = {};
            for (final s in subs) {
              final key = s.slug.isNotEmpty
                  ? s.slug
                  : (s.id > 0
                      ? 'id_${s.id}'
                      : '${s.gymId}_${s.planId}_${s.startDate}_${s.endDate}');
              uniqueSubsMap[key] = s;
            }
            final uniqueSubs = uniqueSubsMap.values.toList();

            final rawActive = uniqueSubs.where((s) => s.isActive).toList();
            final rawPast = uniqueSubs.where((s) => !s.isActive).toList();

            final Map<int, SubscriptionItem> activeByGym = {};
            for (final act in rawActive) {
              final existing = activeByGym[act.gymId];
              if (existing == null || act.id > existing.id) {
                activeByGym[act.gymId] = act;
              }
            }
            final activeSubs = activeByGym.values.toList();

            final Map<String, SubscriptionItem> pastMap = {};
            for (final past in rawPast) {
              final isAlreadyActive = activeSubs.any((a) =>
                  (a.id > 0 && a.id == past.id) ||
                  (a.slug.isNotEmpty && a.slug == past.slug));
              if (!isAlreadyActive) {
                final key = past.slug.isNotEmpty
                    ? past.slug
                    : (past.id > 0
                        ? 'id_${past.id}'
                        : '${past.gymId}_${past.planId}_${past.startDate}_${past.endDate}');
                pastMap[key] = past;
              }
            }
            final pastSubs = pastMap.values.toList();

            if (uniqueSubs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.card_membership_rounded,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aún no tienes membresías activas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explora las sedes Fitbase en el mapa para consultar sus planes y comenzar a entrenar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Explorar Sedes en el Mapa',
                        onPressed: () {
                          CustomNavigator.pushFade(
                            context,
                            const GymMapScreen(isModal: true),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                if (activeSubs.isNotEmpty) ...[
                  const Text(
                    'Membresía Activa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...activeSubs.map((sub) => _buildActiveSubscriptionCard(sub)),
                  const SizedBox(height: 24),
                ],
                if (pastSubs.isNotEmpty) ...[
                  const Text(
                    'Historial de Membresías Pasadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pastSubs.map((sub) => _buildPastSubscriptionTile(sub)),
                ],
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(SubscriptionItem sub) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232B03), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'PLAN ACTIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              Text(
                '\$${sub.planPrice.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sub.planName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub.gymName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Vigencia: ${sub.startDate} al ${sub.endDate}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (sub.autoRenew) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.autorenew_rounded,
                    size: 14, color: AppColors.success),
                SizedBox(width: 6),
                Text(
                  'Autorenovación activa',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ver Credencial QR',
                  icon: Icons.qr_code_rounded,
                  onPressed: () =>
                      SubscriptionQrModal.show(context, item: sub),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<int?>(
                valueListenable: _cancellingId,
                builder: (context, cancelling, _) {
                  final isThis = cancelling == sub.id;
                  return IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withAlpha(25),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: isThis
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : const Icon(Icons.cancel_outlined,
                            color: AppColors.error),
                    onPressed: isThis
                        ? null
                        : () => _handleCancelSubscription(sub),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastSubscriptionTile(SubscriptionItem sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.planName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sub.gymName} • \$${sub.planPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Finalizó: ${sub.endDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sub.statusName.isNotEmpty ? sub.statusName : 'Inactivo',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
