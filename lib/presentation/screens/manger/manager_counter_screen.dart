import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/checkin_model.dart';
import 'package:fitbase/domain/daypass_model.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/providers/checkin_provider.dart';
import 'package:fitbase/presentation/providers/daypass_provider.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/providers/plan_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/widgets/manger/cash_payment_dialog.dart';
import 'package:fitbase/presentation/widgets/manger/close_cash_dialog.dart';
import 'package:fitbase/presentation/widgets/manger/open_cash_dialog.dart';
import 'package:fitbase/presentation/widgets/manger/qr_scanner_modal.dart';

class ManagerCounterScreen extends ConsumerStatefulWidget {
  const ManagerCounterScreen({super.key});

  @override
  ConsumerState<ManagerCounterScreen> createState() =>
      _ManagerCounterScreenState();
}

class _ManagerCounterScreenState extends ConsumerState<ManagerCounterScreen> {
  final _tabIndex = ValueNotifier<int>(0);
  final _checkInByEmail = ValueNotifier<bool>(false);

  final _scanInputController = TextEditingController();
  final _emailScanController = TextEditingController();
  final _searchPassController = TextEditingController();

  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _selectedPlanId = ValueNotifier<int?>(null);
  final _generatedTicket = ValueNotifier<DayPassModel?>(null);

