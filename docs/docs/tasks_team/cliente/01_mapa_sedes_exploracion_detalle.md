# 📌 Tarea C-1: Mapa Interactivo de Sedes Cercanas y Ficha de Detalle

## 🎯 Objetivo
Permitir a los usuarios —tanto en el acceso público como autenticados en la plataforma (Web y Móvil)— explorar en un **mapa interactivo** las sedes de gimnasios más cercanas a su ubicación física. Al presionar sobre un marcador en el mapa, debe mostrar una tarjeta con la información más relevante de la sede y un botón destacado **"Ver Detalles"**, el cual abre la ficha completa con los datos de contacto, horarios de atención de lunes a domingo (con indicador en tiempo real de "Abierto" o "Cerrado") y su galería de fotografías.

---

## 🛠️ Especificaciones Técnicas y Endpoints del Backend

| Acción | Método | Endpoint | Middleware | Formato |
| :--- | :---: | :--- | :--- | :--- |
| **Listar Gimnasios Cercanos (Público/Auth)** | `GET` | `/api/v1/gyms?lat={lat}&lng={lng}&search={query}` | `Idempotency` | JSON (Cacheado en Redis 2m) |
| **Consultar Detalle Completo de Sede** | `GET` | `/api/v1/gyms/:id` | `Idempotency` | JSON |

---

## 📋 Checklist de Implementación en la UI

### 1. Mapa Interactivo con Geolocalización
- [ ] **Detección de Ubicación del Usuario**:
  - Solicitar permiso de geolocalización al entrar a la vista (API `navigator.geolocation` en navegador o `Location.getCurrentPositionAsync` en React Native / Flutter).
  - Si el usuario concede permiso: centrar el mapa en su latitud y longitud y enviar `?lat=...&lng=...` al backend.
  - Si el usuario deniega permiso: centrar en una ubicación por defecto o permitir buscar por nombre de ciudad/colonia con el input de búsqueda `?search=...`.
- [ ] **Renderizado de Marcadores (Pines)**:
  - Marcador distintivo azul para *"Tu ubicación actual"*.
  - Pines de marca para cada gimnasio retornado por `GET /api/v1/gyms`.
  - Agrupación automática de marcadores (Marker Clustering) si hay alta densidad de sedes en la misma zona.

### 2. Tarjeta Previa de Sede (Popup / Bottom Sheet)
- [ ] **Al pulsar un marcador en el mapa**:
  - Desplegar una tarjeta flotante o panel inferior (Bottom Sheet) con los datos clave:
    - **Foto de Portada**: Renderizada desde `background_url`.
    - **Nombre del Gimnasio**: Tipografía destacada.
    - **Dirección**: Calle, número y colonia.
    - **Distancia**: Calculada y formateada por el backend en metros o kilómetros (ej. *"a 1.2 km de ti"*).
    - **Estado en Tiempo Real**: Badge dinámico:
      - 🟢 **Abierto**: Si la hora actual se encuentra dentro del rango de atención de hoy.
      - 🔴 **Cerrado**: Si hoy está marcado como cerrado o se encuentra fuera de horario.
    - **Teléfono y Correo**: Iconos rápidos para llamar o enviar mensaje.
- [ ] **Botón de Acción "Ver Detalles"**:
  - Botón prominente en la tarjeta que realiza la transición a la pantalla de detalle completo (`/gyms/:id`).

### 3. Pantalla de Detalle Completo del Gimnasio
- [ ] **Consumo de `GET /api/v1/gyms/:id`**:
  - Encabezado con imagen de portada (`background_url`) y botón para volver al mapa.
  - **Bloque de Información y Contacto**:
    - Nombre, dirección completa, teléfono de atención al cliente y correo electrónico.
    - Botón *"Cómo llegar"* que abre la ruta en Google Maps / Apple Maps usando las coordenadas `latitude` y `longitude`.
  - **Bloque de Horarios Semanales (Lunes a Domingo)**:
    - Lista ordenada de los 7 días de la semana (Día 0: Domingo a Día 6: Sábado).
    - Conversión de `open_minutes` y `close_minutes` a formato amigable `HH:mm` (ej. `06:00 - 22:00 hrs`).
    - Indicador visual destacando el día de hoy con su estatus actual (**"Abierto Ahora"** o **"Cerrado Ahora"**).
  - **Galería de Fotografías de la Sede**:
    - Carrusel interactivo o cuadrícula visual de las fotografías del gimnasio (`photos: [{ id, url }]`).
    - Al pulsar una imagen, abrir visor de fotos a pantalla completa (Lightbox) con zoom y desplazamiento lateral.
  - **Sección Inferior**:
    - Botón para ver los planes de membresía disponibles en esta sede (conduce a la Tarea C-2).

