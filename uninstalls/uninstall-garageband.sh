#!/usr/bin/env bash
# ============================================================
# Script: uninstall-garageband.sh
# Descripción: Desinstala GarageBand completamente de macOS,
#               incluyendo contenedores, cachés, preferencias, bibliotecas
#               de sonidos (Apple Loops) y datos de soporte.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará GarageBand y todas sus bibliotecas de sonidos del sistema.${RESET}"
    echo -e "${YELLOW}Nota: Algunas carpetas de Apple Loops podrían ser compartidas con Logic Pro o MainStage.${RESET}"
    echo -e "${YELLOW}Los proyectos guardados en ~/Music/ no serán eliminados automáticamente.${RESET}"
    read -p "¿Confirmar desinstalación de GarageBand? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_garageband_running() {
    echo -e "${CYAN}Cerrando procesos de GarageBand...${RESET}"
    pkill -f "GarageBand" || true
    sleep 2
}

remove_files() {
    # Lista de archivos a eliminar
    local paths=(
        "/Applications/GarageBand.app"
        "/Library/Application Support/GarageBand"
        "/Library/Application Support/iLifeMediaBrowser/Plug-Ins/iLMBGarageBandPlugin.ilmbplugin"
        "/Library/Audio/Apple Loops/Apple/Apple Loops for GarageBand"
        "$HOME/Library/Application Support/GarageBand"
        "$HOME/Library/Preferences/com.apple.garageband10.plist"
        "$HOME/Library/Caches/com.apple.garageband"
        "$HOME/Library/Containers/com.apple.garageband10"
        "$HOME/Library/Containers/com.apple.STMExtension.GarageBand"
        "$HOME/Library/Application Scripts/com.apple.garageband10"
        "$HOME/Library/Application Scripts/com.apple.STMExtension.GarageBand"
    )

    echo -e "${CYAN}Eliminando archivos...${RESET}"
    
    # Eliminar rutas fijas
    for path in "${paths[@]}"; do
        if [ -e "$path" ] || [ -L "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $path.${RESET}"
        fi
    done

    # Eliminar archivos con patrones dinámicos (sfl)
    local sfl_pattern="$HOME/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.apple.garageband.sfl"
    # Buscar y eliminar archivos que coincidan
    for f in "${sfl_pattern}"*; do
        if [ -e "$f" ] || [ -L "$f" ]; then
            echo -e "  Eliminando: ${YELLOW}$f${RESET}"
            sudo rm -rf "$f" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $f.${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}DESINSTALADOR DE GARAGEBAND PARA MACOS${RESET}"
    echo -e "${RED}====================================================${RESET}"
    
    confirm_action
    check_garageband_running
    remove_files
    
    echo -e "${RED}====================================================${RESET}"
    echo -e "${GREEN}${BOLD}Proceso completado. GarageBand ha sido desinstalado.${RESET}\n"
}

# Ejecutar script
main "$@"
