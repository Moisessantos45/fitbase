import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/plan_card.dart';

class UserPlansScreen extends StatelessWidget {
  final bool isModal;

  const UserPlansScreen({super.key, this.isModal = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isModal
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Planes Disponibles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Mejora tu entrenamiento!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Elige el plan que mejor se adapte a tu objetivo deportivo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PlanCard(
            title: 'Plan Básico',
            price: '\$299',
            period: '/mes',
            description: 'Ideal para iniciar. Acceso a pesas y cardio de lunes a viernes.',
            benefits: const [
              'Área de pesas y cardio libre',
              'Vestidores estándar y regaderas',
              'Acceso de 06:00 a 22:00',
            ],
            onSelect: () => _confirmPlan(context, 'Plan Básico'),
          ),
          const SizedBox(height: 18),
          PlanCard(
            title: 'Plan Black Pro',
            price: '\$499',
            period: '/mes',
            description: 'Nuestra membresía más elegida. Acceso multisede 24/7 y todas las clases.',
            isPopular: true,
            benefits: const [
              'Acceso ilimitado 24/7 a todas las sucursales',
              'Clases grupales: Yoga, Pilates, Spinning y Box',
              'Zona de vapor y sauna',
              '1 Pase de invitado semanal gratis',
            ],
            onSelect: () => _confirmPlan(context, 'Plan Black Pro'),
          ),
          const SizedBox(height: 18),
          PlanCard(
            title: 'Plan Anual VIP',
            price: '\$4,990',
            period: '/año',
            description: 'Paga anual y ahorra 2 meses de suscripción. Incluye asesor nutricional.',
            benefits: const [
              'Todos los beneficios del Plan Black Pro',
              'Evaluación física y plan nutricional trimestral',
              'Kit oficial Fitbase gratis',
              'Casillero exclusivo personal',
            ],
            onSelect: () => _confirmPlan(context, 'Plan Anual VIP'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _confirmPlan(BuildContext context, String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionaste: $planName'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }
}
