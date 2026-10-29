# 📌 Tarea C-2: Catálogo de Planes de Membresía y Beneficios

## 🎯 Objetivo
Permitir a los clientes y visitantes explorar el catálogo comercial de planes de membresía, suscripciones y pases diarios activos de una sede específica de gimnasio, consultando sus precios finales calculados, promociones y desglose completo de beneficios y condiciones de horarios.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Planes Activos de la Sede** | `GET` | `/api/v1/gyms/:id/plans` | `Idempotency` | JSON |
| **Detalle Completo del Plan** | `GET` | `/api/v1/plans/:id` | `Idempotency` | JSON |
| **Planes con Validación de Socio** | `GET` | `/api/v1/gyms/:id/plans/enrollment` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Sección de Planes en la Ficha del Gimnasio
- [ ] **Tarjetas de Planes Comerciales**:
  - Pestaña o sección *"Planes y Membresías"* dentro de la pantalla de detalle del gimnasio.
  - Consumo público de `GET /api/v1/gyms/:id/plans`.
  - Visualización por tarjeta:
    - **Nombre del Plan** (ej. *"Membresía Black Anual"*, *"Pase de un Día"*).
    - **Precio Base** tachado si cuenta con descuento.
    - **Precio Final (`final_price`)** calculado y destacado en tipografía grande.
    - **Vigencia**: Número de días naturales (`duration`).
    - **Límite de Visitas**: Ilimitadas o número específico (`max_visits`).
    - Badge con porcentaje de descuento promocional si aplica.

### 2. Modal de Detalle y Beneficios Incluidos (`PlanItems`)
- [ ] **Desglose de Servicios y Términos**:
  - Al pulsar sobre un plan, abrir modal detallado consumiendo `GET /api/v1/plans/:id`.
  - Lista de beneficios (`plan_items`):
    - Icono de verificación verde junto a cada beneficio.
    - Nombre del beneficio y descripción detallada (ej. *"Acceso a zona de peso libre y cardiovascular"*, *"Lockers y regaderas incluidos"*, *"Clases de spinning ilimitadas"*).
    - Franjas horarias y días de la semana autorizados para entrenar con ese plan.
- [ ] **Botones de Llamado a la Acción (CTA)**:
  - Si es plan recurrente (mensual/anual): *"Adquirir Membresía"*.
  - Si es plan de visita única: *"Comprar Pase Diario"*.
  - Conduce directamente al flujo de checkout (Tarea C-3).

### 3. Validación de Membresía Activa (Usuario Autenticado)
- [ ] **Control de Duplicidad (`enrollment`)**:
  - Si el usuario está autenticado, consumir `GET /api/v1/gyms/:id/plans/enrollment`.
  - Si el socio ya cuenta con membresía activa en esa sede:
    - Resaltar su plan actual con un badge distintivo: *"Tu membresía actual"*.
    - Mostrar fecha de vencimiento (`end_date`).
    - Inhabilitar botones de compra repetida para evitar cobros dobles accidentales.

