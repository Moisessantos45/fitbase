# 📌 Tarea E-2: Validación de Pases del Día y Accesos Físicos (CheckIn QR)

## 🎯 Objetivo
Proveer al Encargado de la herramienta principal de control de acceso físico en mostrador y torniquete. Debe permitir validar pases de un día y membresías mediante escaneo de código QR con la cámara del dispositivo o búsqueda manual por correo electrónico, garantizando que **ningún visitante ingrese con un pase diario sin haber sido previamente pagado**.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Validar y Registrar Acceso** | `POST` | `/api/v1/checkin/scan` | `Auth`, `Idempotency` | JSON |
| **Bitácora de Accesos del Día** | `GET` | `/api/v1/gyms/:id/checkins` | `Auth`, `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Interfaz de Escaneo y Validación
- [ ] **Lector con Cámara Integrada (Web & Móvil)**:
  - Integración de escáner de cámara (ej. `html5-qrcode` en web o `react-native-camera` / Expo BarCodeScanner en móvil).
  - Enfoque continuo optimizado para leer el código QR del boleto o carnet (cuyo contenido es el `slug` en formato UUIDv7).
- [ ] **Modo de Búsqueda Manual / Contingencia**:
  - Pestaña alternativa con input de texto para:
    - Pegar o escribir el `slug` manualmente.
    - Buscar directamente por el correo electrónico (`email`) del socio o visitante.
- [ ] **Envío de Validación**:
  - Petición a `POST /api/v1/checkin/scan` enviando `{ "gym_id": gymID, "slug": slug }` o `{ "gym_id": gymID, "email": email }`.

### 2. Manejo de Estados y Alertas de Negocio
- [ ] **Acceso Concedido (Pantalla Verde / Sonido de Éxito)**:
  - Respuesta `allowed: true`.
  - Muestra nombre completo del socio/visitante, tipo de acceso (`Membresía` o `Día de Pase`), nombre del plan y estampa de tiempo.
  - El backend marca automáticamente el pase diario como usado (`is_used: true`).
- [ ] **Acceso Denegado por Pase No Pagado (Alerta Amarilla / Naranja)**:
  - Error: *"El pase diario no ha sido pagado. Debe abonarse en recepción antes de ingresar."*
  - La UI muestra de forma destacada el monto a cobrar (`plan_price`) y ofrece un **botón directo de atajo**: *"Cobrar Pase en Mostrador"*, que redirige de inmediato al módulo de cobro de caja con los datos del visitante precargados.
- [ ] **Acceso Denegado por Infracción (Pantalla Roja / Sonido de Error)**:
  - Visualización del motivo exacto:
    - *"Pase ya utilizado"* (intento de reutilización o fraude).
    - *"Membresía inactiva o expirada"*.
    - *"El gimnasio se encuentra cerrado según los horarios configurados"*.
    - *"Credencial o ticket no pertenece a esta sede"*.

### 3. Bitácora de Accesos en Tiempo Real
- [ ] **Feed de Accesos del Turno**:
  - Lista lateral que se actualiza con los últimos ingresos registrados en el turno.
  - Consumo de `GET /api/v1/gyms/:id/checkins`.

