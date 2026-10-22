# Guía de Arquitectura, Providers y Consumo de APIs en Fitbase

Esta guía documenta los estándares de Clean Architecture, la nomenclatura de archivos, la creación de Providers con la versión moderna de Riverpod (3.x), la regla de oro para Mappers y el consumo del cliente HTTP (Dio) en la UI.

---

## 1. Nomenclatura y Organización de Archivos

Todos los archivos deben nombrarse bajo el formato snake_case identificando la entidad y el rol que cumplen:
* **Entidades / Modelos**: `<entidad>_model.dart`
* **Estados**: `<entidad>_state.dart`
* **Mappers**: `<entidad>_mapper.dart`
* **Providers / Notifiers**: `<entidad>_provider.dart`
* **Widgets**: `<nombre_componente>.dart`

### Regla para el uso de subcarpetas (Domain, Infrastructure, Providers y Widgets):
* **`lib/domain/`**:
  * **Archivo único**: Directo en la raíz (ej. `lib/domain/user_model.dart`).
  * **Múltiples archivos**: Crear subcarpeta por entidad (ej. `lib/domain/user/user_model.dart`, `lib/domain/user/profile_model.dart`).
* **`lib/infrastructure/mappers/`**:
  * **Archivo único**: Directo en la raíz (ej. `lib/infrastructure/mappers/user_mapper.dart`).
  * **Múltiples archivos**: Crear subcarpeta por entidad (ej. `lib/infrastructure/mappers/user/user_mapper.dart`).
* **`lib/presentation/providers/`**:
  * **Archivo único**: Directo en la raíz (ej. `lib/presentation/providers/user_provider.dart`).
  * **Múltiples archivos**: Crear subcarpeta por entidad (ej. `lib/presentation/providers/user/user_provider.dart`).
* **`lib/presentation/widgets/`**:
  * **Widgets específicos de una pantalla**: Crear una carpeta dedicada para los widgets que pertenecen a una pantalla o entidad (ej. `lib/presentation/widgets/login/`, `lib/presentation/widgets/workout_detail/`) para evitar saturar la raíz o revolverlos con los de otras pantallas.
  * **Widgets genéricos / reutilizables**: Los componentes reutilizables transversales a toda la app (como `custom_button.dart`, `custom_text_field.dart`) van en la raíz de `lib/presentation/widgets/` o en `widgets/common/`.

---

## 2. Capa de Dominio (`lib/domain/`)

* Contiene las **entidades y modelos puros**.
* **Prohibido**: Depender de librerías de infraestructura como Dio o paquetes de terceros específicos de red o almacenamiento.
* Las entidades no contienen lógica de serialización `fromMap` o `as Map`, solo sus propiedades y métodos de dominio.

---

## 3. Capa de Infraestructura y Mappers (`lib/infrastructure/mappers/`)

### ⚠️ Regla de Oro de los Mappers: NUNCA usar `as`
El operador `as` de Dart rompe la aplicación en runtime si el backend envía un tipo inesperado (`null`, `int` en vez de `String`, etc.). 

#### Estándar de Mapeo Seguro:
```dart
class UserMapper {
  static Map<String, dynamic>? toNullableMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static Map<String, dynamic> toSafeMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return {};
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      isActive: map['is_active'] == true ||
          map['is_active']?.toString().toLowerCase() == 'true',
    );
  }

  static Map<String, dynamic> toMap(User user) {
    return {
      'id': user.id,
      'name': user.name,
      'price': user.price,
      'is_active': user.isActive,
    };
  }
}
```

---

## 4. Creación de Providers con Riverpod Moderno (3.x)

En Riverpod 2.x/3.x, los Notifiers se instancian utilizando el constructor tear-off (`.new`).

### A. Provider Asíncrono (`AsyncNotifier` + `AsyncNotifierProvider`)
Recomendado cuando el estado representa una carga asíncrona de datos:

```dart
final userNotifierProvider =
    AsyncNotifierProvider<UserNotifier, List<User>>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final res = await apiAuth.get('/users');
    final resMap = UserMapper.toSafeMap(res.data);
    final listRaw = resMap['data'];
    if (listRaw is List) {
      return listRaw
          .whereType<Map>()
          .map((item) => UserMapper.fromMap(UserMapper.toSafeMap(item)))
          .toList();
    }
    return [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }
}
```

### B. Provider con Parámetros (`family` en versión moderna)
```dart
final subfoldersProvider =
    AsyncNotifierProvider.family<SubfoldersNotifier, List<Subfolder>, String>(
  SubfoldersNotifier.new,
);

class SubfoldersNotifier extends FamilyAsyncNotifier<List<Subfolder>, String> {
  @override
  Future<List<Subfolder>> build(String arg) async {
    return _fetchSubfolders(arg);
  }

  Future<List<Subfolder>> _fetchSubfolders(String folderId) async {
    final res = await apiAuth.get('/folders/$folderId/subfolders');
    ...
  }
}
```

---

## 5. Consumo de Instancias de Dio (`apiAuth` y `apiPublic`)

Se encuentran centralizadas en `lib/config/api.dart`:

```dart
import 'package:fitbase/config/api.dart';
```

1. **`apiPublic`**:
   * Usada para rutas abiertas como `/auth/login-mobile`, `/auth/register`, `/auth/refresh-token-mobile`.
   * Incluye idempotencia automática (`X-Idempotency-Key`) en peticiones `POST`, `PUT` y `PATCH`.

