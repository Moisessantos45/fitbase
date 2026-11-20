import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/daypass_model.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/presentation/providers/daypass_provider.dart';
import 'package:fitbase/presentation/providers/payment_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/widgets/subscription/subscription_qr_modal.dart';

class GuestDayPassDialog extends ConsumerStatefulWidget {
  final PlanModel plan;
  final int gymId;
  final String gymName;

  const GuestDayPassDialog({
    super.key,
    required this.plan,
    required this.gymId,
    required this.gymName,
  });

  static Future<void> show(
    BuildContext context, {
    required PlanModel plan,
    required int gymId,
    required String gymName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => GuestDayPassDialog(
        plan: plan,
        gymId: gymId,
        gymName: gymName,
      ),
    );
  }

  @override
  ConsumerState<GuestDayPassDialog> createState() => _GuestDayPassDialogState();
}

class _GuestDayPassDialogState extends ConsumerState<GuestDayPassDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _selectedMethod = ValueNotifier<int>(1);
  final _loading = ValueNotifier<bool>(false);
  final _errorMessage = ValueNotifier<String?>(null);
  late final ValueNotifier<String> _visitDate;

  final _stripeSessionId = ValueNotifier<String?>(null);
  final _stripeCheckoutUrl = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visitDate = ValueNotifier<String>(
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _selectedMethod.dispose();
    _loading.dispose();
    _errorMessage.dispose();
    _visitDate.dispose();
    _stripeSessionId.dispose();
    _stripeCheckoutUrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      _visitDate.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSubmit() async {
    final fullName = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final visitDate = _visitDate.value;

    if (fullName.isEmpty || phone.isEmpty || email.isEmpty) {
      _errorMessage.value =
          'Por favor completa tu nombre, teléfono y correo electrónico.';
      return;
    }

    _loading.value = true;
    _errorMessage.value = null;

    if (_selectedMethod.value == 1) {
      try {
        final payload = RegisterGuestDayPassPayload(
          gymId: widget.gymId,
          planId: widget.plan.id,
          fullName: fullName,
          phone: phone,
          email: email,
          visitDate: visitDate,
        );
        final pass = await ref
            .read(dayPassProvider.notifier)
            .createPublicGuestDayPass(payload);

        if (mounted) {
          Navigator.of(context).pop();
          SubscriptionQrModal.show(
            context,
            slug: pass.slug,
            planName: pass.planName.isNotEmpty
                ? '${pass.planName} (Ventanilla)'
                : '${widget.plan.name} (Ventanilla)',
            gymName: pass.gymName.isNotEmpty ? pass.gymName : widget.gymName,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                  '¡Pase registrado! Muestra tu QR en ventanilla para abonar.'),
            ),
          );
        }
      } catch (e) {
        _errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      } finally {
        _loading.value = false;
      }
    } else {
      try {
        final session = await StripeCheckoutNotifier.createGuestCheckout(
          gymId: widget.gymId,
          planId: widget.plan.id,
          fullName: fullName,
          phone: phone,
          email: email,
          visitDate: visitDate,
        );
        _stripeSessionId.value = session.sessionId;
        _stripeCheckoutUrl.value = session.checkoutUrl;
        if (session.checkoutUrl.isNotEmpty) {
          await _launchCheckoutUrl(session.checkoutUrl);
        }
      } catch (e) {
        _errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      } finally {
        _loading.value = false;
      }
    }
  }

  Future<void> _launchCheckoutUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _errorMessage.value = 'Enlace de pago inválido.';
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!fallback) {
          _errorMessage.value =
              'No se pudo abrir el navegador automáticamente. Puedes copiar el enlace abajo.';
        }
      }
    } catch (e) {
      _errorMessage.value = 'No se pudo abrir el enlace: $e';
    }
  }

  Future<void> _verifyStripeSession() async {
    final sId = _stripeSessionId.value;
    if (sId == null) return;

    _loading.value = true;
    _errorMessage.value = null;

    try {
      final status = await StripeCheckoutNotifier.checkPublicStatus(sId);
      if (status.isCompleted) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                  '¡Pago confirmado! Tu pase ya está activo y fue enviado a tu correo.'),
            ),
          );
        }
      } else {
        _errorMessage.value =
            'Estado de pago: ${status.status} (${status.paymentStatus}). Completa el pago en Stripe e intenta verificar de nuevo.';
      }
    } catch (e) {
      _errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Registrar Pase de Visita',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.gymName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${widget.plan.finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _stripeSessionId,
              builder: (context, sessionId, _) {
                if (sessionId != null) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _stripeCheckoutUrl,
                    builder: (context, checkoutUrl, _) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.payment_rounded,
                                    color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Sesión Stripe Lista',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Copia o abre el enlace de pago en tu navegador y luego presiona "Verificar Pago".',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (checkoutUrl != null && checkoutUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.open_in_new_rounded,
                                      size: 16, color: AppColors.primary),
                                  label: const Text(
                                    'Abrir Pasarela Stripe',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _launchCheckoutUrl(checkoutUrl),
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.copy_rounded,
                                    size: 16, color: AppColors.primary),
                                label: const Text(
                                  'Copiar enlace de pago Stripe',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: checkoutUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.primary,
                                      content: Text(
                                          'Enlace de Stripe copiado al portapapeles.'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nombre Completo',
                      hintText: 'Ej. Carlos Santillán',
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Teléfono',
                      hintText: 'Ej. 5512345678',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Correo Electrónico',
                      hintText: 'correo@ejemplo.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fecha de Visita',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<String>(
                      valueListenable: _visitDate,
                      builder: (context, dateStr, _) {
                        return InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 18, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Cambiar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Método de Pago',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _selectedMethod,
                      builder: (context, method, _) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _selectedMethod.value = 1,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: method == 1
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: method == 1
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: method == 1 ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_rounded,
                                      color: method == 1
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pagar en Ventanilla',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Reserva tu pase QR y págalo al llegar en recepción.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      method == 1
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: method == 1
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () => _selectedMethod.value = 2,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: method == 2
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: method == 2
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: method == 2 ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.credit_card_rounded,
                                      color: method == 2
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pagar con Tarjeta (Stripe)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Pago seguro en línea para acceso inmediato.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      method == 2
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: method == 2
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: _errorMessage,
              builder: (context, err, _) {
                if (err == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    err,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _loading,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: _stripeSessionId,
              builder: (context, sessionId, _) {
                if (sessionId != null) {
                  return CustomButton(
                    text: isLoading ? 'Verificando...' : 'Verificar Pago',
                    onPressed: isLoading ? null : _verifyStripeSession,
                  );
                }
                return ValueListenableBuilder<int>(
                  valueListenable: _selectedMethod,
                  builder: (context, method, _) {
                    final label = method == 1
                        ? 'Reservar Pase'
                        : 'Pagar con Tarjeta';
                    return CustomButton(
                      text: isLoading ? 'Procesando...' : label,
                      onPressed: isLoading ? null : _handleSubmit,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
