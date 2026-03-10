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

**Nota:** Estos scripts barren no solo la aplicación, sino también sus extensiones de núcleo (kexts) y agentes de lanzamiento.

---

> [!CAUTION]
> Estas herramientas realizan purgas irreversibles. Se recomienda revisar el listado de archivos detectados antes de confirmar la eliminación definitiva.
