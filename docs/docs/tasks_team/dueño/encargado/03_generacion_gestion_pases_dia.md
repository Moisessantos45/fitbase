# 📌 Tarea E-3: Generación y Gestión Presencial de Pases de un Día

## 🎯 Objetivo
Permitir al Encargado atender y registrar a visitantes casuales que llegan directamente a las instalaciones del gimnasio sin una cuenta en la aplicación. El encargado debe poder generar un pase de un día en mostrador, capturar sus datos de contacto básicos y emitir el boleto digital con código QR para su uso inmediato.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Registrar Visitante Casual en Mostrador** | `POST` | `/api/v1/daypass/register-guest` | `Auth`, `Idempotency` | JSON |
| **Consultar Boleto / Ticket con QR** | `GET` | `/api/v1/daypass/:slug/ticket` | `Idempotency` | JSON |
| **Listar y Gestionar Pases de la Sede** | `GET` | `/api/v1/gyms/:id/daypasses` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Formulario Rápido de Registro de Visitante Casual
- [ ] **Campos de Captura en Mostrador**:
  - `gym_id`: ID de la sede del encargado (inferido o seleccionado).
  - `plan_id`: Selector del plan de tipo pase diario (`plan_type = "Pase de Visita"` o `duration = 1`).
  - `full_name`: Nombre completo del visitante (mínimo 3 caracteres).
  - `phone`: Teléfono de contacto (para emergencias o seguimiento comercial).
  - `email`: Correo electrónico (para envío opcional del comprobante digital).
  - `visit_date`: Fecha de visita (por defecto la fecha de hoy `YYYY-MM-DD`).
- [ ] **Validaciones de Negocio**:
  - Bloqueo en cliente si la fecha seleccionada es en el pasado.
  - El backend valida automáticamente que el gimnasio esté abierto hoy en su horario antes de emitir el pase.

### 2. Emisión del Boleto Digital con Código QR
- [ ] **Pantalla / Modal de Boleto Generado**:
  - Al completar el registro en `POST /api/v1/daypass/register-guest`, consumir `GET /api/v1/daypass/:slug/ticket`.
  - Renderizado en alta resolución del código QR con el `slug` (UUIDv7).
  - Ficha con:
    - Nombre del visitante.
    - Sede y fecha autorizada.
    - Precio del plan (`plan_price`).
    - Estado de pago (`is_paid`).
  - Botón: *"Imprimir Ticket Térmico / Descargar Comprobante"*.
  - Botón directo: *"Proceder al Cobro en Mostrador"*.

### 3. Panel de Gestión de Pases Diarios Emitidos
- [ ] **Tabla de Bitácora de Pases**:
  - Consumo de `GET /api/v1/gyms/:id/daypasses?date=YYYY-MM-DD`.
  - Columnas:
    - Visitante (Nombre, Correo, Teléfono).
    - Modalidad: Socio Registrado vs Invitado Casual (`UserID == nil`).
    - Importe del pase (`plan_price`).
    - Estado de Pago: `Pagado` (verde) vs `Pendiente` (naranja).
    - Estado de Ingreso: `Utilizado` (gris) vs `Por Ingresar` (azul).
  - Selector de fecha para auditar pases de días anteriores o del día en curso.

