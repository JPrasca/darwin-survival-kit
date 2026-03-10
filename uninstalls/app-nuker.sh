#!/usr/bin/env bash
# ============================================================
# Script: app-nuker.sh
# Descripción: Desinstalador universal inteligente para macOS.
#               Detecta Bundle IDs y busca residuos en rutas estándar.
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

usage() {
    echo "Uso: $0 <nombre_de_la_app>"
    echo "Ejemplo: $0 Maccy"
    exit 1
}

get_bundle_id() {
    local app_path="$1"
    if [ -d "$app_path" ]; then
        mdls -name kMDItemCFBundleIdentifier -raw "$app_path" 2>/dev/null || echo ""
    fi
}

find_app_path() {
    local name="$1"
    find /Applications /Users/*/Applications -maxdepth 2 -iname "*$name*.app" -print -quit 2>/dev/null
}

scan_for_residue() {
    local keyword="$1"
    local bundle="$2"
    local search_dirs=(
        "$HOME/Library"
        "/Library"
    )
    # Subcarpetas críticas donde las apps suelen dejar rastro
    local sub_folders=(
        "Application Support" "Caches" "Containers" "Group Containers" 
        "Preferences" "Logs" "Saved Application State" "LaunchAgents" 
        "LaunchDaemons" "HTTPStorages" "Cookies"
    )

    for base in "${search_dirs[@]}"; do
        for sub in "${sub_folders[@]}"; do
            local target_dir="$base/$sub"
            if [ -d "$target_dir" ]; then
                # Buscar coincidencias con el nombre o el bundle ID
                find "$target_dir" -maxdepth 2 \( -iname "*$keyword*" -o -iname "*$bundle*" \) 2>/dev/null
            fi
        done
    done
}

main() {
    if [ $# -lt 1 ]; then usage; fi

    local search_name="$1"
    echo -e "\n${BOLD}${CYAN}Buscando aplicación: $search_name...${RESET}"

    local app_path
    app_path=$(find_app_path "$search_name")

    if [ -z "$app_path" ]; then
        echo -e "${CYAN}Información: No se encontró la aplicación '$search_name'. Es posible que ya haya sido eliminada.${RESET}"
        exit 0
    fi

    echo -e "${GREEN}Encontrado: $app_path${RESET}"
    local bundle_id
    bundle_id=$(get_bundle_id "$app_path")
    echo -e "${GREEN}Bundle ID: ${bundle_id:-No detectado}${RESET}"

    # Reglas especiales para apps complejas (excepciones manuales)
    local extra_paths=()
    if [[ "$search_name" =~ [Oo]ne[Dd]rive ]]; then
        extra_paths+=("$HOME/Library/CloudStorage/OneDrive-Personal")
    fi

    echo -e "\n${BOLD}Escaneando el sistema dinámicamente en busca de residuos...${RESET}"
    
    # Combinar búsqueda dinámica + excepciones y eliminar duplicados/vacíos
    mapfile -t found_paths < <(
        {
            echo "$app_path"
            for p in "${extra_paths[@]}"; do echo "$p"; done
            scan_for_residue "$search_name" "$bundle_id"
        } | sort -u | xargs -I {} sh -c 'if [ -e "{}" ]; then echo "{}"; fi'
    )

    if [ ${#found_paths[@]} -eq 0 ]; then
        echo -e "${YELLOW}No se encontraron archivos adicionales.${RESET}"
        exit 0
    fi

    # Mostrar resultados
    for p in "${found_paths[@]}"; do
        echo -e "  [DETECTADO] $p"
    done

    echo -e "\n${YELLOW}${BOLD}ADVERTENCIA: Se eliminarán los archivos listados arriba.${RESET}"
    read -p "¿Deseas proceder con la eliminación? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi

    # Cierre de procesos
    local process_name
    process_name=$(basename "$app_path" .app)
    if pgrep -f "$process_name" > /dev/null; then
        echo -e "${CYAN}Cerrando procesos de $process_name...${RESET}"
        pkill -f "$process_name" || true
        sleep 2
    fi

    # Eliminación
    echo -e "${RED}Eliminando...${RESET}"
    for p in "${found_paths[@]}"; do
        if [ "$p" == "/" ] || [ "$p" == "$HOME" ]; then continue; fi # Protección básica
        sudo rm -rf "$p" && echo -e "  Eliminado: $p" || echo -e "  Error al eliminar: $p"
    done

    echo -e "\n${GREEN}${BOLD}La aplicación y sus residuos han sido eliminados correctamente.${RESET}\n"
}

main "$@"
