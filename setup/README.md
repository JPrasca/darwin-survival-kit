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

### [setup_terminal.sh](setup_terminal.sh)
Script de personalización y embellecimiento de la terminal nativa de macOS. Instala `JetBrains Mono Nerd Font`, plugins de Zsh (`zsh-autosuggestions`, `zsh-syntax-highlighting`), `eza`, integra `fzf` y `zoxide`, con respaldo previo automático de `~/.zshrc`.

### [revert_terminal.sh](revert_terminal.sh)
Script de reversión integral para restaurar la configuración original de la terminal. Recupera `~/.zshrc` desde el respaldo y permite desinstalar selectivamente los paquetes agregados vía Homebrew.
