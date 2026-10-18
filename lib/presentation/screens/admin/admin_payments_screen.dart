import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';

class AdminPaymentsScreen extends StatefulWidget {
  final bool isModal;

  const AdminPaymentsScreen({super.key, this.isModal = false});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final List<Map<String, dynamic>> _payments = [
    {
      'id': 'PAY-9812',
      'user': 'Carlos Mendoza',
      'concept': 'Plan Black Pro Mensual',
      'amount': '\$499.00',
      'date': 'Hoy, 10:24 AM',
      'method': 'Tarjeta Mastercard',
      'status': 'Completado',
    },
    {
      'id': 'PAY-9811',
      'user': 'Lucía Morales',
      'concept': 'Plan Anual VIP',
      'amount': '\$4,990.00',
      'date': 'Ayer, 16:45 PM',
      'method': 'Transferencia SPEI',
      'status': 'Completado',
    },
    {
      'id': 'PAY-9810',
      'user': 'Valeria Gómez',
      'concept': 'Plan Black Pro Mensual',
      'amount': '\$499.00',
      'date': '10 Oct 2026',
      'method': 'Efectivo en Mostrador',
      'status': 'Completado',
    },
    {
      'id': 'PAY-9809',
      'user': 'Rodrigo Sánchez',
      'concept': 'Plan Básico Mensual',
      'amount': '\$299.00',
      'date': '09 Oct 2026',
      'method': 'Tarjeta Visa',
      'status': 'Rechazado',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Gestión de Pagos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded, color: AppColors.primary),
            onPressed: () => _openNewPaymentModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF263300), AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primary.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresos del Mes',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$142,850.00 MXN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '+14.2% respecto al mes anterior',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Registrar Pago Manual',
                  icon: Icons.add,
                  onPressed: () => _openNewPaymentModal(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Historial de Transacciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._payments.map((p) => _buildPaymentItem(p)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> item) {
    final isSuccess = item['status'] == 'Completado';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['user'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['concept'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['amount'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item['method']} • ${item['date']}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              TextButton(
                onPressed: () => _openModifyPaymentModal(context, item),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                ),
                child: const Text(
                  'Modificar',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openNewPaymentModal(BuildContext context) {
    final userController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Registrar Pago de Membresía',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Usuario / Miembro',
                controller: userController,
                hintText: 'Nombre o correo del usuario',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Monto Recibido (\$)',
                controller: amountController,
                hintText: '499.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Confirmar Registro de Pago',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pago registrado exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openModifyPaymentModal(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Modificar Pago ${item['id']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Usuario: ${item['user']} • ${item['amount']}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
              title: const Text(
                'Marcar como Completado',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.replay_rounded,
                color: AppColors.warning,
              ),
              title: const Text(
                'Reembolsar Pago',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
              ),
              title: const Text(
                'Anular Transacción',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
