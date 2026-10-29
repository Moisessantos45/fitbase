# 📌 Tarea C-5: Historiales Personales: Membresías, Asistencias y Pagos

## 🎯 Objetivo
Proporcionar al cliente una sección de autoconsulta y autoservicio dentro de su perfil donde pueda consultar su historial de suscripciones (con opción de cancelación), su bitácora histórica de entrenamientos y asistencias, y sus comprobantes y recibos de pago.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Mis Membresías y Suscripciones** | `GET` | `/api/v1/subscriptions/my-subscriptions` | `Auth`, `Idempotency` | JSON |
| **Cancelar Suscripción Activa** | `PUT` | `/api/v1/subscriptions/:id/cancel` | `Auth`, `Idempotency` | JSON |
| **Mi Historial de Asistencias** | `GET` | `/api/v1/checkin/my-history` | `Auth`, `Idempotency` | JSON |
| **Mis Recibos y Pagos** | `GET` | `/api/v1/payments/my-payments` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Pantalla "Mis Membresías" (`my-subscriptions`)
- [ ] **Listado Cronológico de Suscripciones**:
  - Consumo de `GET /api/v1/subscriptions/my-subscriptions`.
  - Tarjetas de suscripción clasificadas en pestañas: *"Activas"* e *"Históricas"*.
  - Para membresías activas:
    - Botón de acceso directo para abrir el carnet con código QR.
    - Fechas de vigencia y conteo regresivo de días restantes.
    - Switch o botón *"Cancelar Renovación / Membresía"*.
- [ ] **Flujo de Cancelación Segura**:
  - Al solicitar cancelación, desplegar modal de confirmación explicando que mantendrá acceso hasta que termine su periodo ya pagado.
  - Envío a `PUT /api/v1/subscriptions/:id/cancel`.

### 2. Pantalla "Mis Entrenamientos / Asistencias" (`my-history`)
- [ ] **Bitácora de Visitas**:
  - Consumo de `GET /api/v1/checkin/my-history?page=1&page_size=15`.
  - Visualización en formato de línea de tiempo (Timeline) o calendario:
    - Día y hora exacta de cada ingreso.
    - Nombre del gimnasio donde se realizó el entrenamiento.
    - Tipo de pase utilizado (`Membresía` o `Pase Diario`).
  - Métrica motivacional: Conteo total de entrenamientos en el mes actual.

### 3. Pantalla "Mis Recibos de Pago" (`my-payments`)
- [ ] **Historial Financiero del Socio**:
  - Consumo de `GET /api/v1/payments/my-payments?page=1&page_size=10`.
  - Listado de transacciones con:
    - Folio de transacción.
    - Concepto (ej. *"Pago Plan Black Anual"*, *"Pase de Visita"*).
    - Monto pagado (`amount`).
    - Método de pago (Efectivo, Tarjeta, Stripe).
    - Estado: `Pagado` (verde).
    - Fecha y hora.
- [ ] **Comprobante Digital**:
  - Modal para ver el recibo electrónico detallado.
  - Botón *"Descargar Recibo en PDF / Compartir"*.

