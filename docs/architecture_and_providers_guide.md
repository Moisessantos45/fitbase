# Guía de Arquitectura, Providers y Consumo de APIs en Fitbase

Esta guía documenta los estándares de Clean Architecture, organización modular de archivos, creación de Providers bajo la versión moderna de **Riverpod (3.x)**, regla de oro para Mappers sin `as`, optimización de estado local con `ValueNotifier` y guardianes de navegación por roles en **Fitbase**.

---

## Enlaces del Proyecto

* **Descarga del APK (Android Release)**: [https://zurl.mmabitec.uk/nbQlPz](https://zurl.mmabitec.uk/nbQlPz)
* **Repositorio del Backend (API REST)**: [https://github.com/Moisessantos45/fitbase_backend](https://github.com/Moisessantos45/fitbase_backend)
* **Repositorio de la Aplicación Móvil**: [https://github.com/Moisessantos45/fitbase](https://github.com/Moisessantos45/fitbase)

---

## 1. Cómo Ejecutar y Compilar la Aplicación

### A. Requisitos
* Flutter SDK versión 3.24+ (Dart 3.5+)
* Dispositivo físico Android con depuración USB o emulador activo
* Archivo de variables de entorno `env.dev.json` en la raíz del proyecto:
  ```json
  {
    "API_BASE_V1": "https://fitbase.mmabitec.uk/api/v1"
  }
  ```

### B. Comandos Principales
```bash
# Instalar paquetes
flutter pub get

# Ejecución en modo desarrollo
flutter run --dart-define-from-file=./env.dev.json

# Compilación de APK Release para producción
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 2. Nomenclatura y Organización de Archivos

Todos los archivos deben nombrarse bajo el formato snake_case identificando la entidad y el rol que cumplen:
* **Entidades / Modelos**: `<entidad>_model.dart`
* **Estados**: `<entidad>_state.dart`
* **Mappers**: `<entidad>_mapper.dart`
* **Providers / Notifiers**: `<entidad>_provider.dart`
* **Widgets**: `<nombre_componente>.dart`

### Regla para el uso de subcarpetas:
* **`lib/domain/`**:
  * Contiene las entidades y estados puros desacoplados de cualquier librería externa o SDK de red.
  * Archivos individuales en la raíz (ej. `lib/domain/payment_model.dart`, `lib/domain/cash_register_model.dart`). Subcarpeta solo si son múltiples archivos dependientes de una misma entidad.
* **`lib/infrastructure/mappers/`**:
  * Contiene la lógica de transformación entre los mapas de datos de la API y las entidades de dominio.
  * Archivos individuales en la raíz (ej. `lib/infrastructure/mappers/payment_mapper.dart`).
* **`lib/presentation/providers/`**:
  * Notifiers y providers que gestionan la lógica de negocio y mutación de estado con Riverpod 3.x.
  * Archivos individuales en la raíz (ej. `lib/presentation/providers/user_provider.dart`).
* **`lib/presentation/widgets/`**:
  * **Widgets específicos de una pantalla o módulo**: Crear una carpeta dedicada por módulo o pantalla (ej. `lib/presentation/widgets/manger/`, `lib/presentation/widgets/subscription/`, `lib/presentation/widgets/daypass/`, `lib/presentation/widgets/payment/`) para evitar sobrecargar la raíz del proyecto.
  * **Widgets globales y transversales**: Ubicados en `lib/presentation/widgets/` o `lib/presentation/widgets/common/` (ej. `custom_button.dart`, `gym_detail_modal.dart`).

---

## 3. Capa de Dominio (`lib/domain/`)

* Las entidades representan los conceptos clave del negocio y son **100% inmutables**.
* **Prohibido**: Importar librerías de infraestructura como `dio`, `shared_preferences` o `flutter_secure_storage`.
* Las entidades no contienen constructores `fromMap` o `toJson`, solo sus atributos, constructor `const` con valores por defecto seguros y helpers computados de conveniencia (ej. `bool get isPaid`).

---

## 4. Capa de Infraestructura y Mappers (`lib/infrastructure/mappers/`)

### Regla de Oro: Prohibido usar `as` al desempaquetar JSON
Nunca se debe forzar el tipo con `as String`, `as int`, `as double`, `as bool` o `as Map<String, dynamic>`. Si el backend cambia un entero a `null`, envía un número como texto o modifica la estructura, la aplicación lanzará un error de tipo en tiempo de ejecución.

### Métodos Auxiliares Estándar:
Todo mapper debe incorporar helpers para sanear colecciones y mapas antes de leer sus campos:

```dart
class MyMapper {
  static Map<String, dynamic> toSafeMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }

  static Map<String, dynamic>? toNullableMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }
}
```

### Conversión Segura de Tipos:
* **Strings**: `map['name']?.toString() ?? ''`
* **Enteros**: `int.tryParse(map['id']?.toString() ?? '') ?? 0`
* **Decimales**: `double.tryParse(map['price']?.toString() ?? '') ?? 0.0`
* **Booleanos**: `map['is_active'] == true || map['is_active']?.toString().toLowerCase() == 'true'`
* **Listas**: Iterar mapeando cada elemento a través de `toNullableMap` para descartar registros nulos o corruptos.

---

## 5. Gestión de Estado con Riverpod 3.x (`lib/presentation/providers/`)

Se utiliza la versión moderna de Riverpod sin generadores de código para máxima claridad y control sobre el ciclo de vida.

### Reglas Esenciales:
1. **Constructor Tear-Off**: Declarar providers siempre utilizando la sintaxis de constructor tear-off (`.new`):
   ```dart
   final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
     UserNotifier.new,
   );
   ```
2. **Ciclo de Construcción Inmutable**: En notifiers de tipo `AsyncNotifier`, sobreescribir `build()` devolviendo el estado inicial o ejecutando la carga asíncrona primaria.
3. **Lectura y Mutación Segura**:
   * Para actualizar el estado manteniendo datos existentes: `state = AsyncData(nuevoValor);`
   * Para emitir estado de carga: `state = const AsyncLoading();`
   * Para emitir errores capturados: `state = AsyncError(e, stack);`

---

## 6. Consumo en la Interfaz de Usuario (`lib/presentation/screens/`)

### A. Consumir Estados Asíncronos con `when(...)`
```dart
final userAsync = ref.watch(userProvider);

