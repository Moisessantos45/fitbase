import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/plan_provider.dart';
import 'package:fitbase/presentation/providers/subscription_provider.dart';
import 'package:fitbase/presentation/widgets/daypass/guest_daypass_dialog.dart';
import 'package:fitbase/presentation/widgets/subscription/subscribe_dialog.dart';
import 'package:fitbase/presentation/widgets/subscription/subscription_qr_modal.dart';

class GymDetailModal extends ConsumerStatefulWidget {
  final GymModel initialGym;
  final String? distanceText;

  const GymDetailModal({
    super.key,
    required this.initialGym,
    this.distanceText,
  });

  static Future<void> show(
    BuildContext context, {
    required GymModel gym,
    String? distanceText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GymDetailModal(
        initialGym: gym,
        distanceText: distanceText,
      ),
    );
  }

  @override
  ConsumerState<GymDetailModal> createState() => _GymDetailModalState();
}

class _GymDetailModalState extends ConsumerState<GymDetailModal> {
  late final ValueNotifier<GymModel> _gymNotifier;
  final ValueNotifier<bool> _isLoadingDetails = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _gymNotifier = ValueNotifier<GymModel>(widget.initialGym);
    _loadFullDetails();
    Future.microtask(() => _loadPlans());
  }

  @override
  void dispose() {
    _gymNotifier.dispose();
    _isLoadingDetails.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    final isAuth = ref.read(authProvider).value?.authenticated ?? false;
    if (!isAuth) {
      await ref
          .read(publicPlansProvider.notifier)
          .getPlansByGym(widget.initialGym.id);
      return;
    }

    try {
      await ref
          .read(gymEnrollmentProvider.notifier)
          .getEnrollmentPlans(widget.initialGym.id);
    } catch (_) {
      await ref
          .read(publicPlansProvider.notifier)
          .getPlansByGym(widget.initialGym.id);
    }
  }

  Future<void> _handleCancelCurrentSub(ActiveSubscriptionInfo sub) async {
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
          '¿Deseas dar de baja tu membresía "${sub.planName}" en esta sede? Perderás el acceso en cuanto venza el periodo actual (${sub.endDate}).',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mantener',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Dar de Baja',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(userSubscriptionsProvider.notifier)
          .cancelSubscription(sub.id);
      await _loadPlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Membresía cancelada exitosamente.'),
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
    }
  }

  Future<void> _loadFullDetails() async {
    try {
      final detail = await ref
          .read(gymProvider.notifier)
          .getGymDetail(widget.initialGym.id);
      if (detail != null && mounted) {
        _gymNotifier.value = detail;
      }
    } catch (_) {
    } finally {
      if (mounted) {
        _isLoadingDetails.value = false;
      }
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(220),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withAlpha(200),
                ),
                icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ValueListenableBuilder<GymModel>(
        valueListenable: _gymNotifier,
        builder: (context, gym, _) {
          final sortedSchedules = List<GymScheduleItem>.from(gym.schedules)
            ..sort((a, b) {
              final orderA = a.dayOfWeek == 0 ? 7 : a.dayOfWeek;
              final orderB = b.dayOfWeek == 0 ? 7 : b.dayOfWeek;
              return orderA.compareTo(orderB);
            });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            color: AppColors.background,
                            child: gym.backgroundUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: gym.backgroundUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.fitness_center_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (gym.isOpen
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withAlpha(220),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    gym.isOpen
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    gym.isOpen ? 'Abierto' : 'Cerrado',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (widget.distanceText != null &&
                            widget.distanceText!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.navigation_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.distanceText!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      gym.address.isNotEmpty
                          ? gym.address
                          : 'Dirección no disponible',
                    ),
                    if (gym.phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone_outlined, gym.phone),
                    ],
                    if (gym.email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email_outlined, gym.email),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Horarios de Atención',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (sortedSchedules.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedSchedules.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: AppColors.border,
                          ),
                          itemBuilder: (context, index) {
                            final sched = sortedSchedules[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sched.dayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: sched.isClosed
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    sched.formattedHours,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: sched.isClosed
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      const Text(
                        'Horarios no disponibles',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (gym.photos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Instalaciones y Fotos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: gym.photos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final photo = gym.photos[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showImagePreview(context, photo.url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 140,
                                  color: AppColors.background,
                                  child: CachedNetworkImage(
                                    imageUrl: photo.url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.broken_image_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Planes y Membresías',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPlansSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlansSection() {
    final enrollmentAsync = ref.watch(gymEnrollmentProvider);
    final publicAsync = ref.watch(publicPlansProvider);

    final enrollment = enrollmentAsync.value;
    final hasActive = enrollment?.hasActiveSubscription ?? false;
    final activeSub = enrollment?.activeSubscription;

    final List<PlanModel> plans =
        enrollment != null && enrollment.plans.isNotEmpty
            ? enrollment.plans
            : (publicAsync.value ?? const []);

    final isLoading = (enrollmentAsync.isLoading && enrollment == null) &&
        (publicAsync.isLoading && (publicAsync.value?.isEmpty ?? true));

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (plans.isEmpty && !hasActive) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Esta sede aún no cuenta con planes activos publicados.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasActive && activeSub != null) ...[
          _buildActiveSubscriptionBanner(activeSub, plans),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildPlanCard(
              plan,
              hasActiveSubscription: hasActive,
              activeSub: activeSub,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionBanner(
    ActiveSubscriptionInfo sub,
    List<PlanModel> plans,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Membresía Activa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sub.statusName.isNotEmpty ? sub.statusName : 'Activo',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sub.planName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Vigencia: ${sub.startDate} al ${sub.endDate}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (sub.slug.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.qr_code_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      'Carnet QR',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      SubscriptionQrModal.show(
                        context,
                        slug: sub.slug,
                        planName: sub.planName,
                        gymName: widget.initialGym.name,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.autorenew_rounded, size: 16),
                  label: const Text(
                    'Renovar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    final currentPlan = plans.firstWhere(
                      (p) => p.id == sub.planId || p.isCurrent,
                      orElse: () => PlanModel(
                        id: sub.planId,
                        gymId: widget.initialGym.id,
                        name: sub.planName,
                      ),
                    );
                    _openSubscribeDialog(currentPlan);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.error.withAlpha(25),
                  padding: const EdgeInsets.all(10),
                ),
                icon: const Icon(Icons.cancel_outlined,
                    color: AppColors.error, size: 18),
                onPressed: () => _handleCancelCurrentSub(sub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    PlanModel plan, {
    required bool hasActiveSubscription,
    ActiveSubscriptionInfo? activeSub,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isCurrent ? AppColors.primary : AppColors.border,
          width: plan.isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (plan.isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tu Plan Actual',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (plan.planType.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    plan.planType,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${plan.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (plan.discount > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${plan.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Text(
                '/ ${plan.duration} días',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (plan.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            ...plan.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name +
                            (item.description.isNotEmpty
                                ? ' (${item.description})'
                                : ''),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (!(ref.watch(authProvider).value?.authenticated ?? false))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                label: const Text(
                  'Registrar Pase (Sin Cuenta)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _openGuestDayPassDialog(plan),
              ),
            )
          else if (plan.isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.autorenew_rounded, size: 18),
                label: const Text(
                  'Renovar Membresía',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _openSubscribeDialog(plan),
              ),
            )
          else if (hasActiveSubscription)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: null,
                child: const Text(
                  'Ya tienes una membresía activa en esta sede',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.fitness_center_rounded, size: 18),
                label: const Text(
                  'Inscribirme',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _openSubscribeDialog(plan),
              ),
            ),
        ],
      ),
    );
  }

  void _openSubscribeDialog(PlanModel plan) {
    SubscribeDialog.show(context, plan: plan, gymId: widget.initialGym.id);
  }

  void _openGuestDayPassDialog(PlanModel plan) {
    GuestDayPassDialog.show(
      context,
      plan: plan,
      gymId: widget.initialGym.id,
      gymName: widget.initialGym.name,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
