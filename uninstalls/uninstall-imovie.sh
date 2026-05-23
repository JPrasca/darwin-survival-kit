#!/usr/bin/env bash
# ============================================================
# Script: uninstall-imovie.sh
# Descripción: Desinstala iMovie completamente de macOS,
#               incluyendo contenedores, cachés, preferencias y datos de soporte.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará iMovie y sus archivos de soporte del sistema.${RESET}"
    echo -e "${YELLOW}Los proyectos guardados en ~/Movies/ no serán eliminados automáticamente.${RESET}"
    read -p "¿Confirmar desinstalación de iMovie? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_imovie_running() {
    echo -e "${CYAN}Cerrando procesos de iMovie...${RESET}"
    pkill -f "iMovie" || true
    sleep 2
}

remove_files() {
    # Lista de archivos a eliminar
    local paths=(
        "/Applications/iMovie.app"
        "$HOME/Library/Application Scripts/com.apple.iMovieApp"
        "$HOME/Library/Containers/com.apple.iMovieApp"
        "$HOME/Library/Caches/com.apple.iMovieApp"
        "$HOME/Library/Preferences/com.apple.iMovieApp.plist"
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
    local sfl_pattern="$HOME/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.apple.imovieapp.sfl"
    # Buscar y eliminar archivos que coincidan
    for f in "${sfl_pattern}"*; do
        if [ -e "$f" ] || [ -L "$f" ]; then
            echo -e "  Eliminando: ${YELLOW}$f${RESET}"
            sudo rm -rf "$f" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $f.${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}DESINSTALADOR DE IMOVIE PARA MACOS${RESET}"
    echo -e "${RED}====================================================${RESET}"
    
    confirm_action
    check_imovie_running
    remove_files
    
    echo -e "${RED}====================================================${RESET}"
    echo -e "${GREEN}${BOLD}Proceso completado. iMovie ha sido desinstalado.${RESET}\n"
}

# Ejecutar script
main "$@"
