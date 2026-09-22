#!/bin/bash
# Descripcion: Desinstala AdGuard y sus componentes en macOS.
# Requisitos: Privilegios de administrador (sudo).

set -euo pipefail

# Manejo de colores (TTY Detection)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    RESET=''
fi

# Detectar usuario original
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

# Funciones
confirm_action() {
    echo -e "${YELLOW}=== DESINSTALACIÓN DE ADGUARD ===${RESET}"
    echo "¿Confirmar eliminación de AdGuard y todos sus componentes? [s/N]"
    read -r response
    if [[ ! "$response" =~ ^[sS]$ ]]; then
        echo -e "${RED}PROCESO CANCELADO.${RESET}"
        exit 1
    fi
}

check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}ESTE SCRIPT REQUIERE PRIVILEGIOS DE ADMINISTRADOR.${RESET}"
        echo -e "${YELLOW}EJECUTANDO CON SUDO...${RESET}"
        exec sudo "$0" "$@"
    fi
}

cleanup() {
    echo -e "${YELLOW}CERRANDO PROCESOS DE ADGUARD...${RESET}"
    pkill -9 "AdGuard" || true
    pkill -9 "AdGuard Safari Assistant" || true

    echo -e "${YELLOW}ELIMINANDO ARCHIVOS...${RESET}"
    
    local paths=(
        "/Applications/AdGuard Mini.app"
        "/Applications/AdGuard for Safari.app"
        "/Applications/AdGuard.app"
        "/Library/Application Support/AdGuard Software"
        "/Library/Application Support/AdGuard"
        "$USER_HOME/Library/Application Support/AdGuard Software"
        "$USER_HOME/Library/Application Support/com.adguard.mac.adguard"
        "$USER_HOME/Library/Application Support/AdGuard"
        "$USER_HOME/Library/Preferences/com.adguard.mac.adguard.plist"
        "$USER_HOME/Library/Preferences/com.adguard.mac.adguard.safari-assistant.plist"
        "$USER_HOME/Library/Caches/com.adguard.mac.adguard"
        "$USER_HOME/Library/Caches/com.adguard.mac.adguard.safari-assistant"
        "$USER_HOME/Library/Saved Application State/com.adguard.mac.adguard.savedState"
        "$USER_HOME/Library/Containers/com.adguard.mac.adguard.safari-assistant"
        "$USER_HOME/Library/Group Containers/TC3Q7MAJXF.com.adguard.mac"
    )

    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            echo "Eliminando: $path"
            if ! rm -rf "$path" 2>/dev/null; then
                # Fallback usando AppleScript para carpetas protegidas por macOS (SIP/TCC)
                echo -e "${YELLOW}Usando Finder para eliminar archivo protegido...${RESET}"
                osascript -e "tell application \"Finder\" to delete POSIX file \"$path\"" > /dev/null 2>&1 || true
            fi
        fi
    done

    echo -e "${GREEN}LIMPIEZA FINALIZADA.${RESET}"
    echo -e "${GREEN}PROCESO COMPLETADO.${RESET}"
}

main() {
    check_privileges
    confirm_action
    cleanup
}

main
