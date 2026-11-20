import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';

class SubscriptionQrModal extends StatelessWidget {
  final SubscriptionItem? item;
  final SubscriptionTicket? ticket;
  final String? slug;
  final String? planName;
  final String? gymName;

  const SubscriptionQrModal({
    super.key,
    this.item,
    this.ticket,
    this.slug,
    this.planName,
    this.gymName,
  });

  static Future<void> show(
    BuildContext context, {
    SubscriptionItem? item,
    SubscriptionTicket? ticket,
    String? slug,
    String? planName,
    String? gymName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubscriptionQrModal(
        item: item,
        ticket: ticket,
        slug: slug,
        planName: planName,
        gymName: gymName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displaySlug = slug ?? ticket?.slug ?? item?.slug ?? '';
    final displayPlan =
        planName ?? ticket?.planName ?? item?.planName ?? 'Membresía';
    final displayGym =
        gymName ?? ticket?.gymName ?? item?.gymName ?? 'Fitbase';
    final name = ticket?.fullName ?? item?.userFullName ?? 'Socio';
    final startDate = ticket?.startDate ?? item?.startDate ?? '';
    final endDate = ticket?.endDate ?? item?.endDate ?? '';
    final statusName = ticket?.statusName ?? item?.statusName ?? 'Activo';

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF263300), AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 1.5),
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
                          displayGym,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayPlan,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: QrImageView(
                    data: displaySlug.isNotEmpty ? displaySlug : 'FITBASE',
                    version: QrVersions.auto,
                    size: 180.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Válido: $startDate - $endDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID Acceso: ${displaySlug.isNotEmpty ? displaySlug.substring(0, 13) : ''}...',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Cerrar Credencial',
            isSecondary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

