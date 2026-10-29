# 📌 Tarea D-4: Estadísticas del Negocio y Dashboard de Analítica

## 🎯 Objetivo
Proporcionar al Dueño un panel ejecutivo de inteligencia de negocio (*Business Intelligence*) con métricas en tiempo real sobre la recaudación, afluencia física, horas pico de asistencia, distribución de ingresos por planes y auditoría contable de los turnos de caja de sus encargados.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Resumen Ejecutivo Consolidado** | `GET` | `/api/v1/gyms/:id/analytics/dashboard-summary` | `Auth`, `Idempotency` | JSON |
| **Métricas de Afluencia y Horas Pico** | `GET` | `/api/v1/gyms/:id/analytics/attendance` | `Auth`, `Idempotency` | JSON |
| **Ingresos Cruzados (Método / Plan)** | `GET` | `/api/v1/gyms/:id/analytics/revenue` | `Auth`, `Idempotency` | JSON |
| **Auditoría de Turnos de Encargados** | `GET` | `/api/v1/gyms/:id/analytics/shifts` | `Auth`, `Idempotency` | JSON |
| **Bitácora de Accesos Físicos** | `GET` | `/api/v1/gyms/:id/checkins` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Dashboard Ejecutivo Principal (`dashboard-summary`)
- [ ] **Tarjetas de Indicadores Clave (KPIs)**:
  - Carga instantánea consumiendo `GET /api/v1/gyms/:id/analytics/dashboard-summary`:
    - **Total Recaudado (`total_revenue`)**: Ingresos acumulados netos.
    - **Transacciones (`total_transactions`)**: Total de cobros realizados.
    - **Socios Activos (`active_subscribers`)**: Clientes con membresía vigente al día de hoy.
    - **Asistencias Totales (`total_check_ins`)**: Entradas físicas registradas en torniquete/mostrador.
    - **Hora Pico (`peak_hour`)**: Hora del día con mayor afluencia de personas (ej. `19:00 hrs`) y conteo de ingresos (`peak_hour_count`).
- [ ] **Tablas Rápidas de Actividad Reciente**:
  - Widget de **Últimos 5 Pagos**: Monto, método, estado y fecha.
  - Widget de **Últimos 5 Turnos de Caja**: Encargado, horario de apertura/cierre y estado de arqueo.

### 2. Tablero de Afluencia y Horarios Pico (`attendance`)
- [ ] **Gráfico de Barras de Distribución Horaria (0 a 23 hrs)**:
  - Consumo de `GET /api/v1/gyms/:id/analytics/attendance?from=YYYY-MM-DD&to=YYYY-MM-DD`.
  - Eje X: Horas del día (00:00 a 23:00).
  - Eje Y: Número de visitas registradas en ese horario.
  - Resaltar en color contrastante la columna de la **Hora Pico**.
- [ ] **Desglose de Visitas por Tipo de Acceso**:
  - Gráfica circular / dona comparando:
    - Entradas por **Membresía**.
    - Entradas por **Pase de Día**.
    - Entradas de **Invitados casuales**.

### 3. Matriz de Ingresos Cruzados (`revenue`)
- [ ] **Gráficos Financieros**:
  - Consumo de `GET /api/v1/gyms/:id/analytics/revenue`.
  - **Por Método de Pago**: Distribución porcentual y monto en Efectivo, Tarjeta y Stripe.
  - **Por Plan Comercial**: Cuáles son los planes de membresía más vendidos y rentables.

### 4. Auditoría de Cajas de Encargados (`shifts`)
- [ ] **Control de Descuadres Contables**:
  - Consumo de `GET /api/v1/gyms/:id/analytics/shifts?from=YYYY-MM-DD&to=YYYY-MM-DD`.
  - Comparativa de caja por turno:
    - Encargado responsable.
    - Fondo de inicio (`open_cash`).
    - Total recaudado en sistema durante el turno (`total_collected`).
    - Arqueo final reportado en el cierre (`close_cash`).
    - **Diferencia (`difference`)**:
      - `Cuadrada`: Diferencia = 0 (Verde).
      - `Faltante`: Diferencia < 0 (Rojo, alertando posible fuga de dinero).
      - `Sobrante`: Diferencia > 0 (Amarillo).

