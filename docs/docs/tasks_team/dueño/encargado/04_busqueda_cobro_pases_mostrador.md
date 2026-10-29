# 📌 Tarea E-4: Búsqueda y Cobro en Mostrador de Pases Públicos Pendientes

## 🎯 Objetivo
Permitir al Encargado buscar y cobrar en el mostrador de recepción aquellos pases diarios que los visitantes generaron o compraron previamente a través de la plataforma pública web/móvil seleccionando la modalidad *"Pagar en Recepción"*. Una vez localizado el pase pendiente, el encargado cobra el monto exacto en efectivo o terminal física, enlazando la transacción a su turno de caja abierto y liberando el pase para el acceso del visitante.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Buscar Pases por Término / Filtro** | `GET` | `/api/v1/gyms/:id/daypasses?search={query}` | `Auth`, `Idempotency` | JSON |
| **Consultar Ficha del Boleto por Slug** | `GET` | `/api/v1/daypass/:slug/ticket` | `Idempotency` | JSON |
| **Registrar Cobro en Mostrador** | `POST` | `/api/v1/payments/cash` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Buscador Rápido de Pases Pendientes en Recepción
- [ ] **Barra de Búsqueda Reactiva**:
  - Input prominente de búsqueda en la pantalla del punto de venta o mostrador.
  - El encargado puede escribir indistintamente:
    - Nombre del visitante (ej. *"Carlos"*).
    - Correo electrónico (ej. *"carlos@gmail.com"*).
    - Número de teléfono (ej. *"5512345678"*).
    - Slug / Código del ticket UUIDv7 (ej. leído por escáner de mano).
  - Consumo de `GET /api/v1/gyms/:id/daypasses?search={query}`.
- [ ] **Filtro de Estado de Pago**:
  - Pestaña destacada: *"Pendientes de Cobro"* (`is_paid: false`).
  - Excluir o marcar en gris pases ya utilizados o cancelados.
  - Mostrar claramente el importe pendiente a cobrar (`plan_price`).

### 2. Punto de Cobro en Mostrador (Efectivo y Tarjeta Física)
- [ ] **Modal de Cobro de Pase**:
  - Al pulsar sobre un pase pendiente, se abre el modal de cobro con los datos del visitante y el plan seleccionado precargados.
  - **Selector de Método de Pago**:
    - **Efectivo** (`payment_method_id = 1`):
      - La UI verifica que el encargado tenga su turno de caja abierto (`is_open = true`).
      - Calculadora de cambio: Input *"Monto recibido en efectivo"* y cálculo automático de *"Cambio a devolver"*.
    - **Tarjeta / Terminal Física** (`payment_method_id = 2`):
      - Campo de referencia opcional del voucher bancario.
  - **Confirmación del Cobro**:
    - Envío a `POST /api/v1/payments/cash` con:
      ```json
      {
        "gym_id": 1,
        "payment_method_id": 1,
        "amount": 150.00,
        "day_pass_id": 42
      }
      ```
    - El backend valida atómicamente la caja abierta, registra el pago en `payments` y marca el pase como `is_paid = true`.

### 3. Recibo Digital y Liberación Inmediata de Acceso
- [ ] **Comprobante de Transacción**:
  - Despliegue del recibo digital con folio de cobro, fecha, hora y datos de la sede.
  - Botón: *"Registrar Entrada Inmediata"* (ejecuta el check-in sin necesidad de volver a escanear el boleto).
  - Botón: *"Imprimir Comprobante de Pago"*.

