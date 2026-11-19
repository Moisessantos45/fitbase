import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/presentation/providers/payment_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/screens/guest/guest_ticket_screen.dart';

class GuestPurchaseScreen extends ConsumerStatefulWidget {
  final PlanModel plan;
  final int gymId;

  const GuestPurchaseScreen({
    super.key,
    required this.plan,
    required this.gymId,
  });

  @override
  ConsumerState<GuestPurchaseScreen> createState() => _GuestPurchaseScreenState();
}

class _GuestPurchaseScreenState extends ConsumerState<GuestPurchaseScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _visitDateController = TextEditingController(text: '2026-11-10');
  final _loading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _visitDateController.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase({required bool isStripe}) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.error, content: Text('Por favor completa los campos obligatorios')),
      );
      return;
    }

    _loading.value = true;
    try {
      final ticket = await ref.read(paymentProvider.notifier).purchaseGuestDayPass(
        gymId: widget.gymId,
        planId: widget.plan.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        visitDate: _visitDateController.text.trim(),
        payWithStripe: isStripe,
      );
      
      if (mounted) {
        _loading.value = false;
        if (isStripe) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Simulación Stripe', style: TextStyle(color: AppColors.textPrimary)),
              content: Text(
                'El pago de \$${widget.plan.finalPrice.toStringAsFixed(2)} se procesó correctamente.\n\nEn la versión real, serías redirigido a Stripe y luego regresarías aquí.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Entendido', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GuestTicketScreen(
                slug: ticket.slug,
                fullName: ticket.fullName,
                visitDate: ticket.visitDate,
                isPaid: ticket.isPaid,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Comprar Pase Diario', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('\$${widget.plan.finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(widget.plan.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tus Datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nombre Completo *', controller: _nameController, hintText: 'Ej. Juan Pérez'),
            const SizedBox(height: 12),
            CustomTextField(label: 'Correo Electrónico *', controller: _emailController, hintText: 'correo@ejemplo.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            CustomTextField(label: 'Teléfono', controller: _phoneController, hintText: '55 1234 5678', keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            const Text('Fecha de Visita', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            CustomTextField(label: 'Fecha (YYYY-MM-DD)', controller: _visitDateController),
            const SizedBox(height: 32),
            ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (context, loading, _) {
                return Column(
                  children: [
                    CustomButton(
                      text: loading ? 'Procesando...' : 'Pagar con Tarjeta (Stripe)',
                      onPressed: loading ? () {} : () => _handlePurchase(isStripe: true),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: loading ? 'Procesando...' : 'Pagar en Recepción',
                      isSecondary: true,
                      onPressed: loading ? () {} : () => _handlePurchase(isStripe: false),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}