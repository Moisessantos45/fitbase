import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/widgets/gym_location_card.dart';

class GymMapScreen extends StatefulWidget {
  final bool isModal;

  const GymMapScreen({super.key, this.isModal = false});

  @override
  State<GymMapScreen> createState() => _GymMapScreenState();
}

class _GymMapScreenState extends State<GymMapScreen> {
  late final MapController _mapController;
  final _selectedGymIndex = ValueNotifier<int>(0);

  final List<Map<String, dynamic>> _gyms = [
    {
      'name': 'Fitbase Central Hub',
      'address': 'Av. Insurgentes Sur 1450, Del Valle',
      'distance': '1.2 km',
      'schedule': '24 Horas',
      'phone': '+52 55 1234 5678',
      'rating': '4.9',
      'location': const LatLng(19.3780, -99.1780),
    },
    {
      'name': 'Fitbase Polanco Elite',
      'address': 'Campos Elíseos 204, Polanco V Secc',
      'distance': '4.8 km',
      'schedule': '05:00 - 23:00',
      'phone': '+52 55 8765 4321',
      'rating': '4.8',
      'location': const LatLng(19.4326, -99.1950),
    },
    {
      'name': 'Fitbase Santa Fe',
      'address': 'Vasco de Quiroga 3800, Santa Fe',
      'distance': '9.3 km',
      'schedule': '06:00 - 22:00',
      'phone': '+52 55 4567 8901',
      'rating': '4.7',
      'location': const LatLng(19.3590, -99.2600),
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _selectedGymIndex.dispose();
    super.dispose();
  }

  void _onSelectGym(int index) {
    _selectedGymIndex.value = index;
    final LatLng loc = _gyms[index]['location'] as LatLng;
    _mapController.move(loc, 15.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
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
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedGymIndex,
        builder: (context, selectedIndex, _) {
          final currentLoc = _gyms[selectedIndex]['location'] as LatLng;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLoc,
                  initialZoom: 14.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fitbase.app',
                  ),
                  MarkerLayer(
                    markers: List.generate(_gyms.length, (index) {
                      final item = _gyms[index];
                      final isSelected = selectedIndex == index;
                      final LatLng pt = item['location'] as LatLng;

                      return Marker(
                        point: pt,
                        width: 140,
                        height: 70,
                        child: GestureDetector(
                          onTap: () => _onSelectGym(index),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Text(
                                  item['name'].toString().replaceAll(
                                        'Fitbase ',
                                        '',
                                      ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.onPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                size: isSelected ? 36 : 28,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
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
                right: 16,
                bottom: 220,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'gym_zoom_in',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: () {
                        final z = _mapController.camera.zoom;
                        _mapController.move(
                          _gyms[_selectedGymIndex.value]['location'] as LatLng,
                          z + 1,
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'gym_zoom_out',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: () {
                        final z = _mapController.camera.zoom;
                        _mapController.move(
                          _gyms[_selectedGymIndex.value]['location'] as LatLng,
                          z - 1,
                        );
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
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
                      name: _gyms[selectedIndex]['name']!.toString(),
                      address: _gyms[selectedIndex]['address']!.toString(),
                      distance: _gyms[selectedIndex]['distance']!.toString(),
                      schedule: _gyms[selectedIndex]['schedule']!.toString(),
                      phone: _gyms[selectedIndex]['phone']!.toString(),
                      onDirections: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
