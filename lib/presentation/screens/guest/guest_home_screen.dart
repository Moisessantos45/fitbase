import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/presentation/widgets/plan_card.dart';
import 'package:fitbase/presentation/widgets/gym_location_card.dart';
import 'package:fitbase/presentation/screens/auth/register_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modo Invitado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Explora planes y sucursales',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              CustomNavigator.pushFade(context, const RegisterScreen());
            },
            child: const Text(
              'Registrarse',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Planes Disponibles', icon: Icon(Icons.card_membership_rounded)),
            Tab(text: 'Ubicaciones', icon: Icon(Icons.location_on_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(),
          _buildLocationsTab(),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PlanCard(
          title: 'Plan Básico',
          price: '\$299',
          period: '/mes',
          description: 'Acceso a área de pesas y cardio de lunes a viernes.',
          benefits: const [
            'Área de pesas y cardio libre',
            'Vestidores y lockers estándar',
            'Horario de 6:00 AM a 10:00 PM',
          ],
          onSelect: () => _goToRegister(),
        ),
        const SizedBox(height: 18),
        PlanCard(
          title: 'Plan Black Pro',
          price: '\$499',
          period: '/mes',
          description: 'Acceso total e ilimitado a todas nuestras sedes y clases.',
          isPopular: true,
          benefits: const [
            'Acceso ilimitado 24/7',
            'Todas las sedes incluidas',
            'Clases grupales (Spinning, Yoga, Cross)',
            'Área de sauna y spa',
            'Invitado gratis 1 vez por semana',
          ],
          onSelect: () => _goToRegister(),
        ),
        const SizedBox(height: 18),
        PlanCard(
          title: 'Plan Anual VIP',
          price: '\$4,990',
          period: '/año',
          description: 'Ahorra 2 meses y recibe asesoría nutricional completa.',
          benefits: const [
            'Todos los beneficios Black Pro',
            'Evaluación y plan nutricional mensual',
            '2 sesiones de entrenador personal gratis',
            'Kit de bienvenida Fitbase gratis',
          ],
          onSelect: () => _goToRegister(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLocationsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GymLocationCard(
          name: 'Fitbase Central Hub',
          address: 'Av. Insurgentes Sur 1450, Del Valle',
          distance: '1.2 km',
          schedule: 'Lun - Dom: 24 Horas',
          phone: '+52 55 1234 5678',
          onDirections: () {},
        ),
        const SizedBox(height: 16),
        GymLocationCard(
          name: 'Fitbase Polanco Elite',
          address: 'Campos Elíseos 204, Polanco V Secc',
          distance: '4.8 km',
          schedule: 'Lun - Vie: 05:00 - 23:00 | Sáb-Dom: 07:00 - 20:00',
          phone: '+52 55 8765 4321',
          onDirections: () {},
        ),
        const SizedBox(height: 16),
        GymLocationCard(
          name: 'Fitbase Santa Fe',
          address: 'Vasco de Quiroga 3800, Santa Fe',
          distance: '9.3 km',
          schedule: 'Lun - Vie: 06:00 - 22:00 | Sáb: 07:00 - 18:00',
          phone: '+52 55 4567 8901',
          onDirections: () {},
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _goToRegister() {
    CustomNavigator.pushFade(context, const RegisterScreen());
  }
}
