# 👔 Tareas del Rol Dueño / Propietario (`Owner`)

El **Dueño** es el administrador principal del gimnasio o franquicia. Tras completar su registro e inicio de sesión en Fitbase, su flujo principal consiste en:
1. Dar de alta su gimnasio configurando su información general, horarios de atención y galería fotográfica.
2. Registrar su catálogo comercial de planes de membresía, definiendo beneficios y especificaciones de horarios para cada día de la semana.
3. Monitorear los clientes suscritos y el historial de pagos y recaudación de su negocio.
4. Analizar el rendimiento operativo mediante el tablero de analítica ejecutiva (afluencia, horas pico, ingresos cruzados y auditoría de turnos de caja de sus encargados).

> [!NOTE]
> Las tareas de operación diaria de mostrador (apertura/cierre de caja física, escaneo QR de entradas y cobro presencial) están documentadas en la subcarpeta [`encargado/`](./encargado/README.md), ya que aunque el dueño comparte permisos de administración, dichas tareas corresponden a la rutina del personal de recepción.

---

## 🗂️ Índice de Tareas del Dueño

1. [**01. Registro de Gimnasio, Horarios Semanales y Galería de Fotos**](./01_registro_gym_horarios_galeria.md)
   - Formulario de alta de sucursal con geolocalización en mapa.
   - Configuración semanal de horarios de apertura y cierre (días 0 al 6).
   - Galería de fotos con subida múltiple, foto de portada y eliminación segura.

2. [**02. Registro y Gestión de Planes de Membresía**](./02_registro_gestion_planes.md)
   - Creación de planes con beneficios dinámicos (`PlanItems`).
   - Definición de restricciones y horarios de acceso por día de la semana.
   - Edición de precios, descuentos promocionales y conmutador de activación.

3. [**03. Gestión de Clientes, Suscripciones y Pagos**](./03_gestion_pagos_suscripciones_clientes.md)
   - Monitoreo del listado de socios y clientes suscritos a la sede.
   - Filtrado por estado de membresía (`Activo`, `Inactivo`, `Pendiente`, `Expirado`).
   - Libro mayor de transacciones financieras y widget de recaudación total.

4. [**04. Estadísticas del Negocio y Dashboard de Analítica**](./04_estadisticas_dashboard_analytics.md)
   - Dashboard consolidado con KPIs ejecutivos en un solo request.
   - Métricas de afluencia, hora pico y distribución horaria de visitas.
   - Reporte financiero cruzado (por plan y método de pago).
   - Auditoría de turnos de caja y control de descuadres (sobrantes/faltantes).

5. [**Operaciones de Encargado (Submódulo Mostrador)**](./encargado/README.md)
   - Apertura y cierre de caja física por turno.
   - Validación y escaneo de boletos y carnet QR.
   - Emisión de pases casuales y cobro en mostrador.

