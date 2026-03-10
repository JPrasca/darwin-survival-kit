#!/usr/bin/env bash
# Script: clean-phantoms.sh
# Descripción: Purga archivos de persistencia huérfanos de aplicaciones desinstaladas (Office, CCleaner, OneDrive, etc.).
# Requisitos: macOS / sudo (para archivos en /Library)

set -euo pipefail

# ── Variables de Color (TTY Detection) ──────────────────────────
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

# ── Funciones de Utilidad ─────────────────────────────────────

header() {
    echo -e "\n${BOLD}${CYAN}🧹 $1${RESET}"
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"
}

confirm() {
    local message="$1"
    echo -ne "${YELLOW}${BOLD}¿$message? (s/n): ${RESET}"
    read -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Ss]$ ]]
}

# ── Búsqueda y Limpieza ───────────────────────────────────────

purge_pattern() {
    local pattern="$1"
    local name="$2"
    
    header "ANALISIS DE PATRON: $name"
    
    local search_areas=(
        "/Library/LaunchAgents"
        "/Library/LaunchDaemons"
        "$HOME/Library/LaunchAgents"
        "/Library/Application Support"
        "/Library/Caches"
        "$HOME/Library/Application Support"
        "$HOME/Library/Caches"
        "$HOME/Library/Preferences"
    )

    local found=()
    for area in "${search_areas[@]}"; do
        if [[ -d "$area" ]]; then
            # Buscar archivos o carpetas que coincidan con el patrón
            while IFS= read -r item; do
                if [[ -n "$item" ]]; then
                    found+=("$item")
                fi
            done < <(find "$area" -maxdepth 2 -iname "*$pattern*" 2>/dev/null)
        fi
    done

    # Eliminar duplicados si los hay
    mapfile -t sorted_found < <(sort -u <<<"${found[*]}")
    unset IFS

    if [[ ${#sorted_found[@]} -eq 0 ]]; then
        echo -e "  Sin elementos detectados para $name."
        return
    fi

    echo -e "${YELLOW}Elementos detectados ($name):${RESET}"
    for f in "${sorted_found[@]}"; do
        echo "  - $f"
    done

    if confirm "Confirmar eliminación de elementos ($name)"; then
        for f in "${sorted_found[@]}"; do
            if [[ ! -e "$f" ]]; then continue; fi # Evitar errores si ya se borró el padre
            
            if [[ "$f" == "/Library/"* ]]; then
                echo -e "${CYAN}Solicitando sudo para: $f${RESET}"
                sudo rm -rf "$f"
            else
                rm -rf "$f"
            fi
            echo "  Eliminado: $f"
        done
        echo -e "${GREEN}Purga de $name finalizada.${RESET}"
    else
        echo -e "${RED}Operación omitida para $name.${RESET}"
    fi
}

# ── MAIN ──────────────────────────────────────────────────────

main() {
    echo -e "${BOLD}${CYAN}--- DARWIN SURVIVAL KIT: LIMPIEZA DE PERSISTENCIA ---${RESET}"
    echo -e "Analizando archivos huérfanos de aplicaciones desinstaladas..."
    
    # Lista de patrones detectados en tu auditoría
    purge_pattern "piriform\|ccleaner" "CCleaner"
    purge_pattern "onedrive" "OneDrive"
    purge_pattern "office\|microsoft\.update\|microsoft\.autoupdate" "Microsoft Office / AutoUpdate"
    purge_pattern "bluestacks" "BlueStacks"
    purge_pattern "logitune\|logi" "Logitech Tools"
    purge_pattern "vbox\|virtualbox" "VirtualBox"

    header "Limpieza Finalizada"
    echo -e "${GREEN}El sistema ahora tiene menos procesos 'fantasma' intentando iniciar.${RESET}"
}

main "$@"
