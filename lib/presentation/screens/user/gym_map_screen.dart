import 'package:flutter/material.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/gym_location_card.dart';

class GymMapScreen extends StatefulWidget {
  final bool isModal;

  const GymMapScreen({super.key, this.isModal = false});

  @override
  State<GymMapScreen> createState() => _GymMapScreenState();
}

class _GymMapScreenState extends State<GymMapScreen> {
  int _selectedGymIndex = 0;

  final List<Map<String, String>> _gyms = [
    {
      'name': 'Fitbase Central Hub',
      'address': 'Av. Insurgentes Sur 1450, Del Valle',
      'distance': '1.2 km',
      'schedule': '24 Horas',
      'phone': '+52 55 1234 5678',
      'rating': '4.9',
    },
    {
      'name': 'Fitbase Polanco Elite',
      'address': 'Campos Elíseos 204, Polanco V Secc',
      'distance': '4.8 km',
      'schedule': '05:00 - 23:00',
      'phone': '+52 55 8765 4321',
      'rating': '4.8',
    },
    {
      'name': 'Fitbase Santa Fe',
      'address': 'Vasco de Quiroga 3800, Santa Fe',
      'distance': '9.3 km',
      'schedule': '06:00 - 22:00',
      'phone': '+52 55 4567 8901',
      'rating': '4.7',
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Mapa de Gimnasios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF191F26),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 80,
                  child: _buildPin(0, 'Central Hub'),
                ),
                Positioned(
                  top: 260,
                  right: 90,
                  child: _buildPin(1, 'Polanco Elite'),
                ),
                Positioned(
                  bottom: 220,
                  left: 120,
                  child: _buildPin(2, 'Santa Fe'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(240),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar gimnasio o zona...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  icon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GymLocationCard(
                  name: _gyms[_selectedGymIndex]['name']!,
                  address: _gyms[_selectedGymIndex]['address']!,
                  distance: _gyms[_selectedGymIndex]['distance']!,
                  schedule: _gyms[_selectedGymIndex]['schedule']!,
                  phone: _gyms[_selectedGymIndex]['phone']!,
                  onDirections: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(int index, String label) {
    final isSelected = _selectedGymIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGymIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.location_on_rounded,
            size: isSelected ? 42 : 32,
            color: isSelected ? AppColors.primary : Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF26303B)
      ..strokeWidth = 3;

    final primaryRoadPaint = Paint()
      ..color = const Color(0xFF33404F)
      ..strokeWidth = 8;

    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.45), primaryRoadPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.3, size.height), primaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), roadPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.15), Offset(size.width, size.height * 0.2), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
