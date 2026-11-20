# Manual de Integración: Dio, Riverpod y Consumo de Endpoints en Fitbase

Esta guía detalla la arquitectura de red con **Dio**, la gestión reactiva de estado con **Riverpod (3.x)**, el mapa completo de endpoints y el procedimiento para consumir y mutar datos desde cualquier pantalla (`Screen`) o widget del ecosistema **Fitbase**.

---

## Enlaces del Proyecto

* **Descarga del APK (Android Release)**: [https://zurl.mmabitec.uk/nbQlPz](https://zurl.mmabitec.uk/nbQlPz)
* **Repositorio del Backend (API REST)**: [https://github.com/Moisessantos45/fitbase_backend](https://github.com/Moisessantos45/fitbase_backend)
* **Repositorio de la Aplicación Móvil**: [https://github.com/Moisessantos45/fitbase](https://github.com/Moisessantos45/fitbase)

---

## 1. Configuración y Cómo Hacer Funcionar el Proyecto

### A. Variables de Entorno
La aplicación utiliza `--dart-define-from-file` para alimentar la clase `Env` (`lib/config/env.dart`). Es necesario crear el archivo `env.dev.json` en la raíz del proyecto:

```json
{
  "API_BASE_V1": "https://fitbase.mmabitec.uk/api/v1"
}
```

### B. Comandos de Ejecución y Compilación
```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en modo desarrollo
flutter run --dart-define-from-file=./env.dev.json

# 3. Compilar APK para producción (con ofuscación y reglas R8)
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 2. Mapa de Archivos y Responsabilidades

| Componente | Ubicación en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Variables de Entorno** | `lib/config/env.dart` | Expone `apiBaseV1` inyectada mediante `env.dev.json`. |
| **Clientes HTTP (Dio)** | `lib/config/api.dart` | Exporta `apiAuth` y `apiPublic` con interceptores, idempotencia y cola de refresco. |
| **Entidades de Dominio** | `lib/domain/<entidad>_model.dart` | Clases de datos inmutables y puras, sin acoplamiento a frameworks de red. |
| **Estados de Dominio** | `lib/domain/<entidad>_state.dart` | Estructuras de estado inmutable para Providers y Notifiers complejos. |
| **Mappers de Datos** | `lib/infrastructure/mappers/<entidad>_mapper.dart` | Desempaquetado seguro sin `as`, utilizando `tryParse` y validación booleana segura. |
| **Providers de Riverpod** | `lib/presentation/providers/<entidad>_provider.dart` | Lógica de negocio, consumo de endpoints y emisión de estados (`AsyncNotifier`). |
| **Pantallas (Screens)** | `lib/presentation/screens/<modulo>/<pantalla>_screen.dart` | Vistas principales agrupadas por rol (`admin/`, `auth/`, `guest/`, `manger/`, `user/`). |
| **Widgets de Módulo** | `lib/presentation/widgets/<modulo>/<widget>.dart` | Componentes encapsulados por función (`manger/`, `subscription/`, `daypass/`, `payment/`). |
| **Widgets Globales** | `lib/presentation/widgets/` o `widgets/common/` | Componentes transversales (`custom_button.dart`, `gym_detail_modal.dart`). |

---

## 3. Funcionamiento Interno de Dio (`lib/config/api.dart`)

El proyecto dispone de dos instancias centralizadas de `Dio`:

### A. `apiPublic`
* **Propósito**: Endpoints accesibles sin sesión iniciada (`/auth/login-mobile`, `/auth/register`, `/auth/forgot-password`, `/payments/stripe/guest-checkout`, `/payments/stripe/session/:id`, `/daypass/guest`, `/gyms/public`).
* **Idempotencia Automática**: En peticiones `POST`, `PUT` y `PATCH`, intercepta la llamada y genera la cabecera `X-Idempotency-Key` (UUID v4) calculada a partir de la firma `método + endpoint + payload`. Remueve la clave al recibir respuesta exitosa.

### B. `apiAuth`
* **Propósito**: Cualquier ruta protegida por JWT (roles Usuario, Propietario o Encargado de mostrador).
* **Inyección de Token**: Lee el token activo desde `authProvider` en memoria y añade la cabecera `Authorization: Bearer <token>`.
* **Cola Concurrente y Auto-Refresh ante error 401**:
  1. Si un endpoint protegido responde con `401 Unauthorized`:
  2. Si ya hay una renovación en curso (`_isRefreshing == true`), la petición actual genera un `Completer` y se encola en `_failedQueue`.
  3. Si es la primera en fallar, bloquea la cola y ejecuta el callback de refresco.
  4. Lee el `refresh_token` de `FlutterSecureStorage` y realiza una petición a `POST /auth/refresh-token-mobile`.
  5. Recibe el nuevo par de tokens (`access_token` en memoria y nuevo `refresh_token` seguro).
  6. Reintenta la petición original con `dio.fetch` y desbloquea todas las solicitudes encoladas en `_failedQueue` actualizándoles la cabecera.
  7. Si el refresco falla (token expirado o revocado en Redis), se destruye la sesión y se redirige a la pantalla de login.

---

## 4. Catálogo de Endpoints y Providers Asociados

### A. Autenticación y Perfil (`authProvider`, `userProvider`)
* `POST /auth/login-mobile`: Inicio de sesión (devuelve tokens y rol: `1=Usuario`, `2=Dueño`, `3=Manager`).
* `POST /auth/register`: Registro de usuario con selector de tipo de cuenta (`Usuario` o `Dueño`).
* `POST /auth/refresh-token-mobile`: Renovación silenciosa de credenciales.
* `POST /auth/logout-mobile`: Revocación de tokens en Redis (`blacklist`).
* `GET /users/me`: Consulta de perfil del usuario logueado.
* `POST /users`: Creación inicial de datos de perfil de usuario.
* `PUT /users/me`: Actualización de perfil del usuario.

### B. Membresías y Suscripciones (`userSubscriptionsProvider`, `planProvider`)
* `GET /subscriptions/my-subscriptions`: Lista de membresías históricas y activas del usuario.
* `POST /subscriptions/subscribe`: Alta de nueva suscripción en un gimnasio.
* `POST /subscriptions/:id/cancel`: Cancelación voluntaria de membresía activa.
* `GET /gyms/:gymId/plans`: Catálogo de planes y membresías ofertadas por sede.
* `GET /gyms/:gymId/plans/enrollment`: Información combinada de membresía actual y planes disponibles.

### C. Transacciones y Pasarela Stripe (`paymentProvider`, `userPaymentsProvider`, `gymPaymentsProvider`)
* `GET /payments/my-payments`: Historial de facturas y recibos de pago del usuario logueado.
* `POST /payments/stripe/checkout-session`: Creación de sesión Stripe Checkout para suscripción autenticada.
* `POST /payments/stripe/guest-checkout`: Creación de sesión Stripe Checkout para pases de invitado sin cuenta.
* `GET /payments/stripe/session/:sessionId`: Verificación pública o autenticada del estatus de pago (`complete`, `paid`).
* `POST /payments/cash`: Registro de cobro en efectivo desde el mostrador por el Gym Manager.
* `GET /gyms/:gymId/payments`: Auditoría de pagos recibidos en una sede específica.
* `GET /gyms/:gymId/payments/revenue`: Métricas acumuladas de facturación por sede.

### D. Caja y Turno de Mostrador (`cashRegisterProvider`)
* `GET /cash-registers/current`: Estado de la caja actual para el Gym Manager (abierta o cerrada).
* `POST /cash-registers/open`: Apertura de turno con monto inicial en efectivo.
* `POST /cash-registers/close`: Cierre de turno, arqueo con efectivo final contado y notas del turno.

### E. Control de Accesos y Asistencia (`counterCheckInProvider`, `dayPassProvider`)
* `POST /checkin`: Registro de acceso por QR o email para miembros con membresía activa.
* `POST /daypass/verify`: Validación y consumo del pase de un día en mostrador.
* `GET /daypass/pending`: Lista de pases pendientes de uso o cobro en sede.

---

## 5. Patrón Paso a Paso para Consumir un Endpoint

### Paso 1: Definir la Entidad de Dominio (`lib/domain/`)
```dart
class MyEntity {
  final int id;
  final String title;

  const MyEntity({this.id = 0, this.title = ''});
}
```

### Paso 2: Crear el Mapper Seguro (`lib/infrastructure/mappers/`)
```dart
class MyEntityMapper {
  static Map<String, dynamic> toSafeMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }

  static MyEntity fromMap(Map<String, dynamic> map) {
    return MyEntity(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      title: map['title']?.toString() ?? '',
    );
  }
}
```

### Paso 3: Crear el AsyncNotifier (`lib/presentation/providers/`)
```dart
class MyEntityNotifier extends AsyncNotifier<List<MyEntity>> {
  @override
  Future<List<MyEntity>> build() async {
    return getEntities();
  }

  Future<List<MyEntity>> getEntities() async {
    state = const AsyncLoading();
    try {
      final res = await apiAuth.get('/my-endpoint');
      final resMap = MyEntityMapper.toSafeMap(res.data);
      final rawList = resMap['data'] as List? ?? [];
      final list = rawList
          .map((item) => MyEntityMapper.fromMap(MyEntityMapper.toSafeMap(item)))
          .toList();
      state = AsyncData(list);
      return list;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return const [];
    }
  }
}

final myEntityProvider = AsyncNotifierProvider<MyEntityNotifier, List<MyEntity>>(
  MyEntityNotifier.new,
);
```

### Paso 4: Consumir en la Vista con `when(...)` y `ValueNotifier`
```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(myEntityProvider);

    return Scaffold(
      body: stateAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) => ListTile(title: Text(items[i].title)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
```

---

## 6. Estándares Obligatorios de Codificación

1. **Cero Comentarios**: Ningún archivo fuente `.dart` debe incluir comentarios de línea (`//`) ni de bloque (`/* */`, `///`).
2. **Sin Casteos Débiles**: Prohibido usar `as String`, `as int`, `as Map` en mappers. Utilizar `tryParse`, `toString()`, `toSafeMap` y validación booleana segura.
3. **Estado Local**: Usar obligatoriamente `ValueNotifier<T>` y `ValueListenableBuilder<T>` para banderas y variables de estado local (`_loading`, `_obscurePassword`, filtros). Evitar `setState` salvo en variables de tipo `TextEditingController`.
4. **Separación de Widgets**: Todo widget secundario exclusivo de una pantalla debe residir en su subcarpeta correspondiente dentro de `lib/presentation/widgets/<modulo>/`.
