# Fitbase — Sistema de Diseño y Especificación de UI (Design System)

Este documento contiene la especificación de tokens visuales, componentes y directrices de interfaz utilizadas en la aplicación móvil **Fitbase**, preparadas para su diseño, mantenimiento y réplica en la **versión Web**.

---

## Enlaces del Proyecto

* **Descarga del APK (Android Release)**: [https://zurl.mmabitec.uk/nbQlPz](https://zurl.mmabitec.uk/nbQlPz)
* **Repositorio del Backend (API REST)**: [https://github.com/Moisessantos45/fitbase_backend](https://github.com/Moisessantos45/fitbase_backend)
* **Repositorio de la Aplicación Móvil**: [https://github.com/Moisessantos45/fitbase](https://github.com/Moisessantos45/fitbase)

---

## 1. Concepto y Filosofía de Diseño
* **Estilo visual:** Modo oscuro de alto impacto (*Dark Sport Aesthetic*) con acentos en verde lima/neón (`#D2F801`) de alto contraste.
* **Sensación de marca:** Energética, moderna, prémium, enfocada en rendimiento fitness y experiencia táctil fluida.
* **Geometría:** Bordes redondeados pronunciados (`border-radius: 16px - 24px`), tarjetas sólidas con sutiles bordes delimitadores (`1px solid #2C2C2E`), y jerarquía tipográfica limpia.

---

## 2. Paleta de Colores (Design Tokens)

Para la réplica en Web, definir las siguientes variables CSS en `:root`:

```css
:root {
  /* Fondos y Superficies */
  --color-bg: #101010;
  --color-surface: #1C1C1E;
  --color-surface-light: #2C2C2E;
  --color-card: #18181A;
  --color-card-highlight: #222226;
  --color-border: #2C2C2E;

  /* Color Primario / Acento */
  --color-primary: #D2F801;
  --color-primary-dark: #A6C400;
  --color-primary-glow: rgba(210, 248, 1, 0.25);

  /* Textos */
  --color-text-primary: #FFFFFF;
  --color-text-secondary: #8E8E93;
  --color-text-muted: #636366;

  /* Semánticos */
  --color-success: #34C759;
  --color-warning: #FF9500;
  --color-error: #FF453A;
  --color-info: #0A84FF;
}
```

---

## 3. Componentes Principales de UI

### A. Botón Principal (`CustomButton`)
* **Color de fondo:** `#D2F801` (`var(--color-primary)`).
* **Color de texto:** `#101010` (Negro profundo de alto contraste).
* **Border Radius:** `16px`.
* **Tipografía:** Negrita (`font-weight: 700`), `16px`.
* **Padding:** `16px` vertical.

### B. Campos de Texto (`CustomTextField`)
* **Fondo:** `#1C1C1E`.
* **Borde:** `1.5px solid #2C2C2E`. En foco: `1.5px solid #D2F801`.
* **Border Radius:** `16px`.
* **Iconos:** Prefijo y sufijo con color `#8E8E93`, activos en `#D2F801`.

### C. Credencial Digital QR (`SubscriptionQrModal`)
* **Contenedor:** Modal centrado con fondo oscuro y bordes redondeados (`28px`).
* **Visualizador QR:** Caja blanca pura (`#FFFFFF`) con padding de `16px` y radio `16px` para garantizar escaneo instantáneo con cualquier sensor.
* **Datos mostrados:** Nombre del socio, plan activo, sede, vigencia y código numérico o slug.

### D. Escáner de Cámara QR (`QrScannerModal`)
* **Sensor:** Lector en tiempo real con paquete `mobile_scanner`.
* **Marco de escaneo:** Visor cuadrado central con esquinas resaltadas en verde neón (`#D2F801`) y animación de escaneo.
* **Controles flotantes:** Botones para alternar flash/linterna y alternar entre cámara frontal y trasera.

### E. Módulo de Caja (`OpenCashDialog`, `CloseCashDialog`)
* **Apertura:** Selector numérico de fondo inicial en efectivo y confirmación rápida.
* **Cierre:** Desglose del total calculado por el sistema en efectivo vs. monto contado físico, cálculo de discrepancia y campo de notas finales del turno.

### F. Recibo Detallado de Pago (`PaymentReceiptModal`)
* **Cabecera:** Monto destacado en tamaño grande con badge de estatus (`Pagado`, `Pendiente`, `Rechazado`).
* **Metadatos:** Identificador de transacción, sede, fecha, método de pago y desglose fiscal.

---

## 4. Estructura de Rutas y Pantallas

| Ruta | Rol / Acceso | Componente Flutter |
| :--- | :--- | :--- |
| `/login` | Público | `LoginScreen` (con enlace a registro e invitado) |
| `/register` | Público | `RegisterScreen` (selector: Usuario o Dueño) |
| `/guest` | Invitado | `GuestHomeScreen` (Sedes y compra de DayPass) |
| `/user/home` | Usuario | `UserHomeScreen` (KPIs, vigencia, sedes y pagos) |
| `/user/subscriptions` | Usuario | `UserSubscriptionsScreen` (Membresías y credencial QR) |
| `/user/payments` | Usuario | `UserPaymentsScreen` (Historial de recibos) |
| `/manager/counter` | Gym Manager | `ManagerCounterScreen` (Caja, mostrador y escáner QR) |
| `/admin/dashboard` | Dueño | `AdminDashboardScreen` (Analítica e ingresos) |
| `/admin/plans` | Dueño | `AdminPlansScreen` (Gestión de membresías) |
| `/admin/payments` | Dueño | `AdminPaymentsScreen` (Auditoría de cobros) |
