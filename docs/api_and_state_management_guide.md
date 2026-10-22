# Manual de Integración: Dio, Riverpod y Consumo de Endpoints en Fitbase

Esta guía detalla el funcionamiento interno de la capa de red con **Dio**, la gestión de estado con **Riverpod (3.x)** y el paso a paso para implementar y consumir un nuevo endpoint desde cualquier pantalla (`Screen`) o widget del proyecto.

---

## 1. Mapa de Archivos y Dónde Encontrar Cada Clase

| Componente | Ubicación en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Variables de Entorno** | `lib/config/env.dart` | Contiene la clase `Env` que expone `apiBaseV1`, leída de `--dart-define-from-file=./env.dev.json`. |
| **Clientes HTTP (Dio)** | `lib/config/api.dart` | Exporta las instancias globales `apiAuth` y `apiPublic` con interceptores, idempotencia y autorefresco de tokens. |
| **Entidades de Dominio** | `lib/domain/<entidad>_model.dart` | Define los datos puros sin dependencias externas ni parseo sucio. |
| **Estados de Dominio** | `lib/domain/<entidad>_state.dart` | Define la estructura de estado inmutable para los Notifiers. |
| **Mappers de Datos** | `lib/infrastructure/mappers/<entidad>_mapper.dart` | Convierte de forma segura entre `Map<String, dynamic>` y la entidad, **sin usar `as`**. |
| **Providers de Riverpod** | `lib/presentation/providers/<entidad>_provider.dart` | Lógica de negocio, gestión de llamadas a la API y mutación del estado. |
| **Pantallas (Screens)** | `lib/presentation/screens/<modulo>/<pantalla>_screen.dart` | Vistas principales de la app agrupadas por módulo (`auth/`, `user/`, `admin/`, etc.). |
| **Widgets Exclusivos** | `lib/presentation/widgets/<pantalla>/<widget>.dart` | Componentes privados exclusivos de una pantalla para evitar saturación en la raíz. |
| **Widgets Compartidos** | `lib/presentation/widgets/` o `widgets/common/` | Componentes reutilizables en toda la aplicación (`custom_button.dart`, etc.). |

---

## 2. Cómo Funciona Dio Internamente (`lib/config/api.dart`)

El proyecto cuenta con dos instancias centralizadas de `Dio`:

### A. `apiPublic`
* **Para qué se usa**: Rutas que no requieren token de sesión previo (`/auth/login-mobile`, `/auth/register`, `/auth/refresh-token-mobile`, `/auth/forgot-password`).
* **Idempotencia automática**: Intercepta automáticamente peticiones `POST`, `PUT` y `PATCH`, generando una cabecera `X-Idempotency-Key` única (UUID v4) a partir de la huella digital (`método + ruta + body`). Limpia la clave al resolverse la respuesta.

### B. `apiAuth`
* **Para qué se usa**: Cualquier ruta protegida de la aplicación.
* **Inyección de Token**: Lee el token de acceso desde la memoria del `authProvider` e inyecta la cabecera `Authorization: Bearer <access_token>`.
* **Cola de Espera y Auto-Refresh ante 401**:
  1. Si una petición responde con código `401 Unauthorized`:
  2. Si ya hay una renovación en progreso (`_isRefreshing = true`), la petición crea un `Completer` y se encola en `_failedQueue`.
  3. Si es la primera en fallar, activa `_isRefreshing = true` y ejecuta el callback de refresco.
  4. El callback toma el `refresh_token` almacenado de forma segura en `FlutterSecureStorage` y llama a `POST /auth/refresh-token-mobile`.
  5. Con el nuevo par de credenciales (`access_token` en memoria y `refresh_token` en almacenamiento seguro), se liberan todas las peticiones encoladas en `_failedQueue` inyectándoles el nuevo token y se reintenta la petición original con `dio.fetch`.
  6. Si el refresco falla, se limpia la sesión y se rechazan las peticiones pendientes.

---

## 3. Estado Global de Autenticación (`lib/presentation/providers/auth_provider.dart`)

Expone `authProvider` mediante `AsyncNotifierProvider`:

```dart
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

### Métodos disponibles para usar en la UI:
* **Iniciar Sesión**: Llama a `/auth/login-mobile`, guarda `refresh_token` en `FlutterSecureStorage` y `access_token` en memoria.
  ```dart
  await ref.read(authProvider.notifier).login(email, password);
  ```
* **Cerrar Sesión**: Llama a `POST /auth/logout-mobile`, revoca ambos tokens en Redis (`blacklist`), borra `FlutterSecureStorage` y restablece el estado.
  ```dart
  await ref.read(authProvider.notifier).logout();
  ```
* **Consultar Token Actual en Memoria**:
  ```dart
  final token = ref.read(authProvider.notifier).getToken();
  ```
* **Validar Sesión Activa**: Consulta `GET /auth/session` revalidando el estado del usuario.
  ```dart
  await ref.read(authProvider.notifier).getSession();
  ```

---

## 4. Guía Paso a Paso: Cómo Implementar un Nuevo Endpoint

Ejemplo práctico: Implementar la entidad **Gimnasio (`Gym`)** con listado y creación.

### Paso 1: Crear la Entidad en Dominio
Archivo: `lib/domain/gym_model.dart`

```dart
class Gym {
  final int id;
  final String name;
  final String address;
  final double rating;
  final bool isActive;

