# 🧬 Darwin Survival Kit

> Una colección personal y artesanal de herramientas de supervivencia y automatización para macOS (Darwin).

Este repositorio es mi "equipo de rescate" digital. Aquí centralizo todos los scripts que he ido forjando y puliendo para mantener mi sistema limpio, seguro y eficiente.

---

## 🛠️ Contenido del Kit

El kit está organizado por el propósito de cada herramienta:

### 🧹 [Uninstalls](./uninstalls/)
Herramientas para eliminar software de raíz, sin dejar residuos.
- **`app-nuker.sh`**: El desinstalador universal inteligente. Detecta Bundle IDs y barre directorios ocultos.
- **`uninstall-office.sh`**: Limpieza profunda de la suite Office (Word, Excel, PPT).
- **`uninstall-onedrive.sh`**: Eliminación completa de OneDrive y rastro de CloudStorage.
- **`uninstall-lghub.sh`**: Desinstalador específico para Logitech G HUB.
- **`uninstall-virtualbox.sh`**: Remueve VirtualBox, sus extensiones de kernel y VMs.

### ⚙️ [System](./system/)
Mantenimiento y diagnóstico del corazón del sistema (Darwin).
- **`maintenance-tool.sh`**: Orquestador principal de mantenimiento y acceso rápido a utilidades.
- **`check-disk.sh`**: Monitoreo de salud y espacio en disco.
- **`docker-cleaner.sh`**: Purga inteligente de artefactos Docker (imágenes, volúmenes, caché).

### 💻 [Dev-Tools](./dev-tools/)
Utilidades para el flujo de trabajo de desarrollo.
- **`scan-sql.sh`**: Escáner preventivo de sentencias SQL peligrosas (DROP, DELETE sin WHERE).
- **`check-antigravity-quota.sh`**: Seguimiento de consumo y cuota de Google Gemini API.

### 📦 [Setup](./setup/)
Configuración rápida de un entorno fresco.
- **`install-notunes.sh`**: Bloquea la apertura automática de Apple Music y configura Spotify como reemplazo.

---

## 📜 Estándares de Ingeniería

Cada herramienta en este kit debe cumplir con nuestros pilares definidos en `.agents/skills/script_architect`:

1.  **Seguridad**: Uso obligatorio de `set -euo pipefail` y comillas en variables para manejar rutas con espacios.
2.  **Interfaz Inteligente**: Detección de terminal activa (TTY) para visualización de colores profesional sin ensuciar logs.
3.  **Modularidad**: Código basado en funciones y bloques `main` para facilitar el mantenimiento.
4.  **Higiene**: Sin "ruido" de proyectos externos ni metadatos innecesarios en las cabeceras.

---

## 🚀 Cómo usarlo

1.  Clona el repositorio: `git clone <repo-url>`
2.  Otorga permisos si es necesario: `chmod +x folder/script.sh` (aunque ya deberían venir listos).
3.  Ejecuta con precaución: muchos scripts requieren privilegios de `sudo`.

---

> [!NOTE]
> Este kit es personal y está "hecho a mano". Úsalo bajo tu propia responsabilidad y siempre lee el código antes de ejecutar.
