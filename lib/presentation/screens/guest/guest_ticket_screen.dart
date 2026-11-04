import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';

class GuestTicketScreen extends ConsumerWidget {
  final String slug;
  final String fullName;
  final String visitDate;
  final bool isPaid;

  const GuestTicketScreen({
    super.key,
    required this.slug,
    required this.fullName,
    required this.visitDate,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tu Boleto Digital', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF222904), AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withAlpha(100)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PASE DIARIO',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha de visita: $visitDate',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: slug,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPaid ? AppColors.success.withAlpha(30) : AppColors.warning.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPaid ? 'PAGADO' : 'PENDIENTE DE PAGO EN RECEPCIÓN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Muestra este código QR en el torniquete o recepción para ingresar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Guardar / Compartir',
                  icon: Icons.share_rounded,
                  isSecondary: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de compartir simulada'), backgroundColor: AppColors.primary),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}