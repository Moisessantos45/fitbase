import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/screens/auth/register_screen.dart';
import 'package:fitbase/presentation/screens/auth_gate.dart';
import 'package:fitbase/presentation/widgets/plan_card.dart';
import 'package:fitbase/presentation/widgets/common/gym_detail_modal.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final MapController _mapController;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> _hasSearchText = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLocating = ValueNotifier<bool>(false);
  final ValueNotifier<LatLng?> _userPosition = ValueNotifier<LatLng?>(null);

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mapController = MapController();
    _scrollController = ScrollController();

    _searchController.addListener(() {
      _hasSearchText.value = _searchController.text.trim().isNotEmpty;
    });

    Future.microtask(() {
      _fetchGyms();
      _getUserLocation();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _mapController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _hasSearchText.dispose();
    _isLocating.dispose();
    _userPosition.dispose();
    super.dispose();
  }

  Future<void> _fetchGyms({String? query}) async {
    final search = query ?? _searchController.text.trim();
    final userPos = _userPosition.value;
    await ref.read(publicGymsProvider.notifier).fetchGyms(
          search: search.isNotEmpty ? search : null,
          lat: userPos?.latitude,
          lng: userPos?.longitude,
        );
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
      _mapController.move(userLatLng, 13);
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

  void _focusGymOnMap(GymModel gym) {
    if (gym.latitude != 0 && gym.longitude != 0) {
      _mapController.move(LatLng(gym.latitude, gym.longitude), 15);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    if (authState != null && authState.authenticated) {
      return const AuthGate();
    }

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
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
            Tab(
              text: 'Planes Disponibles',
              icon: Icon(Icons.card_membership_rounded),
            ),
            Tab(
              text: 'Ubicaciones',
              icon: Icon(Icons.location_on_rounded),
            ),
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
          description:
              'Acceso total e ilimitado a todas nuestras sedes y clases.',
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
    final publicGymsState = ref.watch(publicGymsProvider);

    return publicGymsState.when(
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

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
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
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textSecondary,
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
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLocating,
                  builder: (context, locating, _) {
                    return ValueListenableBuilder<LatLng?>(
                      valueListenable: _userPosition,
                      builder: (context, userPos, _) {
                        final hasLocation = userPos != null;
                        return InkWell(
                          onTap: locating ? null : _getUserLocation,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: hasLocation
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: hasLocation
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (locating)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.my_location_rounded,
                                    size: 18,
                                    color: hasLocation
                                        ? AppColors.onPrimary
                                        : AppColors.primary,
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  hasLocation ? 'Cerca' : 'Ubicación',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: hasLocation
                                        ? AppColors.onPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: ValueListenableBuilder<LatLng?>(
                  valueListenable: _userPosition,
                  builder: (context, userPos, _) {
                    final initialCenter = userPos ??
                        (gymsWithCoords.isNotEmpty
                            ? LatLng(
                                gymsWithCoords.first.latitude,
                                gymsWithCoords.first.longitude,
                              )
                            : const LatLng(19.4194, -99.1622));

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: userPos != null ? 13.0 : 12.0,
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
                                        color: AppColors.primary.withAlpha(120),
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
                              return Marker(
                                point: LatLng(gym.latitude, gym.longitude),
                                width: 44,
                                height: 44,
                                child: GestureDetector(
                                  onTap: () {
                                    _focusGymOnMap(gym);
                                    GymDetailModal.show(
                                      context,
                                      gym: gym,
                                      distanceText: _getDistanceString(gym),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(150),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
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
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sedes Disponibles',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${gyms.length} ${gyms.length == 1 ? "sede" : "sedes"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (gyms.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 44,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se encontraron sedes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Intenta cambiar los términos de búsqueda o refresca tu ubicación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _clearSearch,
                      child: const Text('Limpiar Filtros'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gyms.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final gym = gyms[index];
                  final distance = _getDistanceString(gym);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              color: AppColors.background,
                              child: gym.backgroundUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: gym.backgroundUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Icon(
                                          Icons.fitness_center_rounded,
                                          size: 40,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        size: 40,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (gym.isOpen
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withAlpha(220),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  gym.isOpen ? 'Abierto' : 'Cerrado',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (distance.isNotEmpty)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(180),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.navigation_rounded,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        distance,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      gym.address.isNotEmpty
                                          ? gym.address
                                          : 'Dirección no disponible',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (gym.phone.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      gym.phone,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _focusGymOnMap(gym),
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
                                        Icons.map_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Ubicar',
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
                                          gym: gym,
                                          distanceText: distance,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.onPrimary,
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
                                        'Detalles',
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
                  );
                },
              ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }

  void _goToRegister() {
    CustomNavigator.pushFade(context, const RegisterScreen());
  }
}
