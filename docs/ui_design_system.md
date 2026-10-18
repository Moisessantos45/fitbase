# Fitbase — Sistema de Diseño y Especificación de UI (Design System)

Este documento contiene la guía visual, especificación de tokens, componentes y directrices de diseño utilizadas en la aplicación móvil **Fitbase**, preparadas para su réplica exacta en la **versión Web**.

---

## 1. Concepto y Filosofía de Diseño
* **Estilo visual:** Modo oscuro de alto impacto (*Dark Sport Aesthetic*) con acentos en verde lima/neón de alto contraste.
* **Sensación de marca:** Energética, moderna, prémium, enfocada en rendimiento fitness y experiencia táctil fluida.
* **Geometría:** Bordes redondeados pronunciados (`border-radius: 16px - 24px`), tarjetas sólidas con sutiles bordes delimitadores (`1px solid #2C2C2E`), y jerarquía tipográfica limpia.

---

## 2. Referencias Visuales (`./ui`)

El diseño de Fitbase fue extraído y sintetizado a partir de las referencias situadas en el directorio `ui/`:

| Archivo de Referencia | Elementos Adoptados en el Diseño |
| :--- | :--- |
| `ui/original-865050761009d1df7c25d94b14081e6a.png` | • Paleta base oscura (`#101010`) con verde neón (`#D2F801`).<br>• Estructura de tarjetas de categorías y botones de acción rápida.<br>• Selector de enfoque de ejercicios con pills y contraste nítido. |
| `ui/original-dc3657e7c51d6a9b960b82e04bb9a7e9.png` | • Portada / Landing con branding tipográfico contundente (*Fitbase*).<br>• Distribución de cards de entrenadores y rutinas del día.<br>• Botones de ancho completo con color lima y texto oscuro (`on-primary`). |
| `ui/original-7f911d0df6bc558d8d4796d1bda1c2f9.png` | • Estructura del perfil de usuario y métricas divididas en cajas numéricas.<br>• Lista de menú de opciones con iconos redondeados y flechas de navegación.<br>• Distribución de paquetes de entrenamiento con badges destacados. |
| `ui/original-8edc5d357d7c68de0c395c55ed8c3feb.png` | • Temporizadores, indicadores de progreso circular/lineal y listas de ejercicios.<br>• Cabeceras limpias con acciones a los extremos y foco en el contenido central. |

---

## 3. Paleta de Colores (Design Tokens)

Para la réplica en Web, definir las siguientes variables CSS en `:root`:

```css
:root {
  /* Fondos y Superficies */
  --color-bg: #101010;
  --color-surface: #1C1C1E;
  --color-surface-light: #2C2C2E;
  --color-card: #18181A;
  --color-card-highlight: #222226;
  --color-border: #2C2C2E;

  /* Colores de Acento Primario (Lima Fitness) */
  --color-primary: #D2F801;
  --color-primary-dark: #9CB800;
  --color-on-primary: #101010;

  /* Tipografía y Textos */
  --color-text-primary: #FFFFFF;
  --color-text-secondary: #8E8E93;
  --color-text-muted: #636366;

  /* Estados y Feedback */
  --color-success: #30D158;
  --color-warning: #FF9F0A;
  --color-error: #FF453A;
  --color-info: #0A84FF;

  /* Gradientes */
  --gradient-card-lime: linear-gradient(135deg, #222904 0%, #1C1C1E 100%);
  --gradient-gold-dark: linear-gradient(135deg, #263300 0%, #1C1C1E 100%);
}
```

### Tabla de Equivalencias de Color

| Nombre de Token | Hex | RGB | Uso Principal en la UI |
| :--- | :--- | :--- | :--- |
| `background` | `#101010` | `rgb(16, 16, 16)` | Fondo general de todas las pantallas / páginas web. |
| `surface` | `#1C1C1E` | `rgb(28, 28, 30)` | Fondo de tarjetas, campos de texto, modales y barras de navegación. |
| `surfaceLight` | `#2C2C2E` | `rgb(44, 44, 46)` | Fondos secundarios, contenedores de iconos y chips inactivos. |
| `primary` | `#D2F801` | `rgb(210, 248, 1)` | Color de acento, botón principal, badges de alerta positiva, activos en menú. |
| `primaryDark` | `#9CB800` | `rgb(156, 184, 0)` | Hover en botones primarios, bordes en foco y contrastes secundarios. |
| `onPrimary` | `#101010` | `rgb(16, 16, 16)` | Color del texto e icono que se renderiza SOBRE el color primario lima. |
| `textPrimary` | `#FFFFFF` | `rgb(255, 255, 255)` | Títulos, encabezados, precios y textos destacados. |
| `textSecondary` | `#8E8E93` | `rgb(142, 142, 147)` | Etiquetas, descripciones secundarias y textos de ayuda. |
| `textMuted` | `#636366` | `rgb(99, 99, 102)` | Fechas, subtítulos discretos, placeholders de formulario. |
| `border` | `#2C2C2E` | `rgb(44, 44, 46)` | Borde de tarjetas y delimitadores entre secciones (`1px solid`). |
| `success` | `#30D158` | `rgb(48, 209, 88)` | Estado de membresía al día, checkmarks y pagos aprobados. |
| `warning` | `#FF9F0A` | `rgb(255, 159, 10)` | Membresías próximas a vencer y alertas de facturación. |
| `error` | `#FF453A` | `rgb(255, 69, 58)` | Transacciones canceladas, membresías vencidas y botones destructivos. |

