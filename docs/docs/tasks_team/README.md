# 🚀 Fitbase: Hoja de Ruta y Tareas del Equipo (`tasks_team`)

Este directorio consolida las especificaciones y tareas de desarrollo para la implementación de las interfaces de usuario (Web y Móvil) y la integración de las capacidades de negocio en **Fitbase**.

La estructura está dividida según los actores y roles del ecosistema:

```
docs/tasks_team/
├── README.md                                # Visión general y estado de la plataforma
├── dueño/                                   # Flujo y panel administrativo del Propietario
│   ├── README.md                            # Resumen de tareas del Dueño
│   ├── 01_registro_gym_horarios_galeria.md  # Alta y gestión integral de sede, horarios y fotos
│   ├── 02_registro_gestion_planes.md        # Catálogo comercial, horarios por día y beneficios
│   ├── 03_gestion_pagos_suscripciones_clientes.md # Monitoreo de clientes, membresías y cobros
│   ├── 04_estadisticas_dashboard_analytics.md     # Métricas de negocio, afluencia y caja
│   └── encargado/                           # Flujo operativo de mostrador y recepción
│       ├── README.md                        # Responsabilidades operativas del Encargado
│       ├── 01_control_caja_apertura_cierre.md     # Apertura obligatoria en login y cierre en logout
│       ├── 02_validacion_pases_checkin_qr.md      # Escáner y validación de accesos
│       ├── 03_generacion_gestion_pases_dia.md     # Registro presencial de visitantes casuales
│       └── 04_busqueda_cobro_pases_mostrador.md   # Cobro y búsqueda de pases públicos pendientes
└── cliente/                                 # Flujo público y autenticado del Socio
    ├── README.md                            # Resumen del Customer Journey
    ├── 01_mapa_sedes_exploracion_detalle.md # Mapa interactivo geolocalizado y detalle de gimnasio
    ├── 02_catalogo_planes_beneficios.md     # Exploración de membresías y beneficios
    ├── 03_compra_pases_suscripciones_pagos.md # Compra digital y pasarela Stripe
    ├── 04_credencial_qr_acceso.md           # Carnet de socio y boleto QR para torniquete
    └── 05_historiales_recibos_asistencias.md # Autoconsulta de membresías, asistencias y pagos
```

---

## 📌 Estado Actual: ¿Qué está ya implementado y verificado?

De acuerdo con el análisis del backend (`internal/features/*`) y las funcionalidades ya operativas:

1. **Autenticación y Seguridad Global (`auth`)**:
   - Registro de usuarios por rol: Cliente (`POST /api/v1/auth/register`) y Dueño (`POST /api/v1/auth/register-owner`).
   - Inicio de sesión con emisión de tokens PASETO (`POST /api/v1/auth/login`, `POST /api/v1/auth/login-mobile`).
   - Cierre de sesión y refresco de tokens (`POST /api/v1/auth/logout`, `POST /api/v1/auth/refresh-token`).
   - Recuperación de contraseñas (`POST /api/v1/auth/forgot-password`, `PATCH /api/v1/auth/reset-password`).
   - Verificación de correo electrónico con tokens en Redis (`POST /api/v1/auth/verify-email`).
   - Resolución de identidad mediante claims (`authID`, `roleID`, `email`) sin exponer IDs en URLs.

2. **Perfiles de Usuario y Avatares (`user`, `owner`, `manager`, `storage`)**:
   - Actualización de perfil y datos personales para Cliente, Dueño y Encargado.
   - Carga, optimización (Lanczos/JPEG) y almacenamiento de foto de perfil (`UploadAvatar`).

3. **Gestión de Encargados por el Dueño (`manager`)**:
   - Alta de encargados administrativos por el dueño (`POST /api/v1/managers`).
   - Listado administrativo de encargados con paginación, búsqueda por texto y renderizado de avatar en la UI (`GET /api/v1/gyms/managers`).

---

## 👥 Matriz de Roles y Responsabilidades

| Capacidad / Módulo | Dueño (`Owner`) | Encargado (`GymManager`) | Cliente / Público (`User`) |
| :--- | :---: | :---: | :---: |
| Explorar mapa de gimnasios y ficha con horarios/fotos | ✅ | ✅ | ✅ |
| Alta y configuración de sede (datos, horarios, fotos) | ✅ | ✅ | ❌ |
| Crear y gestionar planes y beneficios con horarios | ✅ | Solo lectura | ❌ |
| Alta de encargados y listado en la UI | ✅ | ❌ | ❌ |
| Apertura obligatoria de caja al iniciar sesión (`open_cash`) | ❌ | ✅ | ❌ |
| Cierre obligatorio de caja al cerrar sesión (`close_cash`) | ❌ | ✅ | ❌ |
| Registrar visitantes casuales y emitir pases de un día | ✅ | ✅ | ❌ |
| Buscar pases públicos no pagados y cobro en mostrador | ✅ | ✅ | ❌ |
| Validar accesos físicos mediante escáner QR / Email | ✅ | ✅ | ❌ |
| Ver listado de clientes suscritos y pagos de la sede | ✅ (Gestión) | ✅ (Consulta) | ❌ |
| Dashboard de analítica, horas pico y descuadres de turnos | ✅ | ❌ | ❌ |
| Comprar pases de día o suscripciones con Stripe | ❌ | ❌ | ✅ |
| Presentar credencial digital QR de socio / pase | ❌ | ❌ | ✅ |
| Consultar historial personal (visitas, pagos, suscripciones) | ❌ | ❌ | ✅ |

