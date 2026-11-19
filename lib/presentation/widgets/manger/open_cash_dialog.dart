import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class OpenCashDialog extends ConsumerStatefulWidget {
  final int gymId;
  final VoidCallback onOpened;

  const OpenCashDialog({
    super.key,
    required this.gymId,
    required this.onOpened,
  });

  static Future<void> show(
    BuildContext context, {
    required int gymId,
    required VoidCallback onOpened,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: OpenCashDialog(
          gymId: gymId,
          onOpened: onOpened,
        ),
      ),
    );
  }

  @override
  ConsumerState<OpenCashDialog> createState() => _OpenCashDialogState();
}

class _OpenCashDialogState extends ConsumerState<OpenCashDialog> {
  final _amountController = TextEditingController();
  final _loading = ValueNotifier<bool>(false);
  final _errorMessage = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _amountController.dispose();
    _loading.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  Future<void> _handleOpen() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount < 0) {
      _errorMessage.value = 'Ingresa un monto inicial válido (mayor o igual a 0).';
      return;
    }

    _loading.value = true;
    _errorMessage.value = null;

    try {
      await ref.read(cashRegisterProvider.notifier).openRegister(
            gymId: widget.gymId,
            openCash: amount,
          );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onOpened();
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
              Icons.point_of_sale_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Apertura de Caja',
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
            const Text(
              'Para operar en mostrador y registrar cobros en efectivo, es obligatorio abrir tu turno indicando el fondo inicial en caja.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'Monto Inicial en Efectivo (\$)',
              hintText: 'Ej. 500.00',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        ValueListenableBuilder<bool>(
          valueListenable: _loading,
          builder: (context, loading, _) {
            return CustomButton(
              text: loading ? 'Abriendo Turno...' : 'Abrir Caja e Iniciar Turno',
              onPressed: loading ? null : _handleOpen,
            );
          },
        ),
      ],
    );
  }
}

