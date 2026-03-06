#!/usr/bin/env bash
# ============================================================
# Script: uninstall-lghub.sh
# Descripción: Desinstala Logitech G HUB completamente de macOS, 
#               incluyendo agentes, daemons, extensiones y cachés.
# Requisitos: Permisos de sudo
# ============================================================

set -euo pipefail

# Solo usar colores si la salida es una terminal (TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ── Funciones ────────────────────────────────────────────────
confirm_action() {
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará Logitech G HUB y todas sus configuraciones de periféricos.${RESET}"
    read -p "¿Estás seguro de que deseas continuar? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_lghub_running() {
    echo -e "${CYAN}Cerrando procesos de Logitech G HUB...${RESET}"
    # G HUB tiene varios procesos (lghub, lghub_agent, lghub_updater)
    pkill -f "lghub" || true
    sleep 2
}

remove_files() {
    local paths=(
        "/Applications/LGHUB.app"
        "/Library/Application Support/Logitech/ghub"
        "$HOME/Library/Application Support/LGHUB"
        "$HOME/Library/Caches/com.logi.ghub"
        "$HOME/Library/Preferences/com.logi.ghub.plist"
        "$HOME/Library/Logs/LGHUB"
        "/Library/LaunchAgents/com.logi.ghub.plist"
        "/Library/LaunchDaemons/com.logi.ghub.updater.plist"
        "$HOME/Library/LaunchAgents/com.logi.ghub.plist"
        "/Users/Shared/LGHUB"
    )

    echo -e "${CYAN}Eliminando archivos...${RESET}"
    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $path.${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}Desinstalador de Logitech G HUB para macOS${RESET}"
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    confirm_action
    check_lghub_running
    remove_files
    
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    echo -e "${GREEN}${BOLD}Logitech G HUB ha sido desinstalado correctamente.${RESET}\n"
}

# Ejecutar script
main "$@"
