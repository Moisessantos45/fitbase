# 📌 Tarea D-3: Gestión de Pagos, Suscripciones y Clientes

## 🎯 Objetivo
Proporcionar al Dueño una vista centralizada para consultar y auditar a todos los clientes registrados y activos en su gimnasio, el estado de sus suscripciones y membresías, así como el libro mayor de pagos y recaudación financiera de la sede.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Listar Clientes y Suscripciones** | `GET` | `/api/v1/gyms/:id/subscriptions` | `Auth`, `Idempotency` | JSON |
| **Resumen de Recaudación Total** | `GET` | `/api/v1/gyms/:id/payments/revenue` | `Auth`, `Idempotency` | JSON |
| **Libro Mayor de Pagos de la Sede** | `GET` | `/api/v1/gyms/:id/payments` | `Auth`, `Idempotency` | JSON |
| **Ficha Histórica 360° del Cliente** | `GET` | `/api/v1/gyms/:id/analytics/clients/:user_id` | `Auth`, `Idempotency` | JSON |
| **Cancelar Membresía** | `PUT` | `/api/v1/subscriptions/:id/cancel` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Panel de Clientes y Suscripciones de la Sede
- [ ] **Tabla Paginada de Socios Registrados**:
  - Consumo del endpoint `GET /api/v1/gyms/:id/subscriptions?page=1&page_size=10`.
  - Columnas esenciales:
    - **Cliente**: Nombre completo, teléfono, correo y avatar.
    - **Plan Contratado**: Nombre del plan y tipo de membresía.
    - **Vigencia**: Fecha de inicio (`start_date`) y fecha de caducidad (`end_date`).
    - **Renovación**: Indicador de autorenovación (`auto_renew: true/false`).
    - **Estado**: Badge con color dinámico:
      - `Activo`: Verde.
      - `Inactivo`: Gris.
      - `Pendiente`: Amarillo.
      - `Expirado`: Rojo.
- [ ] **Filtros y Búsqueda**:
  - Filtro por estado de suscripción mediante el parámetro `status_id`.
  - Buscador textual para localizar clientes por nombre, teléfono o correo.
- [ ] **Acciones de Administración**:
  - Botón para dar de baja / cancelar suscripción (`PUT /api/v1/subscriptions/:id/cancel`) con modal de confirmación.
  - Botón para ver la ficha completa 360° del cliente (`GET /api/v1/gyms/:id/analytics/clients/:user_id`).

### 2. Panel de Supervisión Financiera y Pagos
- [ ] **Widget KPI de Recaudación**:
  - Consumo de `GET /api/v1/gyms/:id/payments/revenue`.
  - Tarjeta destacada con:
    - `total_revenue`: Total monetario acumulado de la sede.
    - `total_transactions`: Conteo global de pagos completados.
- [ ] **Historial de Pagos y Transacciones**:
  - Consumo de `GET /api/v1/gyms/:id/payments?page=1&page_size=10`.
  - Listado con desglose de:
    - Recibo ID / Referencia.
    - Monto cobrado (`amount`).
    - Concepto: Suscripción / Plan o Pase de un Día.
    - Método de Pago: Efectivo, Tarjeta, Stripe.
    - Estatus: Pagado, Pendiente, Reembolsado.
    - Fecha y hora del cobro.
- [ ] **Modal de Recibo Digital**:
  - Vista del recibo formal de pago con datos fiscales/comerciales del gimnasio, apto para impresión o envío.

