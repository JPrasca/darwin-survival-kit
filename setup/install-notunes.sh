#!/bin/bash
# Descripcion: Instala y configura noTunes para bloquear la apertura automática de iTunes/Apple Music
# Requisitos: Homebrew instalado (se instalará si falta)

set -euo pipefail

# Detección de TTY para colores condicionales
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN=''
    YELLOW=''
    CYAN=''
    BOLD=''
    RESET=''
fi

check_homebrew() {
    if ! command -v brew > /dev/null 2>&1; then
        echo -e "${YELLOW}Instalando Homebrew...${RESET}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}Homebrew ya está instalado${RESET}"
    fi
}

install_notunes() {
    echo -e "${CYAN}Instalando noTunes via Homebrew Cask...${RESET}"
    brew install --cask notunes
}

configure_notunes() {
    echo -e "${CYAN}Configurando Spotify como reemplazo...${RESET}"
    defaults write digital.twisted.noTunes replacement /Applications/Spotify.app

    echo -e "${CYAN}Configurando inicio automático...${RESET}"
    osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/noTunes.app", hidden:false}'
}

main() {
    echo -e "\n${BOLD}${CYAN}CONFIGURACIÓN DE NOTUNES + SPOTIFY${RESET}"
    echo -e "${CYAN}===================================================${RESET}"

    check_homebrew
    install_notunes
    configure_notunes

    echo -e "${CYAN}===================================================${RESET}"
    echo -e "${GREEN}${BOLD}Instalación completada${RESET}"
    echo -e "Abrir noTunes desde Aplicaciones para activar el bloqueo"
    echo ""
}

main "$@"