  final _isSubmitting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final gym = ref.read(gymProvider).value ??
          await ref.read(gymProvider.notifier).getMyGym();
      if (gym != null && gym.id > 0) {
        await ref.read(cashRegisterProvider.notifier).checkCurrent();
        await ref.read(publicPlansProvider.notifier).getPlansByGym(gym.id);
        await ref.read(dayPassProvider.notifier).searchDaypasses(gym.id);
      }
    });
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    _checkInByEmail.dispose();
    _scanInputController.dispose();
    _emailScanController.dispose();
    _searchPassController.dispose();
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _guestEmailController.dispose();
    _selectedPlanId.dispose();
    _generatedTicket.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  Future<void> _openCameraScanner(int gymId) async {
    final code = await QrScannerModal.show(context);
    if (code != null && code.isNotEmpty) {
      _scanInputController.text = code;
      await ref.read(checkInProvider.notifier).scanAccess(
            gymId: gymId,
            slug: code,
          );
    }
  }

  Future<void> _handleScanAccess(int gymId) async {
    final byEmail = _checkInByEmail.value;
    final text = byEmail
        ? _emailScanController.text.trim()
        : _scanInputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(byEmail
              ? 'Ingresa el correo electrónico del socio o visitante.'
              : 'Escanea o ingresa el código QR (slug).'),
        ),
      );
      return;
    }

    await ref.read(checkInProvider.notifier).scanAccess(
          gymId: gymId,
          slug: byEmail ? null : text,
          email: byEmail ? text : null,
        );
  }

  Future<void> _handleRegisterGuest(int gymId) async {
    final name = _guestNameController.text.trim();
    final phone = _guestPhoneController.text.trim();
    final email = _guestEmailController.text.trim();
    final planId = _selectedPlanId.value;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Completa todos los datos y selecciona un plan.'),
        ),
      );
      return;
    }

    _isSubmitting.value = true;
    try {
      final payload = RegisterGuestDayPassPayload(
        gymId: gymId,
        planId: planId,
        fullName: name,
        phone: phone,
        email: email,
      );
      final ticket =
          await ref.read(dayPassProvider.notifier).registerGuest(payload);
      _generatedTicket.value = ticket;
      _guestNameController.clear();
      _guestPhoneController.clear();
      _guestEmailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Pase diario emitido exitosamente.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error al emitir pase: $e'),
          ),
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(gymProvider).value;
    final cashBox = ref.watch(cashRegisterProvider).value;
    final gymId = gym?.id ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym?.name.isNotEmpty == true ? gym!.name : 'Recepción Fitbase',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Operativa de Mostrador y Accesos',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          _buildCashStatusBadge(cashBox, gymId),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (context, currentTab, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Check-in', Icons.qr_code_scanner_rounded, currentTab),
                      _buildTabButton(1, 'Cobro Pases', Icons.point_of_sale_rounded, currentTab),
                      _buildTabButton(2, 'Emitir Pase', Icons.person_add_alt_1_rounded, currentTab),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (context, currentTab, _) {
                if (currentTab == 0) {
                  return _buildCheckinTab(gymId);
                } else if (currentTab == 1) {
                  return _buildDeskPaymentsTab(gymId);
                } else {
                  return _buildRegisterGuestTab(gymId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashStatusBadge(dynamic cashBox, int gymId) {
    final isOpen = cashBox?.isOpen == true;

    return GestureDetector(
      onTap: () {
        if (!isOpen) {
          OpenCashDialog.show(
            context,
            gymId: gymId,
            onOpened: () => ref.read(cashRegisterProvider.notifier).checkCurrent(),
          );
        } else {
          CloseCashDialog.show(
            context,
            onClosed: () async {
              await ref.read(cashRegisterProvider.notifier).checkCurrent();
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOpen
              ? AppColors.primary.withAlpha(30)
              : AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOpen ? AppColors.primary : AppColors.error,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
              size: 14,
              color: isOpen ? AppColors.primary : AppColors.error,
            ),
            const SizedBox(width: 6),
            Text(
              isOpen
                  ? 'Caja: \$${cashBox.openCash.toStringAsFixed(0)}'
                  : 'Abrir Caja',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOpen ? AppColors.primary : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, int current) {
    final isSelected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabIndex.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinTab(int gymId) {
    final checkInAsync = ref.watch(checkInProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Validar Entrada de Socio o Visitante',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige cómo validar la entrada: escaneando su código QR o buscando por correo electrónico.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<bool>(
                valueListenable: _checkInByEmail,
                builder: (context, byEmail, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _checkInByEmail.value = false,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !byEmail
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 16,
                                        color: !byEmail
                                            ? AppColors.onPrimary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Escanear QR',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: !byEmail
                                              ? AppColors.onPrimary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _checkInByEmail.value = true,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: byEmail
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 16,
                                        color: byEmail
                                            ? AppColors.onPrimary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Por Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: byEmail
                                              ? AppColors.onPrimary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!byEmail) ...[
                        CustomButton(
                          text: 'Abrir Escáner de Cámara QR',
                          icon: Icons.qr_code_scanner_rounded,
                          onPressed: () => _openCameraScanner(gymId),
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'O ingresa el código manualmente (slug)',
                          hintText: 'Ej. 0192e2b3-...',
                          controller: _scanInputController,
                          prefixIcon: Icons.qr_code_2_rounded,
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          text: 'Validar Código QR',
                          isOutlined: true,
                          onPressed: () => _handleScanAccess(gymId),
                        ),
                      ] else ...[
                        CustomTextField(
                          label: 'Correo Electrónico del Socio o Visitante',
                          hintText: 'socio@ejemplo.com',
                          controller: _emailScanController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Validar Acceso por Email',
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: () => _handleScanAccess(gymId),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        checkInAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              'Error al validar: $err',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          data: (result) {
            if (result == null) return const SizedBox.shrink();
            return _buildCheckinResultCard(result, gymId);
          },
        ),
      ],
    );
  }

  Widget _buildCheckinResultCard(CheckInResult result, int gymId) {
    final isAllowed = result.allowed;
    final isPendingPayment = result.needPayment;

    final color = isAllowed
        ? AppColors.success
        : (isPendingPayment ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAllowed
                      ? Icons.check_circle_rounded
                      : (isPendingPayment
                          ? Icons.payment_rounded
                          : Icons.cancel_rounded),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAllowed
                          ? '¡ACCESO CONCEDIDO!'
                          : (isPendingPayment
                              ? 'PASE PENDIENTE DE PAGO'
                              : 'ACCESO DENEGADO'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.userName.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'Socio: ${result.userName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Modalidad: ${result.accessType} • Plan: ${result.planName}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (isPendingPayment) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: 'Ir a Cobro de Pases en Ventanilla',
              onPressed: () => _tabIndex.value = 1,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleScanPassForPayment(int gymId) async {
    final code = await QrScannerModal.show(context);
    if (code == null || code.isEmpty || !mounted) return;

    _searchPassController.text = code;
    try {
      final pass =
          await ref.read(dayPassProvider.notifier).getTicketBySlug(code);
      if (!mounted) return;

      if (pass == null) {
        await ref.read(dayPassProvider.notifier).searchDaypasses(
              gymId,
              search: code,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.error,
              content: Text('No se encontró un pase válido con ese código QR.'),
            ),
          );
        }
        return;
      }

      if (pass.gymId != 0 && pass.gymId != gymId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Este pase pertenece a otra sede.'),
          ),
        );
        return;
      }

      if (pass.isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Este pase ya se encuentra pagado.'),
          ),
        );
        return;
      }

      final cashBox = ref.read(cashRegisterProvider).value;
      if (cashBox == null || !cashBox.isOpen) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.warning,
            content: Text('Debes abrir tu turno de caja antes de cobrar.'),
          ),
        );
        OpenCashDialog.show(
          context,
          gymId: gymId,
          onOpened: () =>
              ref.read(cashRegisterProvider.notifier).checkCurrent(),
        );
        return;
      }

      CashPaymentDialog.show(
        context,
        pass: pass,
        onPaymentSuccess: () {
          ref.read(dayPassProvider.notifier).searchDaypasses(gymId);
        },
      );
    } catch (e) {
      if (mounted) {
        await ref.read(dayPassProvider.notifier).searchDaypasses(
              gymId,
              search: code,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text('Error al consultar pase: $e'),
            ),
          );
        }
      }
    }
  }

  Widget _buildDeskPaymentsTab(int gymId) {
    final daypassesAsync = ref.watch(dayPassProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: CustomButton(
            text: 'Escanear QR de Pase para Cobrar',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () => _handleScanPassForPayment(gymId),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: '',
                  hintText: 'Buscar por nombre, correo, teléfono o código...',
                  controller: _searchPassController,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon:
                    const Icon(Icons.search_rounded, color: AppColors.onPrimary),
                onPressed: () {
                  ref.read(dayPassProvider.notifier).searchDaypasses(
                        gymId,
                        search: _searchPassController.text.trim(),
                      );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(dayPassProvider.notifier).searchDaypasses(gymId),
            child: daypassesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Error al cargar pases: $err',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (passes) {
                final pendingPasses = passes.where((p) => !p.isPaid).toList();

                if (pendingPasses.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 48, color: AppColors.success),
                          SizedBox(height: 14),
                          Text(
                            'No hay pases pendientes de cobro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Todos los pases públicos generados para esta sede se encuentran liquidados.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: pendingPasses.length,
                  itemBuilder: (context, index) {
                    final pass = pendingPasses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.warning.withAlpha(120),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pass.fullName.isNotEmpty
                                      ? pass.fullName
                                      : 'Visitante Casual',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Pendiente en Ventanilla',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${pass.email} • ${pass.phone}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plan: ${pass.planName} • Visita: ${pass.visitDate}',
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
                                '\$${pass.planPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.point_of_sale_rounded,
                                  size: 16,
                                ),
                                label: const Text('Cobrar en Caja'),
                                onPressed: () {
                                  CashPaymentDialog.show(
                                    context,
                                    pass: pass,
                                    onPaymentSuccess: () {
                                      _scanInputController.text = pass.slug;
                                      _tabIndex.value = 0;
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterGuestTab(int gymId) {
    final plansAsync = ref.watch(publicPlansProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registro Presencial de Visitante Casual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Emite un pase diario con código QR para visitantes que llegan a recepción sin cuenta.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre Completo',
                hintText: 'Ej. María Pérez',
                controller: _guestNameController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Teléfono',
                hintText: 'Ej. 5512345678',
                controller: _guestPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Correo Electrónico',
                hintText: 'Ej. maria@email.com',
                controller: _guestEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona el Plan de Pase Diario',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              plansAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) => const Text(
                  'No fue posible obtener los planes de la sede.',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
                data: (plans) {
                  if (plans.isEmpty) {
                    return const Text(
                      'No hay planes registrados en esta sede.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    );
                  }

                  return ValueListenableBuilder<int?>(
                    valueListenable: _selectedPlanId,
                    builder: (context, selId, _) {
                      return Column(
                        children: plans.map((p) {
                          final isSelected = p.id == selId;
                          return InkWell(
                            onTap: () => _selectedPlanId.value = p.id,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(30)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${p.finalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: _isSubmitting,
                builder: (context, submitting, _) {
                  return CustomButton(
                    text: submitting
                        ? 'Emitiendo Boleto...'
                        : 'Emitir Boleto Digital con QR',
                    onPressed:
                        submitting ? null : () => _handleRegisterGuest(gymId),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<DayPassModel?>(
          valueListenable: _generatedTicket,
          builder: (context, ticket, _) {
            if (ticket == null) return const SizedBox.shrink();
            return _buildGeneratedTicketCard(ticket);
          },
        ),
      ],
    );
  }

  Widget _buildGeneratedTicketCard(DayPassModel ticket) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            '¡Boleto Digital Generado!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          QrImageView(
            data: ticket.slug,
            version: QrVersions.auto,
            size: 160.0,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.white,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ticket.fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plan: ${ticket.planName} • \$${ticket.planPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Proceder al Cobro en Ventanilla',
            onPressed: () {
              CashPaymentDialog.show(
                context,
                pass: ticket,
                onPaymentSuccess: () {
                  _scanInputController.text = ticket.slug;
                  _tabIndex.value = 0;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
