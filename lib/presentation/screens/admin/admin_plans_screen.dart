import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/plan_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class AdminPlansScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const AdminPlansScreen({super.key, this.isModal = false});

  @override
  ConsumerState<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends ConsumerState<AdminPlansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPlans());
  }

  Future<void> _loadPlans() async {
    final gym = ref.read(gymProvider).value ??
        await ref.read(gymProvider.notifier).getMyGym();
    if (gym != null && gym.id > 0) {
      await ref.read(adminPlansProvider.notifier).getAllPlans(gym.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(gymProvider).value;
    final plansAsync = ref.watch(adminPlansProvider);

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
          'Catálogo de Planes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            onPressed: () => _openCreatePlanDialog(context, gym?.id ?? 0),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadPlans,
        child: plansAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar planes: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPlans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (plans) {
            if (plans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.layers_clear_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No tienes planes registrados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea las membresías y pases de visita que ofrecerás a tus clientes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Crear Primer Plan',
                        onPressed: () =>
                            _openCreatePlanDialog(context, gym?.id ?? 0),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${plans.length} Planes Registrados',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Crear Plan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () =>
                          _openCreatePlanDialog(context, gym?.id ?? 0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...plans.map((plan) => _buildAdminPlanCard(plan, gym?.id ?? 0)),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminPlanCard(PlanModel plan, int gymId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.active ? AppColors.primary.withAlpha(80) : AppColors.border,
          width: plan.active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.planType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: plan.active,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  await ref.read(adminPlansProvider.notifier).togglePlanActive(
                        gymId: gymId,
                        planId: plan.id,
                        active: val,
                      );
                },
              ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
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
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${plan.discount.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${plan.duration} días',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beneficios (${plan.items.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () => _openAddBenefitDialog(context, gymId, plan.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
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
                              ? ' - ${item.description}'
                              : ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: () => ref
                        .read(adminPlansProvider.notifier)
                        .deletePlanItem(
                          gymId: gymId,
                          planId: plan.id,
                          itemId: item.id,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddBenefitDialog(BuildContext context, int gymId, int planId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Agregar Beneficio',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Nombre del Beneficio',
              hintText: 'Ej. Acceso a regaderas',
              controller: nameCtrl,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Detalle (opcional)',
              hintText: 'Ej. Incluye agua caliente y lockers',
              controller: descCtrl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              await ref.read(adminPlansProvider.notifier).addPlanItem(
                    gymId: gymId,
                    planId: planId,
                    name: name,
                    description: descCtrl.text.trim(),
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _openCreatePlanDialog(BuildContext context, int gymId) {
    if (gymId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Primero debes registrar los datos de tu gimnasio.'),
        ),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '0');
    final durationCtrl = TextEditingController(text: '30');
    final maxVisitsCtrl = TextEditingController();

    final planTypeNotifier = ValueNotifier<String>('Mensual');
    final benefitsNotifier = ValueNotifier<List<PlanItemModel>>([]);
    final isSaving = ValueNotifier<bool>(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nuevo Plan de Membresía',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre del Plan',
                hintText: 'Ej. Membresía Black',
                controller: nameCtrl,
              ),
              const SizedBox(height: 12),
              const Text(
                'Modalidad / Tipo de Plan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<String>(
                valueListenable: planTypeNotifier,
                builder: (context, currentType, _) {
                  return Wrap(
                    spacing: 8,
                    children: [
                      'Mensual',
                      'Anual',
                      'Pase de Visita',
                      'Personalizado',
                    ].map((type) {
                      final selected = type == currentType;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceLight,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.onPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          planTypeNotifier.value = type;
                          if (type == 'Pase de Visita') {
                            durationCtrl.text = '1';
                            maxVisitsCtrl.text = '1';
                          } else if (type == 'Anual') {
                            durationCtrl.text = '365';
                            maxVisitsCtrl.clear();
                          } else if (type == 'Mensual') {
                            durationCtrl.text = '30';
                            maxVisitsCtrl.clear();
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Precio Base (\$)',
                      hintText: '499.00',
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Descuento (%)',
                      hintText: '0',
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Duración (días)',
                      hintText: '30',
                      controller: durationCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Límite Visitas (opcional)',
                      hintText: 'Vacío = Ilimitado',
                      controller: maxVisitsCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Descripción del Plan',
                hintText: 'Explica los beneficios y características...',
                controller: descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Beneficios Incluidos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar Beneficio'),
                    onPressed: () {
                      final itemCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Nuevo Beneficio',
                              style: TextStyle(color: AppColors.textPrimary)),
                          content: CustomTextField(
                            label: 'Beneficio',
                            hintText: 'Ej. Acceso a clases ilimitadas',
                            controller: itemCtrl,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              onPressed: () {
                                final text = itemCtrl.text.trim();
                                if (text.isNotEmpty) {
                                  benefitsNotifier.value = [
                                    ...benefitsNotifier.value,
                                    PlanItemModel(name: text),
                                  ];
                                }
                                Navigator.of(dCtx).pop();
                              },
                              child: const Text('Agregar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              ValueListenableBuilder<List<PlanItemModel>>(
                valueListenable: benefitsNotifier,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return const Text(
                      'No has añadido beneficios a este plan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: isSaving,
                builder: (context, saving, _) {
                  return CustomButton(
                    text: saving ? 'Creando Plan...' : 'Crear y Publicar Plan',
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final price = double.tryParse(priceCtrl.text) ?? 0.0;
                            final discount =
                                double.tryParse(discountCtrl.text) ?? 0.0;
                            final duration =
                                int.tryParse(durationCtrl.text) ?? 30;
                            final maxVisits =
                                int.tryParse(maxVisitsCtrl.text);

                            if (name.isEmpty || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.error,
                                  content: Text(
                                    'Nombre y precio válido son obligatorios.',
                                  ),
                                ),
                              );
                              return;
                            }

                            isSaving.value = true;
                            try {
                              final payload = CreatePlanPayload(
                                gymId: gymId,
                                name: name,
                                description: descCtrl.text.trim(),
                                price: price,
                                discount: discount,
                                duration: duration,
                                planType: planTypeNotifier.value,
                                maxVisits: maxVisits,
                                items: benefitsNotifier.value,
                              );
                              await ref
                                  .read(adminPlansProvider.notifier)
                                  .createPlan(payload);
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.success,
                                    content: Text(
                                      'Plan creado exitosamente.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    content: Text('Error al crear plan: $e'),
                                  ),
                                );
                              }
                            } finally {
                              isSaving.value = false;
                            }
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
