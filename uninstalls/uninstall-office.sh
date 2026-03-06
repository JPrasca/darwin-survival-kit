#!/usr/bin/env bash
# ============================================================
# Script: uninstall-office.sh
# Descripción: Desinstala la suite principal de Microsoft Office 
#               (Word, Excel, PowerPoint) de macOS, incluyendo 
#               contenedores, cachés y configuraciones.
#               NOTA: Mantiene Edge y Teams por petición del usuario.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción eliminará Word, Excel y PowerPoint.${RESET}"
    echo -e "${YELLOW}Teams y Edge NO serán eliminados.${RESET}"
    read -p "¿Estás seguro de que deseas continuar? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

check_office_running() {
    local apps=("Word" "Excel" "PowerPoint")
    for app in "${apps[@]}"; do
        if pgrep -f "$app" > /dev/null; then
            echo -e "${YELLOW}Cerrando $app...${RESET}"
            pkill -f "$app" || true
            sleep 1
        fi
    done
}

remove_files() {
    local paths=(
        # Aplicaciones
        "/Applications/Microsoft Word.app"
        "/Applications/Microsoft Excel.app"
        "/Applications/Microsoft PowerPoint.app"
        
        # Contenedores específicos
        "$HOME/Library/Containers/com.microsoft.Word"
        "$HOME/Library/Containers/com.microsoft.Excel"
        "$HOME/Library/Containers/com.microsoft.Powerpoint"
        "$HOME/Library/Containers/com.microsoft.errorreporting"
        "$HOME/Library/Containers/com.microsoft.Office365ServiceV2"
        
        # Group Containers (Compartidos por Office)
        # Nota: Algunos pueden ser usados por Outlook si lo tuvieras, 
        # pero aquí borramos los core de Office.
        "$HOME/Library/Group Containers/UBF8T346G9.ms"
        "$HOME/Library/Group Containers/UBF8T346G9.Office"
        "$HOME/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"
        
        # Caches y Preferencias
        "$HOME/Library/Application Support/Microsoft/Office"
        "$HOME/Library/Preferences/com.microsoft.Word.plist"
        "$HOME/Library/Preferences/com.microsoft.Excel.plist"
        "$HOME/Library/Preferences/com.microsoft.Powerpoint.plist"
    )

    echo -e "${CYAN}Eliminando archivos...${RESET}"
    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar completamente $path (posiblemente protegido).${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}Desinstalador de Microsoft Office (Word, Excel, PPT)${RESET}"
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    confirm_action
    check_office_running
    remove_files
    
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    echo -e "${GREEN}${BOLD}Office (Word, Excel, PowerPoint) ha sido desinstalado.${RESET}"
    echo -e "${CYAN}Microsoft Edge y Teams permanecen intactos.${RESET}\n"
}

# Ejecutar script
main "$@"
