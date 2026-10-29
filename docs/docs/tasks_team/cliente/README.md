# 👤 Tareas del Rol Cliente / Usuario (`User` & Público)

Este módulo engloba la experiencia del usuario final en **Fitbase**, cubriendo tanto la navegación pública (visitantes casuales sin registrar) como el entorno autenticado del socio que cuenta con una membresía activa o historial de visitas.

---

## 🗺️ El Recorrido del Cliente (*Customer Journey*)

1. **Descubrimiento y Exploración Geográfica**:
   - Visualización de un mapa interactivo con las sedes cercanas a su ubicación actual (público y autenticado).
   - Al pulsar un gimnasio en el mapa, previsualiza una tarjeta con información clave y distancia.
   - Botón de detalles para acceder a la ficha completa: datos de contacto, horarios de apertura/cierre semanales y galería de fotografías.
2. **Catálogo de Planes y Beneficios**:
   - Consulta de los planes de membresía y pases disponibles en esa sede.
   - Desglose de beneficios incluidos y franjas de horarios de entrenamiento.
3. **Compra Digital de Pases y Membresías**:
   - Pases diarios para visitantes sin cuenta o clientes registrados.
   - Pago seguro en línea con tarjeta a través de Stripe Checkout.
4. **Credencial Digital QR para Acceso Físico**:
   - Carnet digital de socio con código QR dinámico (UUIDv7) para escanear en recepción o torniquete.
   - Boleto QR de pase de un día.
5. **Autoconsulta y Gestión Personal**:
   - "Mis Membresías": estado, fechas de vigencia y opción de cancelación.
   - "Mis Asistencias": historial de entrenamientos y visitas registradas.
   - "Mis Recibos": comprobantes de pago de suscripciones y pases.

---

## 🗂️ Índice de Tareas de Cliente

1. [**01. Mapa Interactivo de Sedes Cercanas y Ficha de Detalle**](./01_mapa_sedes_exploracion_detalle.md)
   - Mapa con geolocalización del usuario y pines de gimnasios (`GET /api/v1/gyms?lat=...&lng=...`).
   - Tarjeta flotante con datos esenciales y botón "Ver Detalles".
   - Pantalla de detalle de sede (`GET /api/v1/gyms/:id`): información de contacto, horarios de lunes a domingo e indicador en tiempo real "Abierto / Cerrado", y galería fotográfica.

2. [**02. Catálogo de Planes de Membresía y Beneficios**](./02_catalogo_planes_beneficios.md)
   - Visualización de ofertas comerciales de la sede (`GET /api/v1/gyms/:id/plans`).
   - Modal de detalle y beneficios incluidos (`PlanItems`) con horarios de validez.

3. [**03. Compra Digital de Pases, Suscripciones y Pagos Stripe**](./03_compra_pases_suscripciones_pagos.md)
   - Reserva de pase diario para invitado (`POST /api/v1/daypass/guest`) y socio registrado (`POST /api/v1/daypass/purchase`).
   - Contratación de membresía mensual/anual (`POST /api/v1/subscriptions/subscribe`).
   - Pasarela de pago con Stripe Checkout (`POST /api/v1/payments/stripe/checkout-session`, `/guest-checkout`).

4. [**04. Credenciales Digitales QR para Acceso Físico**](./04_credencial_qr_acceso.md)
   - Carnet digital de socio con QR dinámico (`GET /api/v1/subscriptions/:slug/ticket`).
   - Boleto digital de pase diario con QR (`GET /api/v1/daypass/:slug/ticket`).

5. [**05. Historiales Personales: Membresías, Asistencias y Pagos**](./05_historiales_recibos_asistencias.md)
   - Historial y estado de suscripciones (`GET /api/v1/subscriptions/my-subscriptions`).
   - Historial de asistencias y entrenamientos (`GET /api/v1/checkin/my-history`).
   - Historial de pagos y recibos digitales (`GET /api/v1/payments/my-payments`).

