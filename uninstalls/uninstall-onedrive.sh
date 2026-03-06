#!/usr/bin/env bash
# ============================================================
# Script: uninstall-onedrive.sh
# Descripción: Desinstala Microsoft OneDrive completamente de macOS, 
#               incluyendo contenedores, cachés, configuraciones y 
#               la carpeta de CloudStorage.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará OneDrive y sus archivos locales.${RESET}"
    echo -e "${YELLOW}Asegúrate de haber respaldado tus archivos antes de continuar.${RESET}"
    read -p "¿Estás seguro de que deseas continuar? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_onedrive_running() {
    if pgrep -f "OneDrive" > /dev/null; then
        echo -e "${YELLOW}Cerrando todos los procesos de OneDrive...${RESET}"
        pkill -f "OneDrive" || true
        sleep 3
        # Asegurar cierre si siguen vivos
        if pgrep -f "OneDrive" > /dev/null; then
            pkill -9 -f "OneDrive" || true
        fi
    fi
}

remove_files() {
    local paths=(
        "/Applications/OneDrive.app"
        "$HOME/Library/CloudStorage/OneDrive-Personal"
        "$HOME/Library/Application Support/OneDrive"
        "$HOME/Library/Application Support/com.microsoft.OneDrive"
        "$HOME/Library/Application Support/com.microsoft.OneDriveUpdater"
        "$HOME/Library/Caches/com.microsoft.OneDrive"
        "$HOME/Library/Caches/com.microsoft.OneDriveUpdater"
        "$HOME/Library/Caches/OneDrive"
        "$HOME/Library/Containers/com.microsoft.OneDrive-mac"
        "$HOME/Library/Containers/com.microsoft.OneDriveLauncher"
        "$HOME/Library/Containers/com.microsoft.OneDrive.FinderSync"
        "$HOME/Library/Group Containers/UBF8T346G9.OneDriveStandaloneSuite"
        "$HOME/Library/Group Containers/UBF8T346G9.OfficeOneDriveSyncIntegration"
        "$HOME/Library/Group Containers/UBF8T346G9.Office"
        "$HOME/Library/Preferences/com.microsoft.OneDrive.plist"
        "$HOME/Library/Preferences/com.microsoft.OneDriveUpdater.plist"
        "$HOME/Library/Preferences/com.microsoft.OneDriveStandaloneSuite.plist"
        "$HOME/Library/Cookies/com.microsoft.OneDrive.binarycookies"
        "$HOME/Library/Logs/OneDrive"
        "$HOME/Library/LaunchAgents/com.microsoft.OneDriveStandaloneUpdaterDaemon.plist"
    )

    echo -e "${CYAN}Eliminando archivos...${RESET}"
    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            # Intentar eliminar, pero no fallar si SIP bloquea archivos de metadata en Containers
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $path (posiblemente protegido por el sistema).${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}Desinstalador de Microsoft OneDrive para macOS${RESET}"
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    confirm_action
    check_onedrive_running
    remove_files
    
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    echo -e "${GREEN}${BOLD}OneDrive ha sido desinstalado correctamente.${RESET}\n"
}

# Ejecutar script
main "$@"
