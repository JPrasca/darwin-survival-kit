# 🧹 Módulo: Uninstalls

Guía de uso para las herramientas de desinstalación profunda y eliminación de residuos en macOS.

---

## 🛠️ Herramientas Disponibles

### 1. `app-nuker.sh` (Recomendado)
Desinstalador universal inteligente. Busca residuos en Application Support, Caches y Preferences basándose en el nombre de la aplicación y su Bundle ID.

**Uso:**
```bash
./uninstalls/app-nuker.sh [NombreApplication]
```
**Ejemplo:**
```bash
./uninstalls/app-nuker.sh "Spotify"
```
**Proceso:**
1.  Búsqueda dinámica de la `.app` en `/Applications` y `~/Applications`.
2.  Detección del Bundle Identifier (`mdls`).
3.  Escaneo recursivo de residuos en rutas del sistema.
4.  Solicitud de confirmación antes de la purga masiva.

---

### 2. Desinstaladores Específicos
Herramientas optimizadas para aplicaciones persistentes con rutas de instalación no estándar.

| Herramienta | Aplicación Objetivo | Uso |
| :--- | :--- | :--- |
| `uninstall-office.sh` | Microsoft Office Suite | `./uninstalls/uninstall-office.sh` |
| `uninstall-onedrive.sh` | Microsoft OneDrive | `./uninstalls/uninstall-onedrive.sh` |
| `uninstall-lghub.sh` | Logitech G HUB | `./uninstalls/uninstall-lghub.sh` |
| `uninstall-virtualbox.sh` | Oracle VirtualBox | `./uninstalls/uninstall-virtualbox.sh` |
| `uninstall-imovie.sh` | Apple iMovie | `./uninstalls/uninstall-imovie.sh` |
| `uninstall-garageband.sh` | Apple GarageBand | `./uninstalls/uninstall-garageband.sh` |

**Nota:** Algunos scripts incluyen eliminación de extensiones de núcleo (kexts) y agentes de lanzamiento según la aplicación objetivo. Los desinstaladores de apps Apple (iMovie, GarageBand) no contemplan kexts, ya que no los utilizan.

---

### `uninstall-imovie.sh`
Elimina iMovie y todos sus artefactos de usuario del sistema.

**Rutas eliminadas:**
- `/Applications/iMovie.app`
- `~/Library/Containers/com.apple.iMovieApp`
- `~/Library/Caches/com.apple.iMovieApp`
- `~/Library/Preferences/com.apple.iMovieApp.plist`
- `~/Library/Application Scripts/com.apple.iMovieApp`
- Archivos SFL de documentos recientes

**Uso:**
```bash
./uninstalls/uninstall-imovie.sh
```

> [!NOTE]
> Los proyectos guardados en `~/Movies/` no son eliminados por este script.

---

### `uninstall-garageband.sh`
Elimina GarageBand, sus bibliotecas de sonidos (Apple Loops) y todos sus artefactos de usuario del sistema.

**Rutas eliminadas:**
- `/Applications/GarageBand.app`
- `/Library/Application Support/GarageBand`
- `/Library/Application Support/iLifeMediaBrowser/Plug-Ins/iLMBGarageBandPlugin.ilmbplugin`
- `/Library/Audio/Apple Loops/Apple/Apple Loops for GarageBand`
- `~/Library/Containers/com.apple.garageband10`
- `~/Library/Containers/com.apple.STMExtension.GarageBand`
- `~/Library/Application Scripts/com.apple.garageband10`
- `~/Library/Caches/com.apple.garageband` y preferencias
- Archivos SFL de documentos recientes

**Uso:**
```bash
./uninstalls/uninstall-garageband.sh
```

> [!WARNING]
> Las Apple Loops en `/Library/Audio/Apple Loops/Apple/` pueden ser compartidas con Logic Pro o MainStage. Verificar antes de ejecutar si alguna de estas aplicaciones está instalada.

> [!NOTE]
> Los proyectos guardados en `~/Music/` no son eliminados por este script.

---

> [!CAUTION]
> Estas herramientas realizan purgas irreversibles. Se recomienda revisar el listado de archivos detectados antes de confirmar la eliminación definitiva.
