# 📌 Tarea E-1: Control de Caja Física: Apertura al Login y Cierre al Logout

## 🎯 Objetivo
Garantizar el control contable y la trazabilidad de los flujos de dinero físico en recepción. El flujo de trabajo del Encargado exige que **al iniciar sesión se le solicite obligatoriamente el monto inicial en efectivo con el que abre la caja**, y **al cerrar sesión o terminar su turno se le exija el arqueo final para registrar la caja de salida**.

> [!IMPORTANT]
> El backend de Fitbase rechaza cualquier cobro en efectivo (`POST /api/v1/payments/cash`) si el usuario no tiene una caja física activa y abierta (`close_time IS NULL`), impidiendo fugas de dinero en mostrador.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Consultar Caja Activa** | `GET` | `/api/v1/cash-register/current` | `Auth`, `Idempotency` | JSON |
| **Apertura de Caja de Entrada** | `POST` | `/api/v1/cash-register/open` | `Auth`, `Idempotency` | JSON |
| **Cierre de Caja de Salida** | `POST` | `/api/v1/cash-register/close` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Interceptor y Modal de Apertura al Iniciar Sesión
- [ ] **Comprobación Automática Post-Login**:
  - Inmediatamente después de autenticarse exitosamente como Encargado (`RoleID = 3`), el frontend ejecuta `GET /api/v1/cash-register/current`.
  - **Si no existe caja abierta**:
    - Bloquear la navegación hacia el panel operativo y desplegar modal no descartable: *"Apertura de Turno de Caja"*.
    - Campo numérico obligatorio: `open_cash` (Fondo inicial en efectivo presente en el cajón).
    - Botón principal: *"Abrir Caja e Iniciar Turno"*.
    - Envío a `POST /api/v1/cash-register/open` con `{ "gym_id": gymID, "open_cash": monto }`.
  - **Si ya existe una caja abierta previa**:
    - Redirigir directamente al panel operativo sin interrumpir al encargado.

### 2. Widget de Estado de Caja Activa
- [ ] **Indicador en Navbar / Barra Superior**:
  - Badge visual en el encabezado:
    - Estado: 🟢 *"Caja Abierta"*.
    - Hora de apertura (`open_time`).
    - Fondo de apertura (`open_cash`).
  - Al hacer clic en el badge, mostrar tooltip con el resumen del turno en curso.

### 3. Interceptor y Pantalla de Cierre de Caja al Cerrar Sesión
- [ ] **Flujo de Salida Obligatorio**:
  - Al hacer clic en el botón de **"Cerrar Sesión"** o **"Finalizar Turno"**:
    1. Comprobar mediante `GET /api/v1/cash-register/current` si hay una caja abierta.
    2. Si hay caja abierta, interceptar el logout y mostrar modal obligatorio: *"Arqueo y Cierre de Caja"*.
    3. Input numérico: `close_cash` (Efectivo físico total contado por el encargado al finalizar su turno).
    4. Confirmación: *"¿Estás seguro de cerrar el turno de caja? Esta acción notificará al propietario del gimnasio."*
    5. Envío a `POST /api/v1/cash-register/close` con `{ "close_cash": monto }`.
    6. Una vez cerrado con éxito, proceder automáticamente a ejecutar la destrucción del token en `POST /api/v1/auth/logout` y redirigir a la pantalla de login.