---

## 4. Tipografía y Escala de Textos
* **Familia tipográfica recomendada en Web:** `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`.
* **Pesos utilizados:** `400` (Regular), `500` (Medium), `600` (SemiBold), `700` (Bold), `900` (Black para títulos de impacto).

### Escala de Tamaños
* **Display / Hero Title:** `32px` — Bold / 900 — Letter spacing: `2.5px` (Ej. Logotipo `FITBASE`).
* **H1 / Page Titles:** `28px` — Bold — Letter spacing: `-0.5px`.
* **H2 / Section Titles:** `22px` — Bold.
* **H3 / Card Titles:** `18px` — SemiBold / Bold.
* **Body Normal:** `15px` / `16px` — Regular / Medium — Line height: `1.5`.
* **Body Small / Subtitles:** `13px` / `14px` — Medium.
* **Badges / Footers / Meta:** `11px` / `12px` — SemiBold / Bold.

---

## 5. Sistema de Espaciado y Responsividad (Grid & Breakpoints)

Para mantener la misma armonía en Web que se implementó con `LayoutBuilder`:

### Breakpoints
* **Mobile:** `< 600px`
* **Tablet / Small Laptop:** `600px - 1023px`
* **Desktop / Wide Screen:** `>= 1024px`

### Reglas de Padding Horizontal
* **Mobile (`< 600px`):** Padding lateral de `20px` a `24px`.
* **Tablet / Landscape / Desktop (`>= 600px`):** Padding lateral de `80px` (o contenedor centrado con `max-width: 1200px; margin: 0 auto; padding: 0 40px;`).
* **Formularios / Tarjetas centradas (Login, Register):** `max-width: 440px` a `520px` centrado horizontal y verticalmente.

### Disposición de Grids (Cards y Métricas)
* **Mobile:** 2 columnas (relación de aspecto `1.05`).
* **Tablet / Desktop:** 4 columnas (relación de aspecto `1.3`).

---

## 6. Especificación de Componentes Clave

### A. Botones (`CustomButton`)
```css
/* Botón Primario (Lima Neón) */
.btn-primary {
  height: 54px;
  background-color: var(--color-primary);
  color: var(--color-on-primary);
  font-weight: 700;
  font-size: 16px;
  border-radius: 16px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  transition: transform 0.15s ease, background-color 0.15s ease;
}
.btn-primary:hover {
  background-color: var(--color-primary-dark);
}

/* Botón Secundario (Oscuro) */
.btn-secondary {
  height: 54px;
  background-color: var(--color-surface-light);
  color: var(--color-text-primary);
  font-weight: 700;
  border-radius: 16px;
  border: none;
  cursor: pointer;
}

/* Botón Bordeado (Outlined) */
.btn-outlined {
  height: 54px;
  background-color: transparent;
  color: var(--color-primary);
  border: 1.5px solid var(--color-primary);
  font-weight: 700;
  border-radius: 16px;
  cursor: pointer;
}
```

### B. Campos de Formulario (`CustomTextField`)
```css
.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.input-field {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 16px;
  color: var(--color-text-primary);
  font-size: 15px;
  padding: 16px;
  outline: none;
  transition: border-color 0.2s ease;
}

.input-field:focus {
  border-color: var(--color-primary);
}

.input-field::placeholder {
  color: var(--color-text-muted);
}
```

### C. Tarjeta de Métrica (`MetricSummaryCard`)
* **Fondo:** `#1C1C1E` (`var(--color-surface)`).
* **Borde:** `1px solid #2C2C2E`.
* **Border Radius:** `20px`.
* **Padding:** `14px` vertical, `16px` horizontal.
* **Estructura:**
  * Fila superior: Título en gris claro (`#8E8E93`, `13px`) + Icono dentro de un círculo con fondo de baja opacidad (`rgba(210, 248, 1, 0.15)`).
  * Valor central: Tipografía `22px` a `26px`, negrita, blanca.
  * Subtítulo inferior: `12px`, color lima neón, seminegrita (ej. `+24 esta semana`).

