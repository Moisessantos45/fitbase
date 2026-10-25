import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';

class GymDetailModal extends ConsumerStatefulWidget {
  final GymModel initialGym;
  final String? distanceText;

  const GymDetailModal({
    super.key,
    required this.initialGym,
    this.distanceText,
  });

  static Future<void> show(
    BuildContext context, {
    required GymModel gym,
    String? distanceText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GymDetailModal(
        initialGym: gym,
        distanceText: distanceText,
      ),
    );
  }

  @override
  ConsumerState<GymDetailModal> createState() => _GymDetailModalState();
}

class _GymDetailModalState extends ConsumerState<GymDetailModal> {
  late final ValueNotifier<GymModel> _gymNotifier;
  final ValueNotifier<bool> _isLoadingDetails = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _gymNotifier = ValueNotifier<GymModel>(widget.initialGym);
    _loadFullDetails();
  }

  @override
  void dispose() {
    _gymNotifier.dispose();
    _isLoadingDetails.dispose();
    super.dispose();
  }

  Future<void> _loadFullDetails() async {
    try {
      final detail = await ref
          .read(gymProvider.notifier)
          .getGymDetail(widget.initialGym.id);
      if (detail != null && mounted) {
        _gymNotifier.value = detail;
      }
    } catch (_) {
    } finally {
      if (mounted) {
        _isLoadingDetails.value = false;
      }
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(220),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withAlpha(200),
                ),
                icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ValueListenableBuilder<GymModel>(
        valueListenable: _gymNotifier,
        builder: (context, gym, _) {
          final sortedSchedules = List<GymScheduleItem>.from(gym.schedules)
            ..sort((a, b) {
              final orderA = a.dayOfWeek == 0 ? 7 : a.dayOfWeek;
              final orderB = b.dayOfWeek == 0 ? 7 : b.dayOfWeek;
              return orderA.compareTo(orderB);
            });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            color: AppColors.background,
                            child: gym.backgroundUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: gym.backgroundUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.fitness_center_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (gym.isOpen
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withAlpha(220),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    gym.isOpen
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    gym.isOpen ? 'Abierto' : 'Cerrado',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (widget.distanceText != null &&
                            widget.distanceText!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.navigation_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.distanceText!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      gym.address.isNotEmpty
                          ? gym.address
                          : 'Dirección no disponible',
                    ),
                    if (gym.phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone_outlined, gym.phone),
                    ],
                    if (gym.email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email_outlined, gym.email),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Horarios de Atención',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (sortedSchedules.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedSchedules.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: AppColors.border,
                          ),
                          itemBuilder: (context, index) {
                            final sched = sortedSchedules[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sched.dayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: sched.isClosed
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    sched.formattedHours,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: sched.isClosed
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      const Text(
                        'Horarios no disponibles',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (gym.photos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Instalaciones y Fotos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: gym.photos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final photo = gym.photos[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showImagePreview(context, photo.url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 140,
                                  color: AppColors.background,
                                  child: CachedNetworkImage(
                                    imageUrl: photo.url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.broken_image_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
