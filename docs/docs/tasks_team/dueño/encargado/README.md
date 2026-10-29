# 📋 Tareas del Rol Encargado de Sede (`GymManager`)

El **Encargado de Gimnasio** es el operador de mostrador y recepción responsable del funcionamiento diario de la sede. Comparte las facultades administrativas delegadas por el Dueño (como consultar clientes, sedes y catálogos), pero posee **responsabilidades operativas y contables exclusivas** vinculadas al flujo físico del gimnasio:

1. **Apertura y Cierre Obligatorio de Turno de Caja**:
   - Al iniciar sesión en el sistema, es obligatorio ingresar el monto con el que abre la caja física (`open_cash`).
   - Sin una caja de entrada abierta, el sistema bloquea cualquier venta en efectivo en mostrador.
   - Al cerrar sesión o finalizar su turno, debe declarar el arqueo final en efectivo (`close_cash`) para cerrar la caja de salida y permitir la auditoría del dueño.
2. **Validación de Accesos y Pases del Día**:
   - Escaneo mediante cámara de códigos QR o búsqueda manual para admitir clientes y visitantes al gimnasio.
   - Verificación estricta de que los pases del día estén debidamente pagados antes de otorgar acceso.
3. **Generación y Gestión Presencial de Pases de un Día**:
   - Registro de visitantes casuales que acuden directamente a recepción sin contar con cuenta registrada en la aplicación.
   - Emisión del boleto digital con su código QR.
4. **Búsqueda y Cobro de Pases Públicos no Pagados**:
   - Búsqueda en mostrador de reservaciones hechas en línea por visitantes que eligieron *"Pagar en Recepción"*.
   - Cobro en mostrador (efectivo vinculado a su caja o tarjeta/terminal física) y emisión del recibo digital.

---

## 🗂️ Índice de Tareas del Encargado

1. [**01. Control de Caja Física: Apertura al Login y Cierre al Logout**](./01_control_caja_apertura_cierre.md)
   - Interceptor al iniciar sesión para apertura de caja (`POST /api/v1/cash-register/open`).
   - Badge indicador de caja activa en el encabezado.
   - Modal de arqueo de salida previo al cierre de sesión (`POST /api/v1/cash-register/close`).

2. [**02. Validación de Accesos Físicos y Escáner QR de Pases**](./02_validacion_pases_checkin_qr.md)
   - Lector de cámara de códigos QR (`slug` UUIDv7) y búsqueda manual por correo.
   - Validación de pagos: bloqueo de pases no abonados con mensaje de cobro en mostrador.
   - Registro automático en bitácora y feedback visual/auditivo.

3. [**03. Generación y Gestión Presencial de Pases de un Día**](./03_generacion_gestion_pases_dia.md)
   - Formulario rápido de visitante casual sin cuenta (`POST /api/v1/daypass/register-guest`).
   - Emisión y entrega inmediata de ticket digital con QR.
   - Consulta y administración de pases diarios generados.

4. [**04. Búsqueda y Cobro en Mostrador de Pases Públicos Pendientes**](./04_busqueda_cobro_pases_mostrador.md)
   - Buscador de pases pendientes de pago por nombre, teléfono, email o código.
   - Registro del cobro en efectivo o tarjeta física (`POST /api/v1/payments/cash`).
   - Generación de comprobante y liberación inmediata para acceso físico.

