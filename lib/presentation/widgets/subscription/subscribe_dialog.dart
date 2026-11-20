import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/plan_model.dart';
import 'package:fitbase/domain/subscription_model.dart';
import 'package:fitbase/presentation/providers/payment_provider.dart';
import 'package:fitbase/presentation/providers/subscription_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/subscription/subscription_qr_modal.dart';

class SubscribeDialog extends ConsumerStatefulWidget {
  final PlanModel plan;
  final int gymId;

  const SubscribeDialog({
    super.key,
    required this.plan,
    required this.gymId,
  });

  static Future<void> show(
    BuildContext context, {
    required PlanModel plan,
    required int gymId,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SubscribeDialog(plan: plan, gymId: gymId),
    );
  }

  @override
  ConsumerState<SubscribeDialog> createState() => _SubscribeDialogState();
}

class _SubscribeDialogState extends ConsumerState<SubscribeDialog> {
  final _selectedMethod = ValueNotifier<int>(1);
  final _autoRenew = ValueNotifier<bool>(false);
  final _loading = ValueNotifier<bool>(false);
  final _errorMessage = ValueNotifier<String?>(null);

  final _stripeSessionId = ValueNotifier<String?>(null);
  final _stripeCheckoutUrl = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _selectedMethod.dispose();
    _autoRenew.dispose();
    _loading.dispose();
    _errorMessage.dispose();
    _stripeSessionId.dispose();
    _stripeCheckoutUrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubscribe() async {
    _loading.value = true;
    _errorMessage.value = null;

    if (_selectedMethod.value == 1) {
      try {
        final payload = PurchaseSubscriptionPayload(
          planId: widget.plan.id,
          paymentMethodId: 1,
          autoRenew: _autoRenew.value,
        );
        final ticket = await ref
            .read(userSubscriptionsProvider.notifier)
            .subscribe(payload);

        if (mounted) {
          Navigator.of(context).pop();
          SubscriptionQrModal.show(context, ticket: ticket);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('¡Membresía activada exitosamente!'),
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
        final session = await StripeCheckoutNotifier.createSession(
          gymId: widget.gymId,
          planId: widget.plan.id,
          type: 'subscription',
          autoRenew: _autoRenew.value,
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
              'No se pudo abrir el navegador automáticamente. Copia o intenta abrir el enlace nuevamente.';
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
      final status = await StripeCheckoutNotifier.checkStatus(sId);
      if (status.isCompleted) {
        await ref
            .read(userSubscriptionsProvider.notifier)
            .getMySubscriptions();
        await ref.read(userPaymentsProvider.notifier).getMyPayments();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('¡Pago verificado y suscripción completada!'),
            ),
          );
        }
      } else {
        _errorMessage.value =
            'Estado de pago: ${status.status} (${status.paymentStatus}). Si ya pagaste, espera unos segundos e intenta nuevamente.';
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
              Icons.card_membership_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Contratar Membresía',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plan.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.description.isNotEmpty
                        ? widget.plan.description
                        : 'Acceso a instalaciones por ${widget.plan.duration} días.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total a Pagar:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${widget.plan.finalPrice.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ValueListenableBuilder<String?>(
              valueListenable: _stripeSessionId,
              builder: (context, sessionId, _) {
                if (sessionId != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                              'Sesión Stripe Generada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID Sesión: ${sessionId.substring(0, 16)}...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Completa el pago en Stripe y luego pulsa "Verificar Pago" para activar tu carnet.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ValueListenableBuilder<String?>(
                          valueListenable: _stripeCheckoutUrl,
                          builder: (context, checkoutUrl, _) {
                            if (checkoutUrl == null || checkoutUrl.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
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
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forma de Pago',
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
                                            'Pagar en Recepción / Mostrador',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Emite tu suscripción para abonar en caja.',
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
                                            'Tarjeta Digital (Stripe)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Pago seguro en línea con tarjeta de crédito o débito.',
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
                    const SizedBox(height: 6),
                    ValueListenableBuilder<bool>(
                      valueListenable: _autoRenew,
                      builder: (context, renew, _) {
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Renovación Automática',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          activeThumbColor: AppColors.primary,
                          value: renew,
                          onChanged: (val) => _autoRenew.value = val,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: _errorMessage,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<String?>(
                valueListenable: _stripeSessionId,
                builder: (context, sessionId, _) {
                  if (sessionId != null) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _loading,
                      builder: (context, loading, _) {
                        return CustomButton(
                          text: loading ? 'Verificando...' : 'Verificar Pago',
                          onPressed: loading ? null : _verifyStripeSession,
                        );
                      },
                    );
                  }

                  return ValueListenableBuilder<bool>(
                    valueListenable: _loading,
                    builder: (context, loading, _) {
                      return CustomButton(
                        text: loading ? 'Procesando...' : 'Confirmar Membresía',
                        onPressed: loading ? null : _handleSubscribe,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
