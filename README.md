# Fitbase — Aplicación Móvil

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_3.x-black)](https://riverpod.dev)
[![Dio](https://img.shields.io/badge/Networking-Dio-blue)](https://pub.dev/packages/dio)
[![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://zurl.mmabitec.uk/nbQlPz)
[![Backend](https://img.shields.io/badge/Backend-Repository-orange?logo=github)](https://github.com/Moisessantos45/fitbase_backend)

**Fitbase** es una plataforma móvil de alto rendimiento diseñada para la gestión integral de centros deportivos y gimnasios. Conecta en un único ecosistema a deportistas, dueños de gimnasios, encargados de mostrador y usuarios invitados.

---

## Enlaces Rápidos

* **Descargar Aplicación Android (APK Release)**: [Descargar APK](https://zurl.mmabitec.uk/nbQlPz)
* **Repositorio del Backend (API REST)**: [Moisessantos45/fitbase_backend](https://github.com/Moisessantos45/fitbase_backend)
* **Repositorio de la Aplicación Móvil**: [Moisessantos45/fitbase](https://github.com/Moisessantos45/fitbase)

---

## Funcionalidades Principales por Rol

### 1. Cliente / Deportista (`Usuario`)
* **Dashboard interactivo**: Métricas de días restantes de suscripción activa, acceso rápido a facturas y sedes.
* **Credencial Digital QR**: Generación de código QR dinámico para acceso rápido y control de asistencia en torniquetes o mostrador.
* **Gestión de Membresías y Pagos**: Historial detallado de recibos con soporte para descarga/visualización, auto-renovación y cancelación.
* **Exploración de Gimnasios**: Mapa interactivo y catálogo de sedes con horarios detallados, servicios, fotos y planes vigentes.
* **Pagos con Tarjeta**: Integración fluida con pasarela segura de Stripe Checkout.

### 2. Propietario / Administrador (`Dueño`)
* **Panel de Analítica y Métricas**: Monitoreo en tiempo real de ingresos totales, suscripciones activas, nuevos socios y afluencia por sede.
* **Gestión de Planes**: Creación, edición y activación de membresías, precios, descuentos y beneficios.
* **Control de Socios y Pagos**: Visualización del padrón de clientes y auditoría de transacciones financieras.

### 3. Encargado de Mostrador (`Gym Manager`)
* **Gestión de Caja**: Apertura y cierre de turno con balance de efectivo inicial, registro de cobros y corte de caja.
* **Mostrador y Punto de Cobro**: Registro de pagos en efectivo o confirmación de pases programados con antelación.
* **Lector de Código QR**: Escáner con cámara integrada (`mobile_scanner`) para validar asistencias y verificar pases diarios al instante, o búsqueda rápida por correo electrónico.

### 4. Modo Invitado (`Guest`)
* **Exploración sin Registro**: Visualización pública de sedes, amenidades y ubicación.
* **Compra de Pase Diario (DayPass)**: Pago de accesos de un día mediante Stripe Checkout o pago directo en mostrador al llegar a la sede.

---

## Estructura del Proyecto

El proyecto sigue los principios de **Clean Architecture** con separación estricta de responsabilidades en capas dentro de `lib/`:

```text
lib/
├── config/                         # Configuración transversal del sistema
│   ├── api.dart                    # Clientes Dio (apiPublic y apiAuth con interceptores y auto-refresh)
│   ├── env.dart                    # Variables de entorno leídas desde JSON
│   ├── navigation/                 # Navegación con rutas protegidas por rol (CustomNavigator)
│   └── theme/                      # Paleta visual Dark Sport Aesthetic y tipografía (AppColors)
├── domain/                         # Capa de Dominio (Entidades y estados puros)
│   ├── analytics_model.dart        # Métricas y KPIs de gimnasio
│   ├── auth_model.dart             # Datos de usuario, roles y credenciales
│   ├── cash_register_model.dart    # Apertura y cierre de turnos de caja
│   ├── checkin_model.dart          # Registro y validación de accesos
│   ├── daypass_model.dart          # Pases diarios para invitados
│   ├── gym_model.dart              # Sedes, horarios y fotos
│   ├── payment_model.dart          # Transacciones, facturas y sesiones de Stripe
│   ├── plan_model.dart             # Membresías, precios y beneficios
│   ├── subscription_model.dart     # Suscripciones y vigencia del usuario
│   └── user_model.dart             # Perfil del usuario
├── infrastructure/                 # Capa de Infraestructura
│   └── mappers/                    # Serialización/deserialización segura sin "as"
│       ├── analytics_mapper.dart
│       ├── auth_mapper.dart
│       ├── cash_register_mapper.dart
│       ├── checkin_mapper.dart
│       ├── daypass_mapper.dart
│       ├── gym_mapper.dart
│       ├── payment_mapper.dart
│       ├── plan_mapper.dart
│       ├── subscription_mapper.dart
│       └── user_mapper.dart
├── presentation/                   # Capa de Presentación
│   ├── providers/                  # Gestores de estado Riverpod 3.x (AsyncNotifier)
│   │   ├── analytics_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── cash_register_provider.dart
│   │   ├── checkin_provider.dart
│   │   ├── daypass_provider.dart
│   │   ├── gym_provider.dart
│   │   ├── owner_provider.dart
│   │   ├── payment_provider.dart
│   │   ├── plan_provider.dart
│   │   ├── subscription_provider.dart
│   │   └── user_provider.dart
│   ├── screens/                    # Pantallas organizadas por módulo/rol
│   │   ├── admin/                  # Dashboard, planes, socios y pagos del dueño
│   │   ├── auth/                   # Login, registro y recuperación de contraseña
│   │   ├── guest/                  # Home, catálogo y compra de pases para invitados
│   │   ├── manger/                 # Control de caja, mostrador y escáner QR de recepción
│   │   ├── user/                   # Home, suscripciones, credencial QR, pagos y mapa
│   │   └── common/                 # Vistas compartidas (tickets, splash, auth gate)
│   └── widgets/                    # Widgets modulares agrupados por módulo
│       ├── common/                 # Modales y widgets transversales (gym_detail_modal.dart)
│       ├── daypass/                # Diálogos de compra de pases de invitado
│       ├── manger/                 # Arqueo de caja, cobro en mostrador y modal de escáner QR
│       ├── payment/                # Recibos detallados de pago
│       └── subscription/           # Modal de credencial QR, vista 360 y alta de membresía
└── main.dart                       # Punto de entrada de la aplicación
```

---

## Cómo Hacerlo Funcionar (Guía Paso a Paso)

### 1. Requisitos Previos
* **Flutter SDK**: Versión 3.24.x o superior ([Guía de instalación](https://docs.flutter.dev/get-started/install))
* **Java SDK**: Versión 17
* **Android SDK**: Build tools y Android NDK configurados
* Dispositivo físico Android (con depuración USB habilitada) o un emulador de Android

### 2. Configuración de Variables de Entorno
Crea un archivo llamado `env.dev.json` en la raíz del proyecto:

```json
{
  "API_BASE_V1": "https://fitbase.mmabitec.uk/api/v1"
}
```

> **Nota:** La URL base debe apuntar a la instancia desplegada o local del [Fitbase Backend](https://github.com/Moisessantos45/fitbase_backend).

### 3. Descarga de Dependencias
```bash
flutter pub get
```

### 4. Ejecución en Modo Desarrollo
Con tu dispositivo o emulador conectado, ejecuta:

```bash
flutter run --dart-define-from-file=./env.dev.json
```

### 5. Compilación del APK para Release (Producción)
Para generar el archivo APK optimizado con ofuscación de código y reducción de tamaño con R8:

```bash
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```

El instalador final se generará en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Guías de Documentación Interna

Para profundizar en los estándares de desarrollo del proyecto, consulta los manuales en la carpeta `docs/`:

* **[Manual de Red y Estado](file:///home/moy45/proyectos_flutter/fitbase/docs/api_and_state_management_guide.md)**: Explicación de interceptores de Dio, idempotencia, cola de auto-refresh de tokens JWT y consumo con Riverpod.
* **[Guía de Arquitectura y Providers](file:///home/moy45/proyectos_flutter/fitbase/docs/architecture_and_providers_guide.md)**: Estándares de Clean Architecture, reglas de mappers sin `as`, `ValueNotifier` para estados locales y guardianes de navegación.
* **[Flujo de Trabajo con Git](file:///home/moy45/proyectos_flutter/fitbase/docs/git_workflow_guide.md)**: Convención de ramas, manejo de versiones, tags, y resolución de fusiones sin conflictos.
* **[Sistema de Diseño y Tokens](file:///home/moy45/proyectos_flutter/fitbase/docs/ui_design_system.md)**: Especificación de colores, tipografías, tarjetas y componentes visuales Dark Sport Aesthetic.
