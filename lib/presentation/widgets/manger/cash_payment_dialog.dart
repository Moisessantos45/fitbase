import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/daypass_model.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/providers/daypass_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class CashPaymentDialog extends ConsumerStatefulWidget {
  final DayPassModel pass;
  final VoidCallback onPaymentSuccess;

  const CashPaymentDialog({
    super.key,
    required this.pass,
    required this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required DayPassModel pass,
    required VoidCallback onPaymentSuccess,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CashPaymentDialog(
        pass: pass,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  ConsumerState<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends ConsumerState<CashPaymentDialog> {
  final _receivedController = TextEditingController();
  final _selectedMethod = ValueNotifier<int>(1);
  final _changeAmount = ValueNotifier<double>(0.0);
  final _loading = ValueNotifier<bool>(false);
  final _errorMessage = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(() {
      final received = double.tryParse(_receivedController.text) ?? 0.0;
      final change = received - widget.pass.planPrice;
      _changeAmount.value = change > 0 ? change : 0.0;
    });
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _selectedMethod.dispose();
    _changeAmount.dispose();
    _loading.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final currentBox = ref.read(cashRegisterProvider).value;
    if (_selectedMethod.value == 1 && (currentBox == null || !currentBox.isOpen)) {
      _errorMessage.value =
          'Debes tener un turno de caja abierto para cobrar en efectivo.';
      return;
    }

    if (_selectedMethod.value == 1) {
      final received = double.tryParse(_receivedController.text) ?? 0.0;
      if (received < widget.pass.planPrice) {
        _errorMessage.value =
            'El monto recibido no puede ser menor al precio del pase.';
        return;
      }
    }

    _loading.value = true;
    _errorMessage.value = null;

    try {
      final msg = await ref.read(dayPassProvider.notifier).payDayPassAtDesk(
            gymId: widget.pass.gymId,
            dayPassId: widget.pass.id,
            amount: widget.pass.planPrice,
            paymentMethodId: _selectedMethod.value,
          );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPaymentSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(msg),
          ),
        );
      }
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Cobro en Ventanilla',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pass.fullName.isNotEmpty
                        ? widget.pass.fullName
                        : 'Visitante Casual',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plan: ${widget.pass.planName} • Visita: ${widget.pass.visitDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Cobrar:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${widget.pass.planPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: _selectedMethod,
              builder: (context, method, _) {
                return Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.money_rounded, size: 16),
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
                        onSelected: (_) => _selectedMethod.value = 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.credit_card_rounded, size: 16),
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
                        onSelected: (_) => _selectedMethod.value = 2,
                      ),
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: _selectedMethod,
              builder: (context, method, _) {
                if (method != 1) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Efectivo Recibido (\$)',
                      hintText: 'Ej. 200.00',
                      controller: _receivedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<double>(
                      valueListenable: _changeAmount,
                      builder: (context, change, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cambio a devolver:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${change.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: _errorMessage,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<bool>(
                valueListenable: _loading,
                builder: (context, loading, _) {
                  return CustomButton(
                    text: loading ? 'Cobrando...' : 'Confirmar Cobro',
                    onPressed: loading ? null : _processPayment,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

