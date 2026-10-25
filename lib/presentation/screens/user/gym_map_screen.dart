import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/widgets/common/gym_detail_modal.dart';

class GymMapScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const GymMapScreen({super.key, this.isModal = false});

  @override
  ConsumerState<GymMapScreen> createState() => _GymMapScreenState();
}

class _GymMapScreenState extends ConsumerState<GymMapScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> _hasSearchText = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLocating = ValueNotifier<bool>(false);
  final ValueNotifier<LatLng?> _userPosition = ValueNotifier<LatLng?>(null);
  final ValueNotifier<GymModel?> _selectedGym = ValueNotifier<GymModel?>(null);

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _searchController.addListener(() {
      _hasSearchText.value = _searchController.text.trim().isNotEmpty;
    });

    Future.microtask(() {
      _getUserLocation();
      _fetchGyms();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    _hasSearchText.dispose();
    _isLocating.dispose();
    _userPosition.dispose();
    _selectedGym.dispose();
    super.dispose();
  }

  Future<void> _fetchGyms({String? query}) async {
    final search = query ?? _searchController.text.trim();
    final userPos = _userPosition.value;
    final gyms = await ref.read(publicGymsProvider.notifier).fetchGyms(
          search: search.isNotEmpty ? search : null,
          lat: userPos?.latitude,
          lng: userPos?.longitude,
        );

    if (_selectedGym.value == null && gyms.isNotEmpty) {
      final firstWithCoords = gyms.firstWhere(
        (g) => g.latitude != 0 && g.longitude != 0,
        orElse: () => gyms.first,
      );
      _selectedGym.value = firstWithCoords;
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchGyms(query: val.trim());
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _fetchGyms(query: '');
  }

  Future<void> _getUserLocation() async {
    _isLocating.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocating.value = false;
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocating.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocating.value = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      _userPosition.value = userLatLng;
      _mapController.move(userLatLng, 13.5);
      await _fetchGyms();
    } catch (_) {
    } finally {
      if (mounted) {
        _isLocating.value = false;
      }
    }
  }

  String _getDistanceString(GymModel gym) {
    if (gym.distanceMeters > 0) {
      if (gym.distanceMeters < 1000) {
        return '${gym.distanceMeters.round()} m';
      }
      return '${(gym.distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    final userPos = _userPosition.value;
    if (userPos != null && gym.latitude != 0 && gym.longitude != 0) {
      final d = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        gym.latitude,
        gym.longitude,
      );
      if (d < 1000) {
        return '${d.round()} m';
      }
      return '${(d / 1000).toStringAsFixed(1)} km';
    }
    return '';
  }

  void _onSelectGym(GymModel gym) {
    _selectedGym.value = gym;
    if (gym.latitude != 0 && gym.longitude != 0) {
      _mapController.move(LatLng(gym.latitude, gym.longitude), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicGymsState = ref.watch(publicGymsProvider);

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
          'Sedes y Mapa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isLocating,
            builder: (context, locating, _) {
              return IconButton(
                tooltip: 'Mi ubicación',
                icon: locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.primary,
                      ),
                onPressed: locating ? null : _getUserLocation,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: publicGymsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error al cargar sedes: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _fetchGyms(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (gyms) {
          final gymsWithCoords = gyms
              .where((g) => g.latitude != 0.0 && g.longitude != 0.0)
              .toList();

          return ValueListenableBuilder<GymModel?>(
            valueListenable: _selectedGym,
            builder: (context, selectedGym, _) {
              final activeGym = selectedGym ??
                  (gymsWithCoords.isNotEmpty ? gymsWithCoords.first : null);

              final initialCenter = activeGym != null
                  ? LatLng(activeGym.latitude, activeGym.longitude)
                  : const LatLng(19.4194, -99.1622);

              return Stack(
                children: [
                  ValueListenableBuilder<LatLng?>(
                    valueListenable: _userPosition,
                    builder: (context, userPos, _) {
                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: userPos ?? initialCenter,
                          initialZoom: 13.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.fitbase.app',
                          ),
                          MarkerLayer(
                            markers: [
                              if (userPos != null)
                                Marker(
                                  point: userPos,
                                  width: 36,
                                  height: 36,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              AppColors.primary.withAlpha(120),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_pin_circle_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ...gymsWithCoords.map((gym) {
                                final isSelected = activeGym?.id == gym.id;

                                return Marker(
                                  point: LatLng(gym.latitude, gym.longitude),
                                  width: 140,
                                  height: 70,
                                  child: GestureDetector(
                                    onTap: () => _onSelectGym(gym),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppColors.primary,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.black.withAlpha(120),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            gym.name.replaceAll('Fitbase ', ''),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withAlpha(240),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _hasSearchText,
                        builder: (context, hasText, _) {
                          return TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar sede por nombre o zona...',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              suffixIcon: hasText
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: activeGym != null ? 220 : 30,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'auth_gym_zoom_in',
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          onPressed: () {
                            final z = _mapController.camera.zoom;
                            final current = activeGym != null
                                ? LatLng(
                                    activeGym.latitude,
                                    activeGym.longitude,
                                  )
                                : _mapController.camera.center;
                            _mapController.move(current, z + 1);
                          },
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'auth_gym_zoom_out',
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          onPressed: () {
                            final z = _mapController.camera.zoom;
                            final current = activeGym != null
                                ? LatLng(
                                    activeGym.latitude,
                                    activeGym.longitude,
                                  )
                                : _mapController.camera.center;
                            _mapController.move(current, z - 1);
                          },
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<LatLng?>(
                          valueListenable: _userPosition,
                          builder: (context, userPos, _) {
                            if (userPos == null) return const SizedBox.shrink();
                            return FloatingActionButton.small(
                              heroTag: 'auth_gym_center_user',
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.primary,
                              onPressed: () {
                                _mapController.move(userPos, 14);
                              },
                              child: const Icon(Icons.near_me_rounded),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (activeGym != null)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(140),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (activeGym.backgroundUrl.isNotEmpty) ...[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 52,
                                            height: 52,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  activeGym.backgroundUrl,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.fitness_center_rounded,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activeGym.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: (activeGym.isOpen
                                                            ? AppColors.success
                                                            : AppColors.error)
                                                        .withAlpha(40),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    activeGym.isOpen
                                                        ? 'Abierto'
                                                        : 'Cerrado',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: activeGym.isOpen
                                                          ? AppColors.success
                                                          : AppColors.error,
                                                    ),
                                                  ),
                                                ),
                                                if (_getDistanceString(activeGym).isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _getDistanceString(activeGym),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          activeGym.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _onSelectGym(activeGym),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.near_me_rounded,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Centrar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            GymDetailModal.show(
                                              context,
                                              gym: activeGym,
                                              distanceText: _getDistanceString(
                                                activeGym,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor:
                                                AppColors.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.visibility_rounded,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Ver Detalles',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