return userAsync.when(
  data: (user) => UserProfileView(user: user),
  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
  error: (err, stack) => Center(child: Text('Error: $err')),
);
```

### B. Disparo de Acciones en Eventos
* **Prohibido**: Utilizar `ref.watch` dentro de manejadores de eventos (`onPressed`, `onTap`, `initState`).
* **Correcto**: Utilizar `ref.read(miProvider.notifier).miMetodo(...)`.

---

## 7. Control de Acceso y Navegación Protegida por Roles

Fitbase cuenta con 4 roles de acceso definidos:
* **Rol 1 (`Usuario / Cliente`)**: Acceso a `UserMainScreen()` (dashboard deportivo, credencial QR, membresías y pagos).
* **Rol 2 (`Dueño / Propietario`)**: Acceso a `AdminMainScreen()` (gestión financiera, sedes, planes y padrón de socios).
* **Rol 3 (`Gym Manager / Mostrador`)**: Acceso a `ManagerMainScreen()` (apertura y cierre de caja, cobro en recepción y escáner QR de pases y asistencias).
* **Invitado (`Guest`)**: Acceso a `GuestHomeScreen()` para exploración libre y compra de pases individuales sin cuenta previa.

### Guardián Centralizado: `AuthGate`
Determina la pantalla inicial según la persistencia de sesión:
1. Si no hay sesión iniciada (`roleId == null`): Redirige a `GuestHomeScreen()`.
2. Si el rol es 1: Muestra `UserMainScreen()`.
3. Si el rol es 2: Muestra `AdminMainScreen()`.
4. Si el rol es 3: Muestra `ManagerMainScreen()`.

### Transiciones Protegidas: `CustomNavigator`
```dart
CustomNavigator.pushProtectedFade(
  context,
  ref,
  const ManagerCounterScreen(),
  allowedRoles: [3],
  deniedMessage: 'Sección exclusiva para personal de mostrador',
);
```

---

## 8. Optimización de Estado Local con `ValueNotifier`

Para optimizar renders y evitar reconstrucciones completas del árbol de widgets con `setState`, se aplica de forma obligatoria:

* **Variables de Estado Local**: Banderas booleanas, contadores, estados de carga, visibilidad de contraseña, toggles y filtros deben implementarse con `ValueNotifier<T>` y consumirse puntualmente mediante `ValueListenableBuilder<T>`.
* **Liberación de Memoria**: Liberar todo `ValueNotifier` en el método `dispose()` de la pantalla.
* **Excepción**: Los `TextEditingController` de Flutter no requieren envolverse en `ValueNotifier`.

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _loading = ValueNotifier<bool>(false);
  final _obscure = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _loading.dispose();
    _obscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loading,
      builder: (context, loading, _) {
        return CustomButton(
          text: loading ? 'Iniciando...' : 'Entrar',
          onPressed: loading ? null : _submit,
        );
      },
    );
  }
}
```
