import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';

class AdminSubscribersScreen extends StatefulWidget {
  final bool isModal;

  const AdminSubscribersScreen({super.key, this.isModal = false});

  @override
  State<AdminSubscribersScreen> createState() => _AdminSubscribersScreenState();
}

class _AdminSubscribersScreenState extends State<AdminSubscribersScreen> {
  final _activeFilter = ValueNotifier<String>('Todos');

  @override
  void dispose() {
    _activeFilter.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _subscribers = [
    {
      'name': 'Carlos Mendoza',
      'email': 'carlos.fit@email.com',
      'plan': 'Plan Black Pro',
      'status': 'Activo',
      'expiry': '24 Oct 2026',
      'amount': '\$499/mes',
    },
    {
      'name': 'Lucía Morales',
      'email': 'lucia.mora@email.com',
      'plan': 'Plan Anual VIP',
      'status': 'Activo',
      'expiry': '15 Mar 2027',
      'amount': '\$4,990/año',
    },
    {
      'name': 'Rodrigo Sánchez',
      'email': 'rodrigo.s@email.com',
      'plan': 'Plan Básico',
      'status': 'Por Vencer',
      'expiry': '12 Oct 2026',
      'amount': '\$299/mes',
    },
    {
      'name': 'Valeria Gómez',
      'email': 'val.gomez@email.com',
      'plan': 'Plan Black Pro',
      'status': 'Activo',
      'expiry': '05 Nov 2026',
      'amount': '\$499/mes',
    },
    {
      'name': 'Andrés Castillo',
      'email': 'andres.c@email.com',
      'plan': 'Plan Básico',
      'status': 'Vencido',
      'expiry': '01 Oct 2026',
      'amount': '\$299/mes',
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
          'Suscriptores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar suscriptor por nombre o email...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  icon: Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _activeFilter,
            builder: (context, activeFilter, _) {
              final filtered = _getFilteredSubscribers(activeFilter);
              return Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _buildFilterChip('Todos', activeFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip('Activo', activeFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip('Por Vencer', activeFilter),
                          const SizedBox(width: 8),
                          _buildFilterChip('Vencido', activeFilter),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final sub = filtered[index];
                          return _buildSubscriberCard(sub);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSubscribers(String filter) {
    if (filter == 'Todos') return _subscribers;
    return _subscribers.where((s) => s['status'] == filter).toList();
  }

  Widget _buildFilterChip(String label, String activeFilter) {
    final isSelected = activeFilter == label;
    return GestureDetector(
      onTap: () => _activeFilter.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriberCard(Map<String, dynamic> sub) {
    Color statusColor;
    switch (sub['status']) {
      case 'Activo':
        statusColor = AppColors.success;
        break;
      case 'Por Vencer':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.error;
    }

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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary),
                ),
                child: Center(
                  child: Text(
                    sub['name'].toString().substring(0, 1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub['email'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sub['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Asignado',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sub['plan']} (${sub['amount']})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Vencimiento',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub['expiry'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openModifySubscription(sub),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Modificar Suscripción / Plan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openModifySubscription(Map<String, dynamic> sub) {
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
              'Modificar Suscripción de ${sub['name']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acciones Rápidas:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Cambiar Plan Asignado',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Asignar Básico, Black Pro o VIP',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan modificado con éxito'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.date_range_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Extender Fecha de Vencimiento',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Añadir 30 días de cortesía',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fecha extendida 30 días'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.pause_circle_outline_rounded,
                color: AppColors.warning,
              ),
              title: const Text(
                'Congelar Suscripción',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Pausar cobros temporalmente',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Cerrar',
              isSecondary: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
