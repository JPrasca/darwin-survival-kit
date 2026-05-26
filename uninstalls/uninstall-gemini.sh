#!/usr/bin/env bash
# ============================================================
# Script: uninstall-gemini.sh
# Descripción: Desinstala Gemini Desktop completamente de macOS,
#               incluyendo la aplicación, contenedores, cachés,
#               preferencias, datos de soporte y agentes de lanzamiento.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará Gemini Desktop y todos sus datos del sistema.${RESET}"
    echo -e "${YELLOW}Los datos de cuenta de Google no se verán afectados.${RESET}"
    read -p "¿Confirmar desinstalación de Gemini Desktop? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_gemini_running() {
    echo -e "${CYAN}Cerrando procesos de Gemini...${RESET}"
    pkill -f "Gemini" || true
    pkill -f "com.google.GeminiMacOS" || true
    sleep 2
}

remove_launch_agents() {
    echo -e "${CYAN}Eliminando agentes de lanzamiento...${RESET}"
    local agents=(
        "$HOME/Library/LaunchAgents/com.google.GeminiMacOS.launcher.plist"
    )
    for agent in "${agents[@]}"; do
        if [ -e "$agent" ]; then
            launchctl unload "$agent" 2>/dev/null || true
            echo -e "  Eliminando: ${YELLOW}$agent${RESET}"
            rm -f "$agent" || echo -e "  ${RED}Nota: No se pudo eliminar $agent.${RESET}"
        fi
    done
}

remove_files() {
    local paths=(
        "/Applications/Gemini.app"
        "$HOME/Library/Application Support/Gemini"
        "$HOME/Library/Application Support/com.google.GeminiMacOS"
        "$HOME/Library/Application Support/com.google.GeminiMacOS.launcher"
        "$HOME/Library/Caches/com.google.GeminiMacOS"
        "$HOME/Library/Caches/com.google.GeminiMacOS.launcher"
        "$HOME/Library/Preferences/com.google.GeminiMacOS.plist"
        "$HOME/Library/Preferences/com.google.GeminiMacOS.launcher.plist"
        "$HOME/Library/Preferences/com.google.GeminiMacOS.shareddata.plist"
        "$HOME/Library/Containers/com.google.GeminiMacOS"
        "$HOME/Library/Containers/com.google.GeminiMacOS.launcher"
        "$HOME/Library/Application Scripts/com.google.GeminiMacOS"
        "$HOME/Library/Application Scripts/com.google.GeminiMacOS.launcher"
        "$HOME/Library/Saved Application State/com.google.GeminiMacOS.savedState"
        "$HOME/Library/WebKit/com.google.GeminiMacOS"
        "$HOME/Library/HTTPStorages/com.google.GeminiMacOS"
        "$HOME/Library/HTTPStorages/com.google.GeminiMacOS.binarycookies"
        "$HOME/Library/Logs/Gemini"
    )

    echo -e "${CYAN}Eliminando archivos...${RESET}"
    for path in "${paths[@]}"; do
        if [ -e "$path" ] || [ -L "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $path.${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}DESINSTALADOR DE GEMINI DESKTOP PARA MACOS${RESET}"
    echo -e "${RED}====================================================${RESET}"

    confirm_action
    check_gemini_running
    remove_launch_agents
    remove_files

    echo -e "${RED}====================================================${RESET}"
    echo -e "${GREEN}${BOLD}Proceso completado. Gemini Desktop ha sido desinstalado.${RESET}\n"
}

# Ejecutar script
main "$@"