### D. Tarjeta de Plan (`PlanCard`)
* **Border Radius:** `24px`.
* **Borde:** `1px solid var(--color-border)`. En caso de plan popular: `2px solid var(--color-primary)`.
* **Badge Popular:** Píldora en esquina superior derecha con fondo lima `#D2F801`, texto `#101010`, `font-size: 10px`, `font-weight: 900`, `letter-spacing: 0.5px`.
* **Checkmarks de beneficios:** Icono circular de check relleno en verde lima `#D2F801`.
* **Botón de acción:** Incluido al pie de la tarjeta.

### E. Tarjeta de Sucursal de Gimnasio (`GymLocationCard`)
* **Badge de distancia:** Pill redondeada con icono de brújula o navegación en lima y distancia en `12px` bold.
* **Datos incluidos:** Nombre de la sede, dirección completa con icono de mapa, horario de operación y teléfono de contacto.
* **Botón:** *"Ver Ruta"* con borde lima (`outlined`).

### F. Pase Digital de Acceso (QR Card)
* **Gradiente de fondo:** `linear-gradient(135deg, #222904 0%, #1C1C1E 100%)`.
* **Borde:** `1px solid rgba(210, 248, 1, 0.5)`.
* **Contenedor del código QR:** Fondo blanco sólido con esquinas redondeadas (`12px`) y padding de `12px` para asegurar máximo contraste.
* **Badge de estado:** `"QR LISTO"` con fondo lima.

---

## 7. Navegación y Flujos de Pantallas

### Estructura de Rutas Recomendada para la Web

| Ruta Web | Rol / Acceso | Componente Equivalente Flutter |
| :--- | :--- | :--- |
| `/login` | Público | `LoginScreen` (conmutador rápido Admin/Usuario + link a Invitado) |
| `/register` | Público | `RegisterScreen` |
| `/guest` | Invitado | `GuestHomeScreen` (Planes + Sedes) |
| `/app/home` | Usuario | `UserHomeScreen` (QR, agendas, accesos directos) |
| `/app/plans` | Usuario | `UserPlansScreen` |
| `/app/payments` | Usuario | `UserPaymentsScreen` (Estado membresía, pagar, historial) |
| `/app/subscriptions` | Usuario | `UserSubscriptionsScreen` (Detalle de suscripción activa) |
| `/app/map` | Usuario | `GymMapScreen` (Sedes y mapa interactivo) |
| `/admin/dashboard` | Administrador | `AdminDashboardScreen` (Métricas, aforo, resumen en vivo) |
| `/admin/subscribers` | Administrador | `AdminSubscribersScreen` (Lista de miembros, filtros, modificar suscripción) |
| `/admin/plans` | Administrador | `AdminPlansScreen` (Crear y editar planes) |
| `/admin/payments` | Administrador | `AdminPaymentsScreen` (Registro y modificación de transacciones) |
| `/admin/gym` | Administrador | `AdminGymEditScreen` (Datos y coordenadas de la sede) |
| `/admin/settings` | Administrador | `AdminSettingsScreen` (Configuración de admin, aforo, alertas y cerrar sesión) |
| `/settings` | Común | `SettingsScreen` |
| `/profile` | Común | `ProfileScreen` |

---

## 8. Consideraciones de Transición Móvil a Web
1. **Barra de Navegación:**
   * En móvil se usó una barra inferior con pills flotantes.
   * En web de escritorio (`>= 1024px`), se recomienda implementar una **Sidebar lateral oscura** (`width: 260px; background: #1C1C1E; border-right: 1px solid #2C2C2E;`) con los mismos iconos y el indicador activo en verde lima `#D2F801`.
2. **Modales y BottomSheets:**
   * Las acciones que en móvil abren un `showModalBottomSheet` (ej. Registrar Pago, Modificar Plan, Cancelar Suscripción) deben abrirse en Web como modales centrados (`Dialog` / `Modal`) con fondo atenuado (`backdrop-filter: blur(8px); background: rgba(0,0,0,0.6)`).
3. **Imágenes y Recursos:**
   * Mantener la proporción `1:1` para avatares y fotografías de perfil redondeadas con borde fino en `#D2F801`.
   * En mapas web, se puede integrar Leaflet o Mapbox con estilos de mapa en modo oscuro (*Dark tiles*) para coincidir con el diseño móvil.
