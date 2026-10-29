# 📌 Tarea D-2: Registro y Gestión de Planes de Membresía

## 🎯 Objetivo
Permitir al Dueño diseñar y administrar el catálogo comercial de membresías y pases de su gimnasio. Cada plan define su precio base, porcentaje de descuento, duración en días, tipo de plan, y su lista de beneficios y condiciones de acceso con horarios definidos en cada día de la semana para regular la entrada de los socios a las instalaciones.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Crear Plan con Beneficios** | `POST` | `/api/v1/plans` | `Auth`, `Idempotency` | JSON |
| **Listar Todos los Planes de la Sede** | `GET` | `/api/v1/gyms/:id/all-plans` | `Auth`, `Idempotency` | JSON |
| **Editar Datos Generales del Plan** | `PUT` | `/api/v1/plans/:id` | `Auth`, `Idempotency` | JSON |
| **Agregar Beneficio a un Plan** | `POST` | `/api/v1/plans/:id/items` | `Auth`, `Idempotency` | JSON |
| **Modificar Beneficio Existente** | `PUT` | `/api/v1/plans/:id/items/:item_id` | `Auth`, `Idempotency` | JSON |
| **Eliminar Beneficio** | `DELETE` | `/api/v1/plans/:id/items/:item_id` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Formulario de Creación de Planes
- [ ] **Campos Principales del Plan**:
  - `gym_id`: ID del gimnasio administrado por el dueño.
  - `name`: Nombre comercial (ej. *"Plan Mensual Total"*, *"Plan Matutino Especial"*, *"Pase Diario Visita"*).
  - `description`: Descripción atractiva de los servicios incluidos.
  - `plan_type`: Selector de modalidad (`Mensual`, `Anual`, `Pase de Visita`, `Personalizado`).
  - `price`: Precio base en moneda local (`numeric(10,2)` estrictamente positivo).
  - `discount`: Porcentaje de descuento opcional (de 0 a 100%).
  - `duration`: Vigencia del plan en días naturales (ej. 30 para mensual, 365 para anual, 1 para pase diario).
  - `max_visits`: Límite opcional de accesos permitidos (`null` para visitas ilimitadas).
- [ ] **Cálculo y Previsualización Dinámica de Precios**:
  - Mostrar en tiempo real el precio final que pagará el cliente:
    $$\text{Precio Final} = \text{Precio Base} \times \left(1 - \frac{\text{Descuento}}{100}\right)$$
  - Badge visual con el porcentaje de ahorro generado.

### 2. Configuración de Beneficios y Horarios por Día de la Semana
- [ ] **Gestión Dinámica de Beneficios (`PlanItems`)**:
  - Módulo dinámico para añadir múltiples beneficios antes de guardar el plan.
  - Campos por beneficio: `name` (nombre del beneficio) y `description` (detalle).
- [ ] **Especificación de Horarios de Acceso Semanal por Plan**:
  - Permitir al dueño definir las franjas horarias y días de validez del plan para comunicarlo al socio (ej. *"Acceso Lunes a Viernes de 06:00 a 14:00 hrs"* o *"Acceso Sábados y Domingos horario completo"*).
  - Registro de los términos de horarios semanales como parte de los beneficios e instrucciones del plan (`PlanItem`), facilitando que el cliente conozca claramente qué días y horas puede acudir a entrenar con esa membresía.

### 3. Listado y Catálogo Administrativo de Planes
- [ ] **Vista en Tarjetas o Tabla**:
  - Consumo de `GET /api/v1/gyms/:id/all-plans` (muestra activos e inactivos).
  - Etiquetas de estado: `Activo` (verde) / `Pausado` (gris).
  - Resumen visual con precio base tachado, precio final destacado, duración y visitas.
  - Desplegable de beneficios asociados a cada tarjeta.

### 4. Edición y Pausado
- [ ] **Acciones de Mantenimiento**:
  - Switch rápido para activar o pausar un plan (`PUT /api/v1/plans/:id` con `{ "active": false }`).
  - Modal para editar montos, descuentos o nombres.
  - Gestión granular de beneficios creados sin tener que recrear el plan (`POST /plans/:id/items`, `PUT /plans/:id/items/:item_id`, `DELETE /plans/:id/items/:item_id`).

