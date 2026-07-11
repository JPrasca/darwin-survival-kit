# 📦 Módulo: Setup

Guía de uso para las herramientas de configuración incial de un entorno Darwin.

---

## 🛠️ Herramientas Disponibles

### [setup_brew.sh](setup_brew.sh)
Script para la instalación automatizada de Homebrew, configuración del entorno (PATH) e instalación de herramientas esenciales (`displayplacer`, `wget`, `htop`, `git`).

### [setup_ssh.sh](setup_ssh.sh)
Script para verificar la existencia de claves SSH (`ed25519`) o generar una nueva de forma automática y silenciosa.
### [setup_precommit.sh](setup_precommit.sh)
Script para configurar un Git Hook local (`pre-commit`) que bloquea automáticamente los commits si se detectan datos sensibles usando `gitleaks`.
