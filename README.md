# 🧬 Darwin Survival Kit

> Colección técnica de herramientas de auditoría, mantenimiento y automatización para macOS (Darwin).

Conjunto de utilidades diseñado para la gestión eficiente del sistema, enfocado en la limpieza profunda, seguridad y optimización de recursos.

---

## 🛠️ Contenido del Kit

### 🧹 [Uninstalls](./uninstalls/README.md) (Ver Guía de Uso)
Herramientas para eliminar software de raíz, sin dejar residuos:
- **`app-nuker.sh`**: Desinstalador universal con detección de Bundle IDs.
- **`uninstall-office.sh`, `uninstall-onedrive.sh`, etc.**: Purga específica de suites persistentes.

### ⚙️ [System](./system/README.md) (Ver Guía de Uso)
Mantenimiento y diagnóstico del núcleo del sistema:
- **`maintenance-tool.sh`**: Orquestador principal de utilidades.
- **`malware-hunter.sh`**: Auditoría de seguridad y firmas digitales.
- **`clean-phantoms.sh`**: Eliminación de residuos de aplicaciones desinstaladas.
- **`check-disk.sh`**, **`docker-cleaner.sh`**: Reportes de salud y purga de artefactos.

### 💻 [Dev-Tools](./dev-tools/README.md) (Ver Guía de Uso)
Utilidades para flujos de desarrollo:
- **`scan-sql.sh`**: Análisis preventivo de sentencias SQL peligrosas.
- **`check-antigravity-quota.sh`**: Seguimiento de consumo y cuota de Gemini API.

### 📦 [Setup](./setup/README.md) (Ver Guía de Uso)
Configuración de entorno:
- **`install-notunes.sh`**: Configura Spotify como reemplazo de Apple Music.

---

## 📜 Estándares de Ingeniería

El kit se rige por las directivas definidas en`.agents/skills/script_architect`:

1.  **Seguridad**: Uso estricto de `set -euo pipefail` y manejo seguro de variables.
2.  **Interfaz**: Detección de terminal (TTY) para visualización técnica de colores.
3.  **Neutralidad Técnica**: Interacciones impersonales, sin uso de personas gramaticales (tú/usted), enfocadas en la ejecución y el reporte de estados.
4.  **Estética de Ingeniería**: Salidas de consola limpias, sin emojis, con encabezados técnicos y divisores claros.

---

## 🚀 Uso

1.  Clonar el repositorio: `git clone <repo-url>`
2.  Verificar permisos de ejecución: `chmod +x folder/script.sh`
3.  Ejecutar: Se recomienda precaución, ya que diversos procesos requieren privilegios de `sudo`.

---

> [!IMPORTANT]
> Herramientas de carácter técnico. Se recomienda la lectura del código fuente antes de su ejecución para comprender el alcance de las acciones realizadas.