  const Gym({
    this.id = 0,
    this.name = '',
    this.address = '',
    this.rating = 0.0,
    this.isActive = false,
  });
}
```

---

### Paso 2: Crear el Mapper Seguro en Infraestructura
Archivo: `lib/infrastructure/mappers/gym_mapper.dart`
*(Aplicar la regla de oro: cero `as`)*

```dart
import 'package:fitbase/domain/gym_model.dart';

class GymMapper {
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

  static Gym fromMap(Map<String, dynamic> map) {
    return Gym(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0.0,
      isActive: map['is_active'] == true ||
          map['is_active']?.toString().toLowerCase() == 'true',
    );
  }

  static Map<String, dynamic> toMap(Gym gym) {
    return {
      'id': gym.id,
      'name': gym.name,
      'address': gym.address,
      'rating': gym.rating,
      'is_active': gym.isActive,
    };
  }
}
```

---

### Paso 3: Crear el Provider en Presentación
Archivo: `lib/presentation/providers/gym_provider.dart`

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/config/api.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/infrastructure/mappers/gym_mapper.dart';

class GymNotifier extends AsyncNotifier<List<Gym>> {
  List<Gym> get _current => state.value ?? const [];

  @override
  Future<List<Gym>> build() async {
    return _fetchGyms();
  }

  Future<List<Gym>> _fetchGyms() async {
    final res = await apiAuth.get('/gyms');
    final resMap = GymMapper.toSafeMap(res.data);
    final rawList = resMap['data'];

    if (rawList is List) {
      return rawList
          .whereType<Map>()
          .map((item) => GymMapper.fromMap(GymMapper.toSafeMap(item)))
          .toList();
    }
    return [];
  }

  Future<void> createGym(String name, String address) async {
    state = const AsyncLoading();
    try {
      await apiAuth.post('/gyms', data: {
        'name': name,
        'address': address,
      });
      final updatedList = await _fetchGyms();
      state = AsyncData(updatedList);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchGyms());
  }
}

final gymProvider = AsyncNotifierProvider<GymNotifier, List<Gym>>(
  GymNotifier.new,
);
```

---

### Paso 4: Crear la Pantalla y Widgets Exclusivos

* Crear la pantalla en: `lib/presentation/screens/user/gym_list_screen.dart`
* Crear los widgets exclusivos de la pantalla en: `lib/presentation/widgets/gym_list/gym_item_card.dart`

#### Widget Exclusivo (`lib/presentation/widgets/gym_list/gym_item_card.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:fitbase/domain/gym_model.dart';
import 'package:fitbase/config/theme/app_colors.dart';

class GymItemCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback? onTap;

  const GymItemCard({super.key, required this.gym, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(gym.name, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(gym.address, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: Text('${gym.rating} ★', style: const TextStyle(color: AppColors.primary)),
        onTap: onTap,
      ),
    );
  }
}
```

#### Pantalla (`lib/presentation/screens/user/gym_list_screen.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/presentation/providers/gym_provider.dart';
import 'package:fitbase/presentation/widgets/gym_list/gym_item_card.dart';
import 'package:fitbase/config/theme/app_colors.dart';

class GymListScreen extends ConsumerWidget {
  const GymListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsyncValue = ref.watch(gymProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gimnasios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(gymProvider.notifier).refresh(),
          ),
        ],
      ),
      body: gymAsyncValue.when(
        data: (gyms) {
          if (gyms.isEmpty) {
            return const Center(
              child: Text(
                'No hay gimnasios disponibles',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            itemCount: gyms.length,
            itemBuilder: (context, index) {
              return GymItemCard(gym: gyms[index]);
            },
          );
        },
        loading: () => const Center(
          child: RepaintBoundary(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
```

---

## 5. Resumen de Buenas Prácticas al Escribir Código

1. **Lectura vs Mutación en Riverpod**:
   * Para pintar la UI y reaccionar a cambios: **`ref.watch(miProvider)`**.
   * Para disparar acciones en callbacks (`onPressed`, `onTap`): **`ref.read(miProvider.notifier).miMetodo(...)`**. Nunca usar `watch` dentro de un botón o función de evento.
2. **Cero Comentarios**: Ningún archivo Dart debe contener comentarios (`//`, `/* */`).
3. **Parseo Seguro en Mappers**: Utilizar siempre `tryParse` y validación segura booleana.
4. **Organización de Widgets**: Todo widget creado exclusivamente para una pantalla debe ir en `widgets/<pantalla>/`.
