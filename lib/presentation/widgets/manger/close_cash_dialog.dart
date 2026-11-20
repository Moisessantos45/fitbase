import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class CloseCashDialog extends ConsumerStatefulWidget {
  final Future<void> Function() onClosed;

  const CloseCashDialog({
    super.key,
    required this.onClosed,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onClosed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseCashDialog(onClosed: onClosed),
    );
  }

  @override
  ConsumerState<CloseCashDialog> createState() => _CloseCashDialogState();
}

class _CloseCashDialogState extends ConsumerState<CloseCashDialog> {
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

  Future<void> _handleClose() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount < 0) {
      _errorMessage.value = 'Ingresa el monto final contado en caja.';
      return;
    }

    _loading.value = true;
    _errorMessage.value = null;

    try {
      await ref.read(cashRegisterProvider.notifier).closeRegister(closeCash: amount);
      if (mounted) {
        Navigator.of(context).pop();
        await widget.onClosed();
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
              color: AppColors.warning.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: AppColors.warning,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Arqueo y Cierre de Caja',
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
              'Antes de cerrar sesión o finalizar tu turno, debes ingresar el efectivo total existente en el cajón físico.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'Efectivo Contado al Cierre (\$)',
              hintText: 'Ej. 1250.00',
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
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<bool>(
                valueListenable: _loading,
                builder: (context, loading, _) {
                  return CustomButton(
                    text: loading ? 'Cerrando...' : 'Cerrar Turno',
                    onPressed: loading ? null : _handleClose,
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

