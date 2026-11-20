import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/providers/cash_register_provider.dart';
import 'package:fitbase/presentation/widgets/manger/close_cash_dialog.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';
import 'package:fitbase/presentation/screens/admin/admin_settings_screen.dart';
import 'package:fitbase/presentation/screens/common/change_password_screen.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/providers/manager_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitbase/presentation/widgets/image_source_sheet.dart';

class ManagerProfileScreen extends ConsumerStatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  ConsumerState<ManagerProfileScreen> createState() =>
      _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends ConsumerState<ManagerProfileScreen> {
  final _uploadingAvatar = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(managerProvider.notifier).getManager();
    });
  }

  @override
  void dispose() {
    _uploadingAvatar.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await ImageSourceSheet.show(context);
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    _uploadingAvatar.value = true;
    try {
      final msg = await ref
          .read(managerProvider.notifier)
          .uploadAvatar(picked.path);
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(msg)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
      );
    } finally {
      _uploadingAvatar.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).value?.authData;
    final managerMe = ref.watch(managerProvider).value?.managerMe;
    final email = authUser?.email.isNotEmpty == true
        ? authUser!.email
        : 'manager@fitbase.io';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Perfil Encargado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              CustomNavigator.pushFade(context, const AdminSettingsScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _uploadingAvatar,
                builder: (context, uploading, _) {
                  return GestureDetector(
                    onTap: uploading ? null : _pickAndUploadAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            ),
                          ),
                          child: uploading
                              ? const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : (managerMe != null &&
                                    managerMe.avatarUrl.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    managerMe.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.manage_accounts_rounded,
                                              size: 55,
                                              color: AppColors.primary,
                                            ),
                                  ),
                                )
                              : const Icon(
                                  Icons.manage_accounts_rounded,
                                  size: 55,
                                  color: AppColors.primary,
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gerente de Sucursal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Rol: Manager de Sucursal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Datos de Cuenta y Seguridad',
              children: [
                _buildInfoRow(Icons.email_outlined, 'Correo de Acceso', email),
                _buildInfoRow(
                  Icons.badge_outlined,
                  'Rol Asignado',
                  'Staff / Manager',
                ),
                _buildInfoRow(
                  Icons.security,
                  'Seguridad 2FA',
                  authUser?.twoFactorEnabled == true
                      ? 'Habilitada'
                      : 'Deshabilitada',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Seguridad',
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      CustomNavigator.pushFade(
                        context,
                        const ChangePasswordScreen(),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cambiar Contraseña',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Cambiar Contraseña',
              icon: Icons.lock_reset_rounded,
              onPressed: () {
                CustomNavigator.pushFade(context, const ChangePasswordScreen());
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Cerrar Turno de Caja y Salir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final box = await ref.read(cashRegisterProvider.notifier).checkCurrent();
                  if (box != null && box.isOpen && context.mounted) {
                    CloseCashDialog.show(
                      context,
                      onClosed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
                        }
                      },
                    );
                  } else {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      CustomNavigator.pushAndRemoveUntilFade(context, const AuthGate());
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
