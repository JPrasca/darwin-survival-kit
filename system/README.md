# ⚙️ Módulo: System

Guía de uso para las herramientas de diagnóstico y mantenimiento del núcleo del sistema Darwin.

---

## 🛠️ Herramientas Disponibles

### 1. `maintenance-tool.sh`
Orquestador central del kit. Permite ejecutar diversas tareas desde un solo punto de entrada.

**Uso:**
```bash
./system/maintenance-tool.sh [acción]
```

**Acciones Disponibles:**
- `list`: Muestra todas las acciones configuradas.
- `malware-hunter`: Inicia la auditoría de seguridad.
- `docker-clean`: Ejecuta la purga de artefactos Docker.
- `check-disk`: Muestra el reporte de almacenamiento.
- `scan-sql [directorio]`: Analiza archivos SQL en la ruta especificada.
- `generic-uninstall [nombre_app]`: Desinstalación rápida de una aplicación.

---

### 2. `malware-hunter.sh`
Auditoría técnica de seguridad orientada a la detección de persistencia y verificación de integridad.

**Uso:**
```bash
./system/malware-hunter.sh
```
**Alcance:**
- Análisis de directorios `/Library/LaunchAgents` y `/Library/LaunchDaemons`.
- Verificación de firmas digitales (`codesign`) en aplicaciones.
- Búsqueda de archivos ocultos irregulares en el escritorio y descargas.

---

### 3. `clean-phantoms.sh`
Eliminación de archivos residuales de aplicaciones previamente desinstaladas (fantasmas de persistencia).

**Uso:**
```bash
./system/clean-phantoms.sh
```
**Nota:** El script analiza patrones conocidos (OneDrive, CCleaner, Office, etc.) y solicita confirmación antes de la purga definitiva.

---

### 4. `check-disk.sh`
Reporte rápido de utilización de almacenamiento en volúmenes macOS.

**Uso:**
```bash
./system/check-disk.sh
```

---

### 5. `docker-cleaner.sh`
Gestión de higiene para entornos Docker. Elimina contenedores detenidos, imágenes huérfanas y volúmenes sin uso.

**Uso:**
```bash
./system/docker-cleaner.sh
```

---

> [!CAUTION]
> La mayoría de estas herramientas requieren privilegios de superusuario (`sudo`) para interactuar con directorios del sistema. Se recomienda revisar el contenido de los scripts ante cualquier duda técnica.
