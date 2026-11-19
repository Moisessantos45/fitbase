import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/payment_model.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';

class PaymentReceiptModal extends StatelessWidget {
  final PaymentItem payment;

  const PaymentReceiptModal({super.key, required this.payment});

  static Future<void> show(BuildContext context, PaymentItem payment) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentReceiptModal(payment: payment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Comprobante Digital de Pago',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibo Folio #${payment.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${payment.amount.toStringAsFixed(2)} MXN',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                _buildReceiptRow('Sede / Gimnasio', payment.gymName),
                _buildReceiptRow('Método de Pago', payment.paymentMethodName),
                _buildReceiptRow('Estado', payment.paymentStatusName),
                _buildReceiptRow('Fecha', payment.paymentDate),
                if (payment.subscriptionId != null)
                  _buildReceiptRow(
                      'Suscripción ID', '#${payment.subscriptionId}'),
                if (payment.dayPassId != null)
                  _buildReceiptRow('Pase Diario ID', '#${payment.dayPassId}'),
                if (payment.cashRegisterId != null)
                  _buildReceiptRow('Caja Turno ID', '#${payment.cashRegisterId}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Cerrar Comprobante',
            isSecondary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

