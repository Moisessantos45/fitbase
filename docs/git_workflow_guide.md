# Guía Completa de Flujo de Trabajo con Git en Fitbase

Esta guía documenta el estándar para trabajar con el repositorio de **Fitbase** de forma ordenada, colaborativa y sin pérdida de cambios ni conflictos.

---

## Enlaces del Proyecto

* **Descarga del APK (Android Release)**: [https://zurl.mmabitec.uk/nbQlPz](https://zurl.mmabitec.uk/nbQlPz)
* **Repositorio del Backend (API REST)**: [https://github.com/Moisessantos45/fitbase_backend](https://github.com/Moisessantos45/fitbase_backend)
* **Repositorio de la Aplicación Móvil**: [https://github.com/Moisessantos45/fitbase](https://github.com/Moisessantos45/fitbase)

---

## 1. Clonar el Repositorio

Para empezar a trabajar en la aplicación móvil de Fitbase:

```bash
# Clonar el proyecto
git clone https://github.com/Moisessantos45/fitbase.git

# Entrar en la carpeta del proyecto
cd fitbase

# Configurar variables de entorno iniciales (env.dev.json)
cat << 'EOF' > env.dev.json
{
  "API_BASE_V1": "https://fitbase.mmabitec.uk/api/v1"
}
EOF

# Descargar dependencias de Flutter
flutter pub get
```

---

## 2. Convención y Nomenclatura de Ramas

Nunca se trabaja directamente sobre la rama `main`. Cada tarea debe contar con una rama propia:

### Prefijos Estándar

| Prefijo | Uso | Ejemplo |
|---|---|---|
| `feature/` | Nuevas funcionalidades o pantallas | `feature/manager-caja`, `feature/user-qr-scanner` |
| `fix/` o `bugfix/` | Corrección de fallos en desarrollo | `fix/r8-missing-classes`, `fix/404-user-profile` |
| `hotfix/` | Correcciones críticas directas para producción | `hotfix/stripe-checkout-session` |
| `refactor/` | Mejoras de código o arquitectura sin cambiar comportamiento | `refactor/dio-safe-mappers` |

### Reglas para nombrar ramas:
1. Usar únicamente letras minúsculas.
2. Separar las palabras con guiones (`-`), nunca con espacios o barras innecesarias.
3. Ser conciso y descriptivo con el alcance del cambio.

---

## 3. Comandos Modernos: `git switch` vs `git checkout`

| Acción | Comando moderno (Recomendado) | Comando clásico equivalente |
|---|---|---|
| Cambiar a una rama existente | `git switch nombre-de-rama` | `git checkout nombre-de-rama` |
| Crear y cambiar a una nueva rama | `git switch -c feature/nueva-tarea` | `git checkout -b feature/nueva-tarea` |

---

## 4. Flujo de Trabajo Paso a Paso

### Escenario A: Iniciar una nueva tarea

```bash
# 1. Cambiar a la rama principal y descargar novedades
git switch main
git pull origin main

# 2. Crear tu rama de trabajo
git switch -c feature/mi-modulo
```

### Escenario B: Guardar cambios y subirlos

```bash
# 1. Revisar cambios
git status

# 2. Añadir cambios
git add .

# 3. Crear commit descriptivo
git commit -m "feat(modulo): implementa escáner QR de pases en mostrador"

# 4. Publicar la rama en GitHub
git push -u origin feature/mi-modulo
```

---

## 5. Manejo Seguro de Cambios Temporales (`git stash`)

> **IMPORTANTE**: Por defecto, `git stash` **no** guarda los archivos nuevos que aún no han sido rastreados (*untracked files*). Para evitar que `git pull` aborte por colisión de archivos no rastreados, utiliza siempre el parámetro `-u` (`--include-untracked`):

```bash
# Guardar cambios rastreados y no rastreados
git stash -u -m "Trabajo temporal antes de actualizar main"

# Actualizar main limpiamente
git switch main
git pull origin main

# Reanudar trabajo en tu rama
git switch feature/mi-modulo
git stash pop
```

---

## 6. Integración y Pull Requests

1. Una vez concluida la funcionalidad en tu rama, asegúrate de que el código compila y cumple con el análisis estático:
   ```bash
   flutter analyze
   ```
2. Realiza push a tu rama y abre un Pull Request (PR) hacia `main` en GitHub.
3. Una vez aprobado y fusionado el PR en GitHub:
   ```bash
   git switch main
   git pull origin main
   git branch -d feature/mi-modulo
   ```

---

## 7. Compilación y Verificación de Release

Antes de generar una nueva entrega, verifica la compilación con ofuscación y reducción de R8:

```bash
flutter build apk --release --dart-define-from-file=./env.dev.json --obfuscate --split-debug-info=build/app/outputs/symbols
```
