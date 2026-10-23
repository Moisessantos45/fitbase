import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/config/navigation/custom_navigator.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/widgets/custom_button.dart';
import 'package:fitbase/presentation/widgets/custom_text_field.dart';
import 'package:fitbase/presentation/screens/admin/admin_settings_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitbase/presentation/screens/common/map_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitbase/presentation/widgets/image_source_sheet.dart';

class AdminGymEditScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const AdminGymEditScreen({super.key, this.isModal = false});

  @override
  ConsumerState<AdminGymEditScreen> createState() => _AdminGymEditScreenState();
}

class _AdminGymEditScreenState extends ConsumerState<AdminGymEditScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final _loading = ValueNotifier<bool>(false);
  final _uploadingCover = ValueNotifier<bool>(false);
  final _uploadingPhotos = ValueNotifier<bool>(false);
  int _lastLoadedGymId = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gymProvider.notifier).getMyGym();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _loading.dispose();
    _uploadingCover.dispose();
    _uploadingPhotos.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCover(int gymId) async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await ImageSourceSheet.show(context);
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    _uploadingCover.value = true;
    try {
      final msg = await ref
          .read(gymProvider.notifier)
          .uploadCover(gymId: gymId, filePath: picked.path);
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(msg)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
      );
    } finally {
      _uploadingCover.value = false;
    }
  }

  Future<void> _pickAndUploadPhotos(int gymId) async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final List<XFile> pickedList = await picker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedList.isEmpty) return;

    _uploadingPhotos.value = true;
    try {
      final msg = await ref
          .read(gymProvider.notifier)
          .uploadPhotos(
            gymId: gymId,
            filePaths: pickedList.map((f) => f.path).toList(),
          );
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(msg)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
      );
    } finally {
      _uploadingPhotos.value = false;
    }
  }

  void _syncControllers(GymModel gym) {
    if (_lastLoadedGymId != gym.id) {
      _lastLoadedGymId = gym.id;
      _nameController.text = gym.name;
      _addressController.text = gym.address;
      _phoneController.text = gym.phone;
      _emailController.text = gym.email;
      _latController.text = gym.latitude.toString();
      _lngController.text = gym.longitude.toString();
    }
  }

  Future<void> _handleSave(GymModel gym) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (name.isEmpty || address.isEmpty || phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Por favor completa todos los campos requeridos.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    _loading.value = true;

    try {
      final msg = await ref
          .read(gymProvider.notifier)
          .updateGym(
            id: gym.id,
            name: name,
            address: address,
            phone: phone,
            email: email,
            latitude: lat,
            longitude: lng,
          );

      _loading.value = false;
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(msg)),
      );
    } catch (e) {
      _loading.value = false;
      messenger.showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
      );
    }
  }

  void _showEditScheduleDialog(GymModel gym, GymScheduleItem item) {
    final isClosedNotifier = ValueNotifier<bool>(item.isClosed);
    final openMinutesNotifier = ValueNotifier<int>(item.openMinutes);
    final closeMinutesNotifier = ValueNotifier<int>(item.closeMinutes);
    final dialogLoading = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Horario: ${item.dayName}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isClosedNotifier,
                builder: (context, isClosed, _) {
                  return SwitchListTile(
                    title: const Text(
                      'Cerrado este día',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: isClosed,
                    activeThumbColor: AppColors.error,
                    activeTrackColor: AppColors.error.withAlpha(80),
                    onChanged: (val) {
                      isClosedNotifier.value = val;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: isClosedNotifier,
                builder: (context, isClosed, _) {
                  if (isClosed) return const SizedBox.shrink();

                  return Column(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: openMinutesNotifier,
                        builder: (context, openMins, _) {
                          final h = (openMins ~/ 60).toString().padLeft(2, '0');
                          final m = (openMins % 60).toString().padLeft(2, '0');
                          return ListTile(
                            leading: const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Hora de Apertura',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            trailing: Text(
                              '$h:$m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: openMins ~/ 60,
                                  minute: openMins % 60,
                                ),
                              );
                              if (picked != null) {
                                openMinutesNotifier.value =
                                    picked.hour * 60 + picked.minute;
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: closeMinutesNotifier,
                        builder: (context, closeMins, _) {
                          final h = (closeMins ~/ 60).toString().padLeft(
                            2,
                            '0',
                          );
                          final m = (closeMins % 60).toString().padLeft(2, '0');
                          return ListTile(
                            leading: const Icon(
                              Icons.lock_clock_outlined,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Hora de Cierre',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            trailing: Text(
                              '$h:$m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: closeMins ~/ 60,
                                  minute: closeMins % 60,
                                ),
                              );
                              if (picked != null) {
                                closeMinutesNotifier.value =
                                    picked.hour * 60 + picked.minute;
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: dialogLoading,
            builder: (context, loading, _) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);

                        dialogLoading.value = true;
                        try {
                          final msg = await ref
                              .read(gymProvider.notifier)
                              .updateSchedule(
                                gymId: gym.id,
                                scheduleId: item.id,
                                openMinutes: isClosedNotifier.value
                                    ? 0
                                    : openMinutesNotifier.value,
                                closeMinutes: isClosedNotifier.value
                                    ? 0
                                    : closeMinutesNotifier.value,
                                isClosed: isClosedNotifier.value,
                              );
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text(msg),
                            ),
                          );
                        } catch (e) {
                          dialogLoading.value = false;
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.error,
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                child: Text(
                  loading ? 'Guardando...' : 'Guardar',
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateGymDialog() {
    final createName = TextEditingController();
    final createAddress = TextEditingController();
    final createPhone = TextEditingController();
    final createEmail = TextEditingController();
    final createLat = TextEditingController(text: '19.4194');
    final createLng = TextEditingController(text: '-99.1622');
    final dialogLoading = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Dar de Alta Sede',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Nombre de Sede',
                controller: createName,
                hintText: 'Ej. Fitbase Polanco',
                prefixIcon: Icons.fitness_center,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Dirección',
                controller: createAddress,
                hintText: 'Calle, número y colonia',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Teléfono',
                controller: createPhone,
                hintText: 'Número de contacto',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Correo de Contacto',
                controller: createEmail,
                hintText: 'correo@fitbase.io',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Latitud',
                      controller: createLat,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      label: 'Longitud',
                      controller: createLng,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.map_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: const Text(
                  'Fijar en Mapa',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final curLat =
                      double.tryParse(createLat.text.trim()) ?? 19.4194;
                  final curLng =
                      double.tryParse(createLng.text.trim()) ?? -99.1622;
                  final picked = await CustomNavigator.pushFade<LatLng>(
                    context,
                    MapPickerScreen(
                      initialLatitude: curLat,
                      initialLongitude: curLng,
                      title: 'Ubicación Nueva Sede',
                    ),
                  );
                  if (picked != null) {
                    createLat.text = picked.latitude.toStringAsFixed(6);
                    createLng.text = picked.longitude.toStringAsFixed(6);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: dialogLoading,
            builder: (context, loading, _) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        final n = createName.text.trim();
                        final a = createAddress.text.trim();
                        final p = createPhone.text.trim();
                        final e = createEmail.text.trim();
                        final lat =
                            double.tryParse(createLat.text.trim()) ?? 0.0;
                        final lng =
                            double.tryParse(createLng.text.trim()) ?? 0.0;

                        if (n.isEmpty || a.isEmpty || p.isEmpty || e.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.error,
                              content: Text('Completa todos los campos.'),
                            ),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);

                        dialogLoading.value = true;
                        try {
                          await ref
                              .read(gymProvider.notifier)
                              .createGym(
                                name: n,
                                address: a,
                                phone: p,
                                email: e,
                                latitude: lat,
                                longitude: lng,
                              );
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text('Gimnasio creado exitosamente'),
                            ),
                          );
                        } catch (err) {
                          dialogLoading.value = false;
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.error,
                              content: Text(err.toString()),
                            ),
                          );
                        }
                      },
                child: Text(
                  loading ? 'Creando...' : 'Crear Sede',
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymAsync = ref.watch(gymProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          'Datos del Gimnasio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              ref.read(gymProvider.notifier).getMyGym();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              CustomNavigator.pushFade(context, const AdminSettingsScreen());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: gymAsync.when(
        data: (gym) {
          if (gym == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No tienes una sede registrada aún',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra los datos de tu gimnasio para configurar horarios y fotos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      text: 'Registrar Sede de Gimnasio',
                      icon: Icons.add_business_rounded,
                      onPressed: _showCreateGymDialog,
                    ),
                  ],
                ),
              ),
            );
          }

          _syncControllers(gym);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _uploadingCover,
                  builder: (context, uploadingCover, _) {
                    if (gym.backgroundUrl.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(gym.backgroundUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha(180),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  gym.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.black54,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: uploadingCover
                                      ? null
                                      : () => _pickAndUploadCover(gym.id),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: uploadingCover
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Cambiar Portada',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Material(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: uploadingCover
                            ? null
                            : () => _pickAndUploadCover(gym.id),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: uploadingCover
                              ? const CircularProgressIndicator(
                                  color: AppColors.primary,
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 36,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Subir Foto de Portada',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Formatos JPG, PNG o WebP',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
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
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gym.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gym.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gym.isOpen
                              ? AppColors.success.withAlpha(40)
                              : AppColors.error.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gym.isOpen ? 'Abierto' : 'Cerrado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: gym.isOpen
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Datos Generales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Nombre de la Sede',
                  controller: _nameController,
                  prefixIcon: Icons.fitness_center_rounded,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Dirección Física',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
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
                        label: 'Correo de Contacto',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Latitud',
                        controller: _latController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Longitud',
                        controller: _lngController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.explore_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final lat =
                          double.tryParse(_latController.text.trim()) ??
                          19.4194;
                      final lng =
                          double.tryParse(_lngController.text.trim()) ??
                          -99.1622;
                      final picked = await CustomNavigator.pushFade<LatLng>(
                        context,
                        MapPickerScreen(
                          initialLatitude: lat,
                          initialLongitude: lng,
                          title: 'Ubicación de la Sede',
                        ),
                      );
                      if (picked != null) {
                        _latController.text = picked.latitude.toStringAsFixed(
                          6,
                        );
                        _lngController.text = picked.longitude.toStringAsFixed(
                          6,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.map_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seleccionar Coordenadas en Mapa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Toca aquí para abrir el mapa interactivo y fijar el pin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Horarios Semanales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${gym.schedules.length} configurados',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gym.schedules.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = gym.schedules[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          item.dayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.formattedHours,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: item.isClosed
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_calendar_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _showEditScheduleDialog(gym, item);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Galería de Fotos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _uploadingPhotos,
                      builder: (context, uploading, _) {
                        return TextButton.icon(
                          onPressed: uploading
                              ? null
                              : () => _pickAndUploadPhotos(gym.id),
                          icon: uploading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                          label: Text(
                            uploading ? 'Subiendo...' : 'Añadir Fotos',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (gym.photos.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gym.photos.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Material(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _pickAndUploadPhotos(gym.id),
                              child: Container(
                                width: 100,
                                height: 110,
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Añadir Más',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final photo = gym.photos[index - 1];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                photo.url,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 110,
                                      height: 110,
                                      color: AppColors.surfaceLight,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  try {
                                    final msg = await ref
                                        .read(gymProvider.notifier)
                                        .deletePhoto(
                                          gymId: gym.id,
                                          photoId: photo.id,
                                        );
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.success,
                                        content: Text(msg),
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.error,
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _pickAndUploadPhotos(gym.id),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: const Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 36,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aún no has agregado fotos de tus instalaciones',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Toca aquí para seleccionar una o varias fotos de la galería',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, loading, _) {
                    return CustomButton(
                      text: loading
                          ? 'Guardando cambios...'
                          : 'Guardar Cambios de Sede',
                      icon: loading ? null : Icons.save_rounded,
                      onPressed: loading ? () {} : () => _handleSave(gym),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error al cargar los datos del gimnasio:\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Reintentar',
                  onPressed: () {
                    ref.read(gymProvider.notifier).getMyGym();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
