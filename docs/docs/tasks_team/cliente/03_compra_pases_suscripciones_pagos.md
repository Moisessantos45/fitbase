# 📌 Tarea C-3: Compra Digital de Pases, Suscripciones y Pagos Stripe

## 🎯 Objetivo
Permitir a los clientes y visitantes adquirir pases de un día o contratar membresías periódicas, ofreciendo tanto la opción de pago presencial en mostrador (*"Pagar en Recepción"*) como el pago digital seguro con tarjeta de crédito/débito a través de la pasarela **Stripe Checkout**.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Reserva de Pase Público (Sin Cuenta)** | `POST` | `/api/v1/daypass/guest` | `Idempotency` | JSON |
| **Stripe Checkout Visitante Público** | `POST` | `/api/v1/payments/stripe/guest-checkout` | `Idempotency` | JSON |
| **Compra de Pase Socio Autenticado** | `POST` | `/api/v1/daypass/purchase` | `Auth`, `Idempotency` | JSON |
| **Contratar Suscripción Socio** | `POST` | `/api/v1/subscriptions/subscribe` | `Auth`, `Idempotency` | JSON |
| **Stripe Checkout Socio Autenticado** | `POST` | `/api/v1/payments/stripe/checkout-session` | `Auth`, `Idempotency` | JSON |
| **Comprobar Estado de Sesión Stripe** | `GET` | `/api/v1/payments/stripe/session/:session_id` | `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Flujo de Compra de Pase Diario para Visitante Público (Sin Cuenta)
- [ ] **Formulario de Emisión Pública**:
  - Modal o pantalla en `/guest/daypass`:
    - Captura de `full_name`, `phone`, `email` y selector de `visit_date`.
  - **Elección del Canal de Pago**:
    - **Opción A: "Pagar en Recepción"**:
      - Envío a `POST /api/v1/daypass/guest`.
      - Redirección inmediata al boleto digital con código QR con estado *"Pendiente de Pago en Mostrador"* para que el encargado lo cobre al llegar a la sede.
    - **Opción B: "Pagar Ahora con Tarjeta"**:
      - Envío a `POST /api/v1/payments/stripe/guest-checkout`.
      - Redirección automática a la URL segura provista por Stripe (`checkout_url`).

### 2. Flujo de Compra de Pase Diario para Socio Autenticado
- [ ] **Proceso Simplificado con Cuenta**:
  - El socio selecciona la fecha de visita (`visit_date`).
  - No requiere volver a capturar nombre ni contacto (el backend los infiere del usuario logueado).
  - Envío a `POST /api/v1/daypass/purchase` o pasarela Stripe vía `POST /api/v1/payments/stripe/checkout-session` con `type = "daypass"`.

### 3. Flujo de Contratación de Membresía / Suscripción
- [ ] **Configuración de la Suscripción**:
  - Selector de fecha de inicio (`start_date`), por defecto hoy.
  - Conmutador opcional de autorenovación (`auto_renew: true/false`).
  - Selector de forma de pago:
    - Pago en mostrador / efectivo: `POST /api/v1/subscriptions/subscribe`.
    - Pago digital con tarjeta: `POST /api/v1/payments/stripe/checkout-session` con `type = "subscription"`.

### 4. Retorno y Confirmación de Pago Stripe
- [ ] **Pantalla de Éxito (`/payments/success?session_id=...`)**:
  - Lectura del parámetro `session_id` de la URL.
  - Consumo de `GET /api/v1/payments/stripe/session/:session_id` para confirmar la acreditación del pago.
  - Animación de confirmación exitosa con detalles del cobro.
  - Botón directo: *"Ver mi Credencial QR de Acceso"*.

