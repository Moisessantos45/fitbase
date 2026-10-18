import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/screens/admin/admin_settings_screen.dart';

class AdminGymEditScreen extends StatefulWidget {
  final bool isModal;

  const AdminGymEditScreen({super.key, this.isModal = false});

  @override
  State<AdminGymEditScreen> createState() => _AdminGymEditScreenState();
}

class _AdminGymEditScreenState extends State<AdminGymEditScreen> {
  final _nameController = TextEditingController(text: 'Fitbase Central Hub');
  final _addressController = TextEditingController(text: 'Av. Insurgentes Sur 1450, Del Valle');
  final _phoneController = TextEditingController(text: '+52 55 1234 5678');
  final _emailController = TextEditingController(text: 'contacto@fitbasegym.com');
  final _scheduleController = TextEditingController(text: 'Lunes a Domingo 24 Horas');
  final _capacityController = TextEditingController(text: '250');
  final _latLngController = TextEditingController(text: '19.3734, -99.1798');

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _scheduleController.dispose();
    _capacityController.dispose();
    _latLngController.dispose();
    super.dispose();
  }

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
          'Datos del Gimnasio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              CustomNavigator.pushFade(context, const AdminSettingsScreen());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sede Principal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Actualiza los datos visibles para usuarios e invitados.',
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
            CustomTextField(
              label: 'Nombre del Gimnasio / Sede',
              controller: _nameController,
              prefixIcon: Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Dirección Física',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Coordenadas de Ubicación (Lat, Lng)',
              controller: _latLngController,
              prefixIcon: Icons.map_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Teléfono',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Aforo Máximo',
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.people_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Correo de Contacto',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Horario de Atención',
              controller: _scheduleController,
              prefixIcon: Icons.access_time_rounded,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Guardar Cambios de Sede',
              icon: Icons.save_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos del gimnasio actualizados correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Configuración y Cerrar Sesión',
              isOutlined: true,
              icon: Icons.logout_rounded,
              onPressed: () {
                CustomNavigator.pushFade(context, const AdminSettingsScreen());
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
