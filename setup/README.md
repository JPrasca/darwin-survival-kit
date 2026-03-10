# 📦 Módulo: Setup

Guía de uso para las herramientas de configuración incial de un entorno Darwin.

---

## 🛠️ Herramientas Disponibles

### 1. `install-notunes.sh`
Configura el sistema para evitar que **Apple Music** se inicie automáticamente al presionar el botón de reproducción de los auriculares o teclados externos.

**Uso:**
```bash
./setup/install-notunes.sh
```

**Efectos:**
- Instalación de la utilidad `NoTunes` (utilidad minimalista).
- Configura a **Spotify** como el reproductor objetivo por defecto del sistema.
- Crea un agente de lanzamiento para mantener el proceso activo.

---

> [!TIP]
> Esta herramienta es ideal para instalaciones limpias de macOS donde se prefiere utilizar reproductores de terceros sobre la suite nativa de Apple.
