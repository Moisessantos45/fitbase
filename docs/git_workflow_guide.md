# Guía Completa de Flujo de Trabajo con Git

Esta guía documenta el estándar para trabajar con repositorios Git de forma ordenada, colaborativa y sin conflictos.

---

## 1. Clonar el Repositorio

Para empezar a trabajar en un proyecto ya existente en GitHub:

```bash
# Clonar el proyecto
git clone https://github.com/Moisessantos45/unicompra.git

# Entrar en la carpeta del proyecto
cd unicompra

# Verificar la rama actual y el estado
git status
```

---

## 2. Convención y Nomenclatura de Ramas

Para evitar colisiones y mantener el orden del equipo, nunca se trabaja directamente sobre la rama `main`. Se debe crear una rama específica por cada tarea.

### Prefijos recomendados

| Prefijo | Uso | Ejemplo |
|---|---|---|
| `feature/` | Nuevas funcionalidades o pantallas | `feature/login-de-usuario`, `feature/catalogo-productos` |
| `fix/` o `bugfix/` | Corrección de fallos en desarrollo | `fix/error-validacion-correo` |
| `hotfix/` | Correcciones críticas directas para producción | `hotfix/crash-al-pagar` |
| `support/` | Mantenimiento de versiones anteriores específicas | `support/v1-supabase` |
| `refactor/` | Mejoras de código o arquitectura sin cambiar funcionalidad | `refactor/api-auth-service` |

### Reglas para nombrar ramas:
1. Usar únicamente letras minúsculas.
2. Separar las palabras con guiones (`-`), nunca con espacios o barras diagonales innecesarias.
3. Ser conciso pero descriptivo: indica claramente qué hace la rama.
4. No incluir nombres personales en la rama (ejemplo incorrecto: `feature/juan-login`).

---

## 3. Comandos Modernos: `git switch` vs `git checkout`

En versiones modernas de Git se prefiere `git switch` para gestionar ramas, ya que separa el cambio de ramas de la manipulación de archivos:

| Acción | Comando moderno (Recomendado) | Comando clásico equivalente |
|---|---|---|
| Cambiar a una rama existente | `git switch nombre-de-rama` | `git checkout nombre-de-rama` |
| Crear y cambiar a una nueva rama | `git switch -c feature/nueva-tarea` | `git checkout -b feature/nueva-tarea` |

---

## 4. Flujo de Trabajo Paso a Paso

### Escenario A: Crear una nueva rama desde cero

Antes de iniciar cualquier desarrollo, asegúrate de que tu rama `main` local contenga los últimos cambios del repositorio remoto:

```bash
# 1. Cambiar a la rama principal
git switch main

# 2. Descargar los últimos cambios
git pull origin main

# 3. Crear y colocarte en tu nueva rama
git switch -c feature/login-de-usuario
```

### Escenario B: Guardar cambios y subirlos a GitHub

A medida que avances en tu código:

```bash
# 1. Revisar los archivos modificados
git status

# 2. Preparar los archivos para el commit (puedes usar un archivo o todos con .)
git add .

# 3. Registrar el commit con un mensaje claro
git commit -m "Implementa pantalla de login con validación de credenciales"

# 4. Publicar la rama en el servidor remoto por primera vez (-u configura el seguimiento)
git push -u origin feature/login-de-usuario
```

> **Nota:** El parámetro `-u origin feature/...` asocia la rama local con la remota. Para las siguientes subidas en la misma rama, solo bastará ejecutar:
> ```bash
> git push
> ```

---

## 5. Mantener tu Rama Actualizada con `main`

Mientras trabajas en tu rama, otros compañeros pueden haber subido cambios a `main`. Para evitar que tu rama quede obsoleta y prevenir conflictos graves al final, incorpora las actualizaciones frecuentemente:

```bash
# 1. Ir a main y descargar las novedades
git switch main
git pull origin main

# 2. Regresar a tu rama de trabajo
git switch feature/login-de-usuario

# 3. Fusionar las novedades de main dentro de tu rama
git merge main
```

Si no hay conflictos, Git creará un commit de fusión automáticamente. Luego puedes enviar esa actualización a tu rama remota:

```bash
git push
```

---

## 6. Cambiar de Rama sin Perder Cambios (`git stash`)

Si necesitas cambiar urgentemente a otra rama pero tienes trabajo a medias que aún no está listo para un commit, guarda temporalmente tus cambios en el baúl (`stash`):

```bash
# 1. Guardar cambios pendientes en el stash con una descripción
git stash push -m "Login a medio hacer antes de revisar bug en home"

# 2. Ya puedes cambiar de rama limpiamente
git switch main

# 3. Al volver a tu rama, recupera los cambios guardados
git switch feature/login-de-usuario
git stash pop
```

Otros comandos útiles de `stash`:
```bash
# Listar los stashes guardados
git stash list

# Descartar el último stash sin aplicarlo
git stash drop
```

---

## 7. Fusión a `main`, Tags y Manejo de Versiones

### Integración en `main` cuando la tarea esté terminada

