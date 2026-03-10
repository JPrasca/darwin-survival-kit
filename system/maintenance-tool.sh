#!/usr/bin/env bash
# Script: maintenance-tool.sh
# Descripción: Herramienta centralizada para limpiezas, desinstalaciones y auditorías en macOS.
# Requisitos: Varios (depende de la acción; ej: docker, gcloud).

set -euo pipefail

# Solo usar colores si la salida es una terminal (TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    YELLOW=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Parámetros globales
YES=0
if [[ "${1:-""}" == "--yes" ]]; then
    YES=1
    shift
fi

# ── Funciones de Utilidad ─────────────────────────────────────

confirm() {
    local message="$1"
    if [[ $YES -eq 1 ]]; then return 0; fi
    
    read -p "$(echo -e "${YELLOW}${BOLD}¿$message? (s/n): ${RESET}")" -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Ss]$ ]]
}

header() {
    echo -e "\n${BOLD}${CYAN}--- ACCION: $1 ---${RESET}"
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"
}

# ── Acciones ──────────────────────────────────────────────────

uninstall_generic() {
    local app="$1"
    if ! confirm "Desinstalar $app y limpiar rastros"; then exit 0; fi
    
    echo -e "${CYAN}Eliminando $app...${RESET}"
    pkill -f "$app" 2>/dev/null || true
    
    local paths=(
        "/Applications/$app.app"
        "$HOME/Library/Application Support/$app"
        "$HOME/Library/Caches/com.$app"
        "$HOME/Library/Preferences/com.$app.plist"
        "$HOME/Library/LaunchAgents/com.$app.plist"
    )

    for p in "${paths[@]}"; do
        if [[ -e "$p" ]]; then
            rm -rf "$p" && echo "  Eliminado: $p"
        fi
    done
}

clean_docker() {
    header "Limpieza de Docker"
    if command -v ./system/docker-cleaner.sh &>/dev/null; then
        ./system/docker-cleaner.sh
    else
        echo -e "${RED}Error: no se encontró ./system/docker-cleaner.sh${RESET}"
        exit 1
    fi
}

scan_sql_action() {
    local dir="${1:-.}"
    header "Análisis SQL Peligroso"
    if [[ -f "./dev-tools/scan-sql.sh" ]]; then
        ./dev-tools/scan-sql.sh "$dir"
    else
        echo -e "${RED}Error: no se encontró ./dev-tools/scan-sql.sh${RESET}"
        exit 1
    fi
}

malware_hunter_action() {
    header "Auditoría de Malware y Seguridad"
    if [[ -f "./system/malware-hunter.sh" ]]; then
        ./system/malware-hunter.sh
    else
        echo -e "${RED}Error: no se encontró ./system/malware-hunter.sh${RESET}"
        exit 1
    fi
}

show_usage() {
    echo -e "\n${BOLD}Uso:${RESET} $0 [--yes] <acción> [argumentos]"
    echo ""
    echo -e "${BOLD}Acciones:${RESET}"
    echo "  list                            Lista todas las acciones disponibles"
    echo "  generic-uninstall <AppName>     Desinstala una App por nombre"
    echo "  docker-clean                    Ejecuta el limpiador de Docker"
    echo "  scan-sql <dir>                  Busca SQL peligroso en el directorio"
    echo "  malware-hunter                  Ejecuta auditoría de seguridad"
    echo ""
}

# ── MAIN ──────────────────────────────────────────────────────

main() {
    local action="${1:-""}"
    shift || true

    case "$action" in
        list)
            header "ACCIONES DE MANTENIMIENTO"
            echo "  - generic-uninstall          - docker-clean"
            echo "  - scan-sql                   - check-disk"
            echo "  - malware-hunter"
            echo ""
            ;;
        generic-uninstall)
            [[ -z "${1:-""}" ]] && show_usage && exit 1
            uninstall_generic "$1"
            ;;
        docker-clean)
            clean_docker
            ;;
        scan-sql)
            scan_sql_action "${1:-.}"
            ;;
        check-disk)
            ./system/check-disk.sh
            ;;
        malware-hunter)
            malware_hunter_action
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
