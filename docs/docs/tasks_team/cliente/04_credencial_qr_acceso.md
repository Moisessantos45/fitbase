# 📌 Tarea C-4: Credenciales Digitales QR para Acceso Físico

## 🎯 Objetivo
Diseñar la pantalla central de acceso físico que el cliente presentará día a día en el mostrador o torniquete de la sucursal. Esta vista renderiza el código QR dinámico de alta resolución basado en el identificador seguro `Slug` (UUIDv7), tanto para membresías activas como para pases de un día.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Consultar Carnet de Membresía** | `GET` | `/api/v1/subscriptions/:slug/ticket` | `Idempotency` | JSON |
| **Consultar Ticket de Pase de un Día** | `GET` | `/api/v1/daypass/:slug/ticket` | `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Carnet Digital de Socio (Membresía Activa)
- [ ] **Diseño Visual de Credencial Deportiva**:
  - Consumo de `GET /api/v1/subscriptions/:slug/ticket`.
  - Tarjeta con estilo de credencial física moderna:
    - Foto de perfil (avatar) del socio.
    - Nombre y apellidos completos.
    - Nombre del gimnasio y logotipo de la sede.
    - Tipo y nombre del plan contratado (ej. *"Plan Anual Black"*).
    - Fechas de vigencia: Inicio (`start_date`) y vencimiento (`end_date`).
    - Badge de estado dinámico:
      - 🟢 `Activo`: Membresía vigente y lista para entrar.
      - 🔴 `Vencido` / `Inactivo`: Alerta de renovación.
- [ ] **Generador de Código QR**:
  - Renderizado del QR utilizando una librería robusta (ej. `qrcode.react` o `react-native-qrcode-svg`).
  - El contenido del QR es estrictamente la cadena del `slug` (UUIDv7).
  - Ajuste automático de brillo en móvil al abrir la pantalla para optimizar la lectura en lectores ópticos y cámaras.

### 2. Boleto Digital de Pase de un Día
- [ ] **Ticket de Visita Individual**:
  - Consumo de `GET /api/v1/daypass/:slug/ticket`.
  - Formato de boleto con:
    - Fecha programada de visita (`visit_date`).
    - Estado de pago:
      - 🟢 `Pagado`: Boleto habilitado para acceso.
      - 🟠 `Pendiente de Pago en Recepción`: Alerta indicando que debe pagar en mostrador al llegar.
    - Estado de uso:
      - `Válido para Hoy`: Aún no ha ingresado.
      - `Pase Utilizado`: Ya se registró el check-in (`is_used: true`).
  - Código QR generado a partir del `slug` del pase.
- [ ] **Acciones de Conveniencia**:
  - Botón *"Guardar en Fotos / Compartir Boleto"*.
  - Enlace rápido a *"Cómo llegar a la sede"*.

