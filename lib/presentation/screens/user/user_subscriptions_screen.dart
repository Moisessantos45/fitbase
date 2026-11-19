import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/providers/history_provider.dart';
import 'package:fitbase/presentation/screens/user/user_plans_screen.dart';

class UserSubscriptionsScreen extends ConsumerWidget {
  final bool isModal;

  const UserSubscriptionsScreen({super.key, this.isModal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Mis Suscripciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: FutureBuilder(
        future: ref.read(historyProvider.notifier).getMySubscriptions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final subs = snapshot.data!;
          if (subs.isEmpty) {
            return const Center(child: Text('No tienes suscripciones', style: TextStyle(color: AppColors.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sub.isActive ? AppColors.primary : AppColors.border,
                    width: sub.isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (sub.isActive ? AppColors.success : AppColors.textSecondary).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sub.statusName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: sub.isActive ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '\$${sub.planPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(sub.planName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(sub.gymName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('${sub.startDate} - ${sub.endDate}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                    if (sub.isActive) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cambiar Plan',
                              isSecondary: true,
                              height: 44,
                              onPressed: () {
                                CustomNavigator.pushFade(context, const UserPlansScreen(isModal: true));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Cancelar',
                              isOutlined: true,
                              height: 44,
                              onPressed: () => _showCancelDialog(context, sub.planName),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cancelar suscripción?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Tu plan "$planName" se desactivará. Mantendrás el acceso a las instalaciones hasta el final de tu ciclo actual.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Volver', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suscripción cancelada (simulado)'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}