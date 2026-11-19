import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/payment_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/widgets/payment/payment_receipt_modal.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const AdminPaymentsScreen({super.key, this.isModal = false});

  @override
  ConsumerState<AdminPaymentsScreen> createState() =>
      _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPaymentData());
  }

  Future<void> _loadPaymentData() async {
    final gym = ref.read(gymProvider).value ??
        await ref.read(gymProvider.notifier).getMyGym();
    if (gym != null && gym.id > 0) {
      try {
        await ref.read(gymRevenueProvider.notifier).getGymRevenue(gym.id);
      } catch (_) {}
      try {
        await ref.read(gymPaymentsProvider.notifier).getGymPayments(gym.id);
      } catch (_) {}
    }
  }

  void _openManualPaymentModal(BuildContext context, int gymId) {
    final amountCtrl = TextEditingController();
    final subIdCtrl = TextEditingController();
    final dayPassIdCtrl = TextEditingController();
    final methodNotifier = ValueNotifier<int>(1);
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
                'Registrar Cobro en Mostrador',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Monto a Cobrar (\$)',
                hintText: 'Ej. 499.00',
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              const Text(
                'Método de Pago',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<int>(
                valueListenable: methodNotifier,
                builder: (context, method, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Efectivo'),
                          selected: method == 1,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: method == 1
                                ? AppColors.onPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => methodNotifier.value = 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Tarjeta Física'),
                          selected: method == 2,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: method == 2
                                ? AppColors.onPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => methodNotifier.value = 2,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'ID de Suscripción (opcional)',
                hintText: 'Ej. 12',
                controller: subIdCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'ID de Pase Diario (opcional)',
                hintText: 'Ej. 5',
                controller: dayPassIdCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: isSaving,
                builder: (context, saving, _) {
                  return CustomButton(
                    text: saving ? 'Procesando...' : 'Confirmar Cobro',
                    onPressed: saving
                        ? null
                        : () async {
                            final amount =
                                double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                            if (amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.error,
                                  content: Text('Ingresa un monto válido.'),
                                ),
                              );
                              return;
                            }

                            final subId =
                                int.tryParse(subIdCtrl.text.trim());
                            final dayPassId =
                                int.tryParse(dayPassIdCtrl.text.trim());

                            isSaving.value = true;
                            try {
                              final msg = await ref
                                  .read(gymPaymentsProvider.notifier)
                                  .registerCashPayment(
                                    gymId: gymId,
                                    paymentMethodId: methodNotifier.value,
                                    amount: amount,
                                    subscriptionId: subId,
                                    dayPassId: dayPassId,
                                  );
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                              await _loadPaymentData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.success,
                                    content: Text(msg),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    content: Text('Error al cobrar: $e'),
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

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(gymProvider).value;
    final revenueAsync = ref.watch(gymRevenueProvider);
    final paymentsAsync = ref.watch(gymPaymentsProvider);
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
          'Libro Mayor de Pagos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded, color: AppColors.primary),
            onPressed: () => _openManualPaymentModal(context, gymId),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadPaymentData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263300), AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withAlpha(120)),
              ),
              child: revenueAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recaudación de la Sede',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Panel contable reservado para el propietario',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                data: (revenue) {
                  final totalRev = revenue?.totalRevenue ?? 0.0;
                  final totalTx = revenue?.totalTransactions ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recaudación Total Acumulada',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'EN VIVO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${totalRev.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$totalTx pagos y transacciones registradas',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transacciones de la Sede',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add,
                      size: 16, color: AppColors.primary),
                  label: const Text(
                    'Cobrar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _openManualPaymentModal(context, gymId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            paymentsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error al cargar pagos: $err',
                      style: const TextStyle(color: AppColors.error)),
                ),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay transacciones registradas en esta sede.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: payments.map((p) => _buildPaymentCard(p)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentItem payment) {
    return GestureDetector(
      onTap: () => PaymentReceiptModal.show(context, payment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recibo #${payment.id}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.paymentMethodName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.paymentDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+\$${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: payment.isPaid
                        ? AppColors.success.withAlpha(25)
                        : AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    payment.paymentStatusName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: payment.isPaid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
