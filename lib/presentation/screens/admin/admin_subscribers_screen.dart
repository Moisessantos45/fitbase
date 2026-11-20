import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/subscription_provider.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/widgets/subscription/client_360_modal.dart';

class AdminSubscribersScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const AdminSubscribersScreen({super.key, this.isModal = false});

  @override
  ConsumerState<AdminSubscribersScreen> createState() =>
      _AdminSubscribersScreenState();
}

class _AdminSubscribersScreenState
    extends ConsumerState<AdminSubscribersScreen> {
  final _searchController = TextEditingController();
  final _statusFilter = ValueNotifier<int?>(null);
  final _cancellingId = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSubscribers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statusFilter.dispose();
    _cancellingId.dispose();
    super.dispose();
  }

  Future<void> _loadSubscribers() async {
    final gym = ref.read(gymProvider).value ??
        await ref.read(gymProvider.notifier).getMyGym();
    if (gym != null && gym.id > 0) {
      await ref.read(gymSubscriptionsProvider.notifier).getGymSubscriptions(
            gym.id,
            statusId: _statusFilter.value,
          );
    }
  }

  Future<void> _handleCancelSubscription(
      int gymId, SubscriptionItem sub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cancelar Suscripción?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Deseas dar de baja la membresía de ${sub.userFullName}? Su estado cambiará a Inactivo.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar',
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

    _cancellingId.value = sub.id;
    try {
      await ref
          .read(gymSubscriptionsProvider.notifier)
          .cancelGymSubscription(
            gymId: gymId,
            subscriptionId: sub.id,
            currentStatusId: _statusFilter.value,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Suscripción cancelada exitosamente.'),
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
    final gym = ref.watch(gymProvider).value;
    final subscribersAsync = ref.watch(gymSubscriptionsProvider);
    final gymId = gym?.id ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Socios y Suscripciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CustomTextField(
              label: '',
              hintText: 'Filtrar por nombre, correo o plan...',
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ValueListenableBuilder<int?>(
              valueListenable: _statusFilter,
              builder: (context, filter, _) {
                return Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: filter == null,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: filter == null
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        _statusFilter.value = null;
                        _loadSubscribers();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Activos'),
                      selected: filter == 1,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: filter == 1
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        _statusFilter.value = 1;
                        _loadSubscribers();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Inactivos'),
                      selected: filter == 2,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: filter == 2
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        _statusFilter.value = 2;
                        _loadSubscribers();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadSubscribers,
              child: subscribersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error al cargar socios: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (subs) {
                  final query = _searchController.text.trim().toLowerCase();
                  final searched = query.isEmpty
                      ? subs
                      : subs.where((s) {
                          return s.userFullName
                                  .toLowerCase()
                                  .contains(query) ||
                              s.userEmail.toLowerCase().contains(query) ||
                              s.planName.toLowerCase().contains(query);
                        }).toList();

                  final Map<int, SubscriptionItem> uniqueByUser = {};
                  for (final sub in searched) {
                    final key = sub.userId > 0 ? sub.userId : sub.id;
                    final existing = uniqueByUser[key];
                    if (existing == null) {
                      uniqueByUser[key] = sub;
                    } else {
                      if (sub.isActive && !existing.isActive) {
                        uniqueByUser[key] = sub;
                      } else if (sub.id > existing.id &&
                          (sub.isActive == existing.isActive)) {
                        uniqueByUser[key] = sub;
                      }
                    }
                  }
                  final filtered = uniqueByUser.values.toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No se encontraron socios o suscripciones.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final sub = filtered[index];
                      return _buildSubscriberCard(sub, gymId);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberCard(SubscriptionItem sub, int gymId) {
    final isAct = sub.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAct ? AppColors.primary.withAlpha(60) : AppColors.border,
        ),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAct ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sub.userFullName.isNotEmpty
                            ? sub.userFullName.substring(0, 1).toUpperCase()
                            : 'S',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAct
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.userFullName.isNotEmpty
                            ? sub.userFullName
                            : 'Usuario #${sub.userId}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub.userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAct
                      ? AppColors.success.withAlpha(25)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sub.statusName.isNotEmpty ? sub.statusName : 'Inactivo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAct ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan: ${sub.planName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${sub.planPrice.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Vigencia: ${sub.startDate} al ${sub.endDate}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.person_search_rounded,
                      size: 16, color: AppColors.primary),
                  label: const Text(
                    'Ficha 360°',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Client360Modal.show(
                      context,
                      gymId: gymId,
                      userId: sub.userId,
                    );
                  },
                ),
              ),
              if (isAct) ...[
                const SizedBox(width: 8),
                ValueListenableBuilder<int?>(
                  valueListenable: _cancellingId,
                  builder: (context, cancelling, _) {
                    final isThis = cancelling == sub.id;
                    return IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withAlpha(25),
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: isThis
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined,
                              color: AppColors.error, size: 20),
                      onPressed: isThis
                          ? null
                          : () => _handleCancelSubscription(gymId, sub),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