```bash
# 1. Asegurarte de tener los últimos commits de tu rama listos y subidos
git push

# 2. Cambiar a main y actualizar
git switch main
git pull origin main

# 3. Fusionar tu rama a main
git merge feature/login-de-usuario

# 4. Subir main actualizado a GitHub
git push origin main

# 5. (Opcional) Eliminar la rama local una vez integrada
git branch -d feature/login-de-usuario
```

---

### Etiquetas y Versiones (`git tag`)

Las etiquetas identifican hitos o lanzamientos de versiones (releases):

```bash
# Crear un tag anotado con mensaje
git tag -a v1.0.0 -m "Primera versión estable"

# Subir una etiqueta específica a GitHub
git push origin v1.0.0

# O subir todas las etiquetas creadas
git push --tags
```

---

### Flujo Avanzado: Migración y Mantenimiento de Múltiples Versiones

#### 1. Marcar versión previa y crear rama de migración
```bash
# Marcar la versión actual
git tag -a v1.0.0-supabase -m "Última versión estable con Supabase"
git push origin v1.0.0-supabase

# Crear rama para la migración
git switch -c feature/custom-api

# Desarrollar y subir cambios
git add .
git commit -m "Replace Supabase with custom API"
git push origin feature/custom-api

# Fusionar a main cuando esté completa
git switch main
git merge feature/custom-api
git push origin main

# Etiquetar la nueva versión mayor
git tag -a v2.0.0 -m "Versión con API custom"
git push origin v2.0.0
```

#### 2. Soporte a versión antigua (`support/...`)
```bash
# Cambiar a la rama de soporte v1
git switch support/v1-supabase

# Crear rama para el hotfix específico
git switch -c hotfix/fix-supabase-auth

# Aplicar el arreglo
git add .
git commit -m "Fix authentication bug in Supabase version"

# Fusionar de vuelta a soporte
git switch support/v1-supabase
git merge hotfix/fix-supabase-auth

# Crear nuevo tag de versión menor
git tag -a v1.0.1 -m "Bugfix para autenticación"
git push origin support/v1-supabase
git push origin v1.0.1

# Eliminar rama temporal del hotfix
git branch -d hotfix/fix-supabase-auth
```

#### 3. Replicar un commit específico entre versiones (`cherry-pick`)
Cuando corriges un error en una versión y necesitas aplicar exactamente ese mismo arreglo en otra versión sin traer todos los cambios:

```bash
# 1. En la rama donde resolviste el error (por ejemplo main):
git switch main
git add .
git commit -m "Fix critical auth token expiration"

# 2. Obtener el hash del commit con git log (ejemplo: a1b2c3d)
git log -1 --oneline

# 3. Cambiar a la otra rama y aplicar ese commit puntual
git switch support/v1-supabase
git cherry-pick a1b2c3d

# 4. Si hay conflictos, resolverlos, añadirlos con git add . y continuar:
# git cherry-pick --continue

# 5. Subir los cambios a la rama de soporte
git push origin support/v1-supabase
```

---

## 8. Buenas Prácticas para Evitar Errores y Conflictos

1. **Nunca comitees directamente en `main`**: Trabaja siempre sobre una rama `feature/` o `fix/`.
2. **Actualiza `main` antes de crear tu rama**: Si creas tu rama desde un `main` desactualizado, arrastrarás diferencias históricas.
3. **Mantén ramas pequeñas y de ciclo corto**: Cuanto más tiempo vive una rama sin fusionarse, mayor es la probabilidad de conflictos con otros compañeros.
4. **Trae cambios de `main` con regularidad**: Haz `git merge main` en tu rama cada 1 o 2 días y siempre antes de fusionar tu trabajo a `main`.
5. **Revisa antes de comitear**: Usa `git status` y `git diff` para verificar qué archivos estás añadiendo. Evita agregar archivos temporales, logs o credenciales (`.env`).
6. **¿Qué hacer si ocurre un conflicto en `git merge`?**:
   - Git marcará los archivos en conflicto entre `<<<<<<<`, `=======` y `>>>>>>>`.
   - Abre cada archivo marcado, decide qué código debe conservarse y elimina las marcas de Git.
   - Ejecuta `git add <archivo-resuelto>` y finalmente `git commit -m "Resuelve conflictos de merge con main"`.
   - Si prefieres cancelar el merge y volver al estado previo: `git merge --abort`.

---

## 9. Hoja de Referencia Rápida (Cheat Sheet)

```bash
# Clonar
git clone <URL>

# Actualizar main local
git switch main && git pull origin main

# Crear y cambiar a rama nueva
git switch -c feature/mi-tarea

# Ver cambios pendientes
git status

# Guardar cambios
git add .
git commit -m "Mensaje descriptivo"

# Subir rama por primera vez
git push -u origin feature/mi-tarea

# Subidas posteriores
git push

# Guardar cambios temporales sin commit
git stash push -m "Pausa"
git stash pop

# Integrar novedades de main en tu rama
git switch main && git pull origin main
git switch feature/mi-tarea
git merge main
```

