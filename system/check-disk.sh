#!/usr/bin/env bash
# Script: check-disk.sh
# Descripción: Muestra el espacio disponible en disco de forma legible.
# Requisitos: macOS / Coreutils (df)

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
check_deps() {
    if ! command -v df &>/dev/null; then
        echo -e "${RED}Error: 'df' no encontrado.${RESET}"
        exit 1
    fi
}

show_header() {
    echo -e "\n${BOLD}${CYAN}📊 Estado del almacenamiento en macOS${RESET}"
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"
}

get_disk_usage() {
    echo -e "${BOLD}Disco Principal (macOS):${RESET}"
    df -h / | grep -v "Filesystem" | awk '{print "  Total:  " $2 "\n  Usado:  " $3 "\n  Libre:  " $4 " (" $5 ")"}'
    
    echo -e "\n${BOLD}Otros volúmenes relevantes:${RESET}"
    df -h | grep "/Volumes/" | awk '{print "  " $6 ": " $4 " libres de " $2}' || echo "  No hay volúmenes externos montados."
}

main() {
    check_deps
    show_header
    get_disk_usage
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}\n"
}

main "$@"