2. **`apiAuth`**:
   * Usada para cualquier endpoint protegido.
   * Inyecta automáticamente el token de acceso `Authorization: Bearer <token>` desde memoria.
   * Maneja errores `401 Unauthorized` de forma transparente: pone en cola las peticiones concurrentes, ejecuta la rotación mediante el refresh token en almacenamiento seguro y reintenta todas las peticiones con las nuevas credenciales.

---

## 6. Consumo en la UI con Riverpod

Para consumir los providers en la interfaz se utiliza `ConsumerWidget` o `ConsumerStatefulWidget`, leyendo el estado reactivo mediante `ref.watch(...)` y renderizando mediante el método `.when(...)`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/theme/app_colors.dart';
import 'package:fitbase/presentation/providers/subfolders_provider.dart';

class FolderDetailView extends ConsumerWidget {
  final String folderId;
  const FolderDetailView({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subfoldersAsyncValue = ref.watch(subfoldersProvider(folderId));

    return CustomScrollView(
      slivers: [
        subfoldersAsyncValue.when(
          data: (subfolders) {
            if (subfolders.isEmpty) {
              return const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            }
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Subcarpetas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "${subfolders.length}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 106,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: subfolders.length,
                      itemBuilder: (context, index) {
                        final sub = subfolders[index];
                        return SubFolderItem(
                          name: sub.name,
                          captureCount: "${sub.captureCount}",
                          onTap: () => _openSubfolder(context, sub),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (error, stack) =>
              const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }

  void _openSubfolder(BuildContext context, dynamic subfolder) {}
}
```

---

## 7. Protección de Pantallas y Control de Acceso por Roles (`AuthGate` y `RoleGuard`)

Para replicar el comportamiento de los middlewares de rutas (como los de Nuxt/Vue) en Flutter nativo sin añadir librerías adicionales:

### A. Guardián Raíz Reactivo (`lib/presentation/screens/auth_gate.dart`)
Se establece como `home: const AuthGate()` en `MaterialApp`. Evalúa en tiempo real el estado de autenticación y roles de Riverpod:
1. **Sin autenticación**: Muestra `LoginScreen()`.
2. **Perfil Incompleto (`fullProfile == false`)**: Redirige forzosamente a la pantalla de completar perfil exclusiva de cada rol:
   * **Propietario / Dueño (`roleId == 2`)**: `AdminProfileScreen()` en `lib/presentation/screens/admin/admin_profile_screen.dart`.
   * **Gerente / Manager (`roleId == 3`)**: `ManagerProfileScreen()` en `lib/presentation/screens/manger/manager_profile_screen.dart`.
   * **Cliente / Usuario (`roleId == 1`)**: `UserProfileScreen()` en `lib/presentation/screens/user/user_profile_screen.dart`.
3. **Autenticado y Completo**:
   * Si es Propietario (`roleId == 2`) o Manager (`roleId == 3`): Muestra `AdminMainScreen()`.
   * Si es Cliente/Usuario (`roleId == 1`): Muestra `UserMainScreen()`.
4. **Verificación Inicial**: Mientras valida la sesión con `getSession()` en segundo plano, renderiza un loader con `RepaintBoundary`.

### B. Guardián de Roles en Navegación (`lib/config/navigation/custom_navigator.dart`)
Para proteger cualquier transición entre pantallas dentro de la app:

```dart
CustomNavigator.pushProtectedFade(
  context,
  ref,
  const AdminPlansScreen(),
  allowedRoles: [2, 3], // Solo Propietario o Manager
  deniedMessage: 'Sección exclusiva para administradores',
);
```

Si el usuario no cuenta con el rol requerido, bloquea la navegación y notifica al usuario con un `SnackBar`.

---

## 8. Optimización de Estado Local en Pantallas (`ValueNotifier` vs `setState`)

Para evitar reconstrucciones innecesarias de todo el árbol de widgets (`re-build`), se sigue estrictamente la siguiente regla:

### Regla:
* **Variables de estado local (`_submitted`, `_loading`, `_obscurePassword`, `_acceptTerms`, toggles, filtros)**: Deben declararse obligatoriamente con `ValueNotifier<T>` y consumirse puntualmente con `ValueListenableBuilder<T>`.
* **Liberación de memoria**: Todo `ValueNotifier` debe liberarse en el método `dispose()` de la pantalla mediante `.dispose()`.
* **Excepción estricta**: Los controladores de texto (`TextEditingController`) **no** se encapsulan en `ValueNotifier`, ya que son clases `ChangeNotifier` nativas de Flutter.

#### Ejemplo Canónico:
```dart
class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _submitted = ValueNotifier<bool>(false);
  final _loading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _submitted.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    _loading.value = true;
    try {
      await ref.read(authProvider.notifier).forgotPassword(email);
      _submitted.value = true;
      _loading.value = false;
    } catch (_) {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: _submitted,
        builder: (context, submitted, _) {
          if (submitted) return const SuccessView();
          return ValueListenableBuilder<bool>(
            valueListenable: _loading,
            builder: (context, loading, _) {
              return CustomButton(
                text: loading ? 'Enviando...' : 'Recuperar Contraseña',
                onPressed: loading ? null : _handleSubmit,
              );
            },
          );
        },
      ),
    );
  }
}
```

