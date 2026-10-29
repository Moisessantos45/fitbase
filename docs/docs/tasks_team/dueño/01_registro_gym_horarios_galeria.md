# 📌 Tarea D-1: Registro de Gimnasio, Horarios Semanales y Galería de Fotos

## 🎯 Objetivo
Permitir al Dueño registrar su sucursal de gimnasio de forma completa e intuitiva tras haber creado su cuenta. La funcionalidad debe permitir ingresar la información comercial y geográfica de la sede, definir los horarios de apertura y cierre de cada día de la semana, y subir la galería fotográfica junto con la imagen de portada.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Alta Integral de Gimnasio** | `POST` | `/api/v1/gyms` | `Auth`, `Idempotency` | `multipart/form-data` |
| **Consultar Gimnasio Propio** | `GET` | `/api/v1/gyms/my-gym` | `Auth`, `Idempotency` | JSON |
| **Listar Gimnasios del Dueño** | `GET` | `/api/v1/gyms/my-gyms` | `Auth`, `Idempotency` | JSON |
| **Actualizar Información** | `PUT` | `/api/v1/gyms/:id` | `Auth`, `Idempotency` | JSON |
| **Guardar Horarios Semanales** | `POST` | `/api/v1/gyms/:id/schedules` | `Auth`, `Idempotency` | JSON |
| **Editar Horario de un Día** | `PUT` | `/api/v1/gyms/:id/schedules/:schedule_id` | `Auth`, `Idempotency` | JSON |
| **Subir Fotos Adicionales** | `POST` | `/api/v1/gyms/:id/photos` | `Auth`, `Idempotency` | `multipart/form-data` |
| **Eliminar Foto de Galería** | `DELETE` | `/api/v1/gyms/:id/photos/:photo_id` | `Auth`, `Idempotency` | JSON |
| **Actualizar Foto de Portada** | `POST` / `PUT` | `/api/v1/gyms/:id/cover` | `Auth`, `Idempotency` | `multipart/form-data` |

---

## 📋 Checklist de Implementación en la UI

### 1. Formulario de Datos Generales y Geolocalización
- [ ] **Campos de Información**:
  - `name`: Nombre comercial de la sede (obligatorio, máx 100 caracteres).
  - `address`: Dirección física completa (obligatorio, máx 255 caracteres).
  - `phone`: Teléfono de contacto (obligatorio, 10 dígitos o formato E.164).
  - `email`: Correo oficial de la sede (validación estricta de sintaxis).
- [ ] **Selector de Ubicación en Mapa (Geolocalización)**:
  - Mapa interactivo integrado (ej. Leaflet, Mapbox o Google Maps).
  - Marcador arrastrable (Pin) que captura automáticamente `latitude` y `longitude`.
  - Botón "Usar mi ubicación actual" mediante la API de geolocalización del navegador o dispositivo móvil.

### 2. Configuración de Horarios de Atención Semanales
- [ ] **Tabla / Listado de los 7 Días de la Semana (Día 0 = Domingo a Día 6 = Sábado)**:
  - Selector de hora de apertura y cierre para cada día.
  - Conversión automática en frontend entre formato visual `HH:mm` y minutos acumulados requeridos por el backend (`minutes = hora * 60 + minutos`):
    - *Ejemplo*: `08:00` = `480` minutos; `21:30` = `1290` minutos.
  - Switch o Checkbox *"Cerrado este día"* (`is_closed: true`). Si está cerrado, inhabilitar los inputs de hora y enviar `open_minutes: 0, close_minutes: 0`.
  - Botón de conveniencia: *"Copiar horario de lunes a viernes"*.

### 3. Galería de Fotografías y Portada
- [ ] **Carga de Imágenes**:
  - Input `multipart/form-data` con soporte para arrastrar y soltar (Drag and Drop) de múltiples archivos fotográficos (`photos`).
  - Previsualización inmediata en miniatura antes de confirmar la subida.
  - El backend optimiza automáticamente cada foto con filtro Lanczos y compresión a JPEG (`max 1600px`).
- [ ] **Gestión de Portada (`background_id`)**:
  - Selector para marcar una de las imágenes cargadas como portada principal de la sede.
  - Botón para cambiar portada en cualquier momento (`POST /api/v1/gyms/:id/cover`).
- [ ] **Eliminación Segura**:
  - Botón de papelera en cada miniatura de la galería (`DELETE /api/v1/gyms/:id/photos/:photo_id`).
  - Modal de confirmación para prevenir eliminaciones accidentales.

