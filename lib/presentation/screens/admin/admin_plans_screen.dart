import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/widgets/plan_card.dart';

class AdminPlansScreen extends StatefulWidget {
  final bool isModal;

  const AdminPlansScreen({super.key, this.isModal = false});

  @override
  State<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends State<AdminPlansScreen> {
  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Plan Básico',
      'price': '\$299',
      'period': '/mes',
      'description': 'Acceso a pesas y cardio de lunes a viernes en horario diurno.',
      'benefits': [
        'Área de pesas y cardio',
        'Vestidores estándar',
        'Horario 06:00 a 22:00',
      ],
      'isPopular': false,
    },
    {
      'title': 'Plan Black Pro',
      'price': '\$499',
      'period': '/mes',
      'description': 'Acceso multisede 24/7 y todas las clases grupales.',
      'benefits': [
        'Acceso ilimitado 24/7',
        'Todas las sedes incluidas',
        'Clases grupales ilimitadas',
        'Área de sauna y spa',
        '1 pase de invitado semanal',
      ],
      'isPopular': true,
    },
    {
      'title': 'Plan Anual VIP',
      'price': '\$4,990',
      'period': '/año',
      'description': 'Ahorra 2 meses de costo mensual con todos los beneficios.',
      'benefits': [
        'Todos los beneficios Black Pro',
        'Evaluación y plan nutricional',
        '2 sesiones personal trainer',
        'Kit de bienvenida Fitbase',
      ],
      'isPopular': false,
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Gestión de Planes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
            onPressed: () => _openPlanEditor(context, null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_plans.length} Planes Activos',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: const Text('Crear Plan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                onPressed: () => _openPlanEditor(context, null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._plans.map((plan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: PlanCard(
                title: plan['title'],
                price: plan['price'],
                period: plan['period'],
                description: plan['description'],
                benefits: List<String>.from(plan['benefits']),
                isPopular: plan['isPopular'] ?? false,
                showEditOption: true,
                onEdit: () => _openPlanEditor(context, plan),
                onSelect: () => _openPlanEditor(context, plan),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openPlanEditor(BuildContext context, Map<String, dynamic>? plan) {
    final titleController = TextEditingController(text: plan?['title'] ?? '');
    final priceController = TextEditingController(text: plan?['price'] ?? '');
    final periodController = TextEditingController(text: plan?['period'] ?? '/mes');
    final descController = TextEditingController(text: plan?['description'] ?? '');

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
              Text(
                plan == null ? 'Crear Nuevo Plan' : 'Modificar Plan / Membresía',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre del Plan',
                controller: titleController,
                hintText: 'Ej. Plan Black Pro',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Precio',
                      controller: priceController,
                      hintText: '\$499',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Periodicidad',
                      controller: periodController,
                      hintText: '/mes o /año',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Descripción Breve',
                controller: descController,
                maxLines: 2,
                hintText: 'Descripción de las ventajas del plan...',
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: plan == null ? 'Guardar Nuevo Plan' : 'Actualizar Plan',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(plan == null ? 'Plan creado' : 'Plan actualizado'),
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
}
