#!/usr/bin/env bash
# ============================================================
# Script: uninstall-logitech-options-tune.sh
# Descripción: Desinstala Logi Options (legacy), Logi Options+ y LogiTune
#              completamente de macOS, incluyendo agentes, daemons,
#              preferencias y cachés.
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
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta accion eliminara Logi Options, Logi Options+ y LogiTune junto con todas sus configuraciones.${RESET}"
    read -p "Confirmar eliminacion? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operacion cancelada.${RESET}"
        exit 0
    fi
}

stop_processes() {
    echo -e "${CYAN}Deteniendo procesos activos...${RESET}"

    local agents=(
        "com.logi.optionsplus"
        "com.logitech.logitune.launcher"
        "com.logitech.LogiRightSight.Agent"
    )

    for agent in "${agents[@]}"; do
        if launchctl list 2>/dev/null | grep -q "$agent"; then
            echo -e "  Descargando agente: ${YELLOW}$agent${RESET}"
            launchctl unload "/Library/LaunchAgents/${agent}.plist" 2>/dev/null || true
            launchctl unload "$HOME/Library/LaunchAgents/${agent}.plist" 2>/dev/null || true
        fi
    done

    pkill -f "LogiOptionsPlus" 2>/dev/null || true
    pkill -f "logioptionsplus" 2>/dev/null || true
    pkill -f "LogiTune" 2>/dev/null || true
    pkill -f "LogiOptions" 2>/dev/null || true
    pkill -f "LogiRightSight" 2>/dev/null || true
    pkill -f "LogiPluginService" 2>/dev/null || true

    # Descargar daemons con sudo
    local daemons=(
        "com.logitech.logitune.agent"
        "com.logitech.LogiRightSight"
        "com.logitech.logitune.crashpad"
        "com.logitech.logitune.updater"
    )
    for daemon in "${daemons[@]}"; do
        sudo launchctl unload "/Library/LaunchDaemons/${daemon}.plist" 2>/dev/null || true
        sudo launchctl unload "/Library/LaunchAgents/${daemon}.plist" 2>/dev/null || true
    done

    sleep 1
}

remove_files() {
    local paths=(
        # --- Logi Options+ (nombre real del bundle) ---
        "/Applications/logioptionsplus.app"
        "/Applications/Logi Options+.app"
        "/Applications/Utilities/Logi Options+ Driver Installer.bundle"
        "/Applications/Utilities/LogiPluginService.app"
        "/Library/Application Support/Logitech.localized/LogiOptionsPlus"
        "/Library/LaunchAgents/com.logi.optionsplus.plist"
        "/Library/LaunchDaemons/com.logi.optionsplus.updater.plist"
        "/Library/LaunchAgents/com.logitech.LogiRightSight.Agent.plist"
        "/Library/Logs/Logi"
        "$HOME/Library/Application Support/LogiOptionsPlus"
        "$HOME/Library/Application Support/com.logitech.logiaipromptbuilder"
        "$HOME/Library/Preferences/com.logi.optionsplus.plist"
        "$HOME/Library/Preferences/com.logitech.logiaipromptbuilder.plist"
        "$HOME/Library/Caches/com.logi.optionsplus"
        "$HOME/Library/Caches/com.logi.optionsplus.installer"
        "$HOME/Library/Logs/LogiZoomBridge"

        # --- Logi Options (version legacy) ---
        "/Applications/Logi Options.app"
        "/Library/Application Support/Logitech.localized/Logi Options"
        "/Library/LaunchAgents/com.logitech.manager.launcher.plist"
        "/Library/LaunchDaemons/com.logitech.manager.daemon.plist"
        "$HOME/Library/Application Support/Logitech Options"
        "$HOME/Library/Preferences/com.logitech.manager.plist"

        # --- Logi Tune (nombre real: 'Logi Tune.app' con espacio) ---
        "/Applications/Logi Tune.app"
        "/Applications/LogiTune.app"
        "/Library/Application Support/logitune"
        "/Library/Application Support/Logitech.localized/LogiTune"
        "/Library/LaunchAgents/com.logitech.logitune.launcher.plist"
        "/Library/LaunchAgents/com.logitech.logitune.agent.plist"
        "/Library/LaunchDaemons/com.logitech.LogiRightSight.plist"
        "/Library/LaunchDaemons/com.logitech.logitune.crashpad.plist"
        "/Library/LaunchDaemons/com.logitech.logitune.updater.plist"
        "$HOME/Library/Application Support/LogiTune"
        "$HOME/Library/Logs/logitune"
        "$HOME/Library/Preferences/com.logitech.logitune.plist"
        "$HOME/Library/Caches/com.logitech.logitune"

        # --- Residuos compartidos de Logitech ---
        "/Library/Application Support/Logi"
        "/Library/Application Support/Logitech.localized"
        "$HOME/Library/Application Support/Logitech"
    )

    echo -e "${CYAN}Eliminando archivos y directorios...${RESET}"
    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            echo -e "  Eliminando: ${YELLOW}$path${RESET}"
            sudo rm -rf "$path" || echo -e "  ${RED}Nota: No se pudo eliminar $path${RESET}"
        fi
    done
}

remove_preferences_glob() {
    echo -e "${CYAN}Buscando preferencias adicionales de Logitech...${RESET}"

    local pref_dir="$HOME/Library/Preferences"
    for plist in "$pref_dir"/com.logi.*.plist "$pref_dir"/com.logitech.*.plist; do
        if [ -e "$plist" ]; then
            echo -e "  Eliminando preferencia: ${YELLOW}$plist${RESET}"
            rm -f "$plist" || echo -e "  ${RED}Nota: No se pudo eliminar $plist${RESET}"
        fi
    done
}

main() {
    echo -e "\n${BOLD}${RED}Desinstalador de Logi Options y LogiTune para macOS${RESET}"
    echo -e "${RED}----------------------------------------------------${RESET}"

    confirm_action
    stop_processes
    remove_files
    remove_preferences_glob

    echo -e "${RED}----------------------------------------------------${RESET}"
    echo -e "${GREEN}${BOLD}Desinstalacion finalizada.${RESET}"
    echo -e "${CYAN}Se recomienda reiniciar el sistema para completar la limpieza.${RESET}\n"
}

# Ejecutar script
main "$@"
