#!/usr/bin/env bash
# Script: uninstall-virtualbox.sh
# Descripción: Desinstala VirtualBox completamente, incluyendo VMs, kexts y configuraciones.
# Requisitos: Permisos de sudo.

set -euo pipefail

# Solo usar colores si la salida es una terminal (TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    CYAN=''
    BOLD=''
    RESET=''
fi

confirm_action() {
    echo -e "${RED}${BOLD}ADVERTENCIA: Se eliminará VirtualBox y TODAS sus máquinas virtuales.${RESET}"
    read -p "¿Deseas continuar? (s/n): " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Ss]$ ]] || { echo -e "${CYAN}Cancelado.${RESET}"; exit 0; }
}

kill_vbox() {
    echo -e "${CYAN}Deteniendo procesos de VirtualBox...${RESET}"
    killall -9 VBoxHeadless VBoxSVC VBoxNetDHCP 2>/dev/null || true
}

remove_files() {
    # Identificar el usuario real
    local REAL_USER
    REAL_USER=$(logname 2>/dev/null || echo "$USER")
    local USER_HOME
    USER_HOME=$(eval echo ~"$REAL_USER")

    echo -e "${CYAN}Eliminando archivos y configuraciones...${RESET}"
    
    local paths=(
        "/Applications/VirtualBox.app"
        "/Library/Application Support/VirtualBox"
        "/Library/Extensions/VBoxDrv.kext"
        "/Library/Extensions/VBoxNetFlt.kext"
        "/Library/Extensions/VBoxNetAdp.kext"
        "/Library/Extensions/VBoxUSB.kext"
        "$USER_HOME/.config/VirtualBox"
        "$USER_HOME/.VirtualBox"
        "$USER_HOME/VirtualBox VMs"
    )

    for p in "${paths[@]}"; do
        if [ -e "$p" ]; then
            sudo rm -rf "$p" && echo "  Eliminado: $p"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}🧹 Desinstalador Total de VirtualBox${RESET}"
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"

    confirm_action
    kill_vbox
    remove_files

    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    echo -e "${GREEN}${BOLD}VirtualBox ha sido eliminado del sistema.${RESET}\n"
}

main "$@"