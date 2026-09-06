#!/bin/bash
# Nombre: revert_terminal.sh
# Descripcion: Reversión integral de la configuración de terminal.
#              Restaura ~/.zshrc y desinstala componentes agregados por setup_terminal.sh.
# Requisitos: Homebrew, bash, macOS

set -euo pipefail

# Detección de TTY y configuración de colores
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Variables de rutas
BACKUP_BASE="$HOME/.darwin_terminal_backup"
LATEST_DIR="$BACKUP_BASE/latest"
ZSHRC="$HOME/.zshrc"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

print_info() {
    echo -e "${BLUE}=== $1 ===${RESET}"
}

print_success() {
    echo -e "${GREEN}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}$1${RESET}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

confirm_action() {
    echo -e "${YELLOW}${BOLD}ADVERTENCIA: Esta acción restaurará la configuración previa de la terminal.${RESET}"
    read -p "¿Proceder con la reversión? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}Operación cancelada.${RESET}"
        exit 0
    fi
}

restore_configurations() {
    print_info "RESTAURANDO ARCHIVOS DE CONFIGURACIÓN"

    local start_marker="# >>> darwin-survival-kit terminal config >>>"
    local end_marker="# <<< darwin-survival-kit terminal config <<<"

    if [ -d "$LATEST_DIR" ]; then
        # Restauración de .zshrc
        if [ -f "$LATEST_DIR/zshrc" ]; then
            cp "$LATEST_DIR/zshrc" "$ZSHRC"
            print_success "Restaurado: $ZSHRC desde respaldo previo."
        elif [ -f "$LATEST_DIR/zshrc_was_missing" ]; then
            rm -f "$ZSHRC"
            print_success "Eliminado: $ZSHRC (no existía antes de la configuración)."
        fi

        # Restauración de starship.toml si existía respaldo
        if [ -f "$LATEST_DIR/starship.toml" ]; then
            cp "$LATEST_DIR/starship.toml" "$STARSHIP_CONFIG"
            print_success "Restaurado: $STARSHIP_CONFIG desde respaldo previo."
        fi

        # Restauración de starship_pwd.sh si existía respaldo
        if [ -f "$LATEST_DIR/starship_pwd.sh" ]; then
            cp "$LATEST_DIR/starship_pwd.sh" "$HOME/.config/starship_pwd.sh"
            print_success "Restaurado: $HOME/.config/starship_pwd.sh desde respaldo previo."
        fi
    else
        print_warning "No se detectó directorio de respaldo en $LATEST_DIR."
        if [ -f "$ZSHRC" ] && grep -qF "$start_marker" "$ZSHRC"; then
            echo "Removiendo bloque de configuración darwin-survival-kit de $ZSHRC..."
            sed -i.tmp "/$start_marker/,/$end_marker/d" "$ZSHRC"
            rm -f "${ZSHRC}.tmp"
            print_success "Bloque de configuración retirado de $ZSHRC."
        fi
    fi
}

uninstall_installed_packages() {
    print_info "VERIFICANDO PAQUETES A DESINSTALAR"

    local manifest=""
    if [ -f "$LATEST_DIR/installed_packages.txt" ]; then
        manifest="$LATEST_DIR/installed_packages.txt"
    fi

    if [ -z "$manifest" ] || [ ! -s "$manifest" ]; then
        echo "No se registraron nuevos paquetes instalados por setup_terminal.sh."
        return 0
    fi

    echo "Los siguientes paquetes fueron instalados durante la configuración:"
    while IFS= read -r item || [ -n "$item" ]; do
        [ -z "$item" ] && continue
        echo "  - $item"
    done < "$manifest"

    echo ""
    read -p "¿Desinstalar los paquetes listados vía Homebrew? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Conservando paquetes instalados en el sistema."
        return 0
    fi

    echo "Desinstalando paquetes..."
    while IFS= read -r item || [ -n "$item" ]; do
        [ -z "$item" ] && continue
        local pkg_type="${item%%:*}"
        local pkg_name="${item#*:}"

        if [ "$pkg_type" == "formula" ]; then
            echo "Desinstalando fórmula: $pkg_name..."
            brew uninstall "$pkg_name" || print_warning "No se pudo desinstalar $pkg_name"
        elif [ "$pkg_type" == "cask" ]; then
            echo "Desinstalando cask: $pkg_name..."
            brew uninstall --cask "$pkg_name" || print_warning "No se pudo desinstalar cask $pkg_name"
        fi
    done < "$manifest"

    print_success "Desinstalación de componentes finalizada."
}

show_completion_report() {
    echo -e "\n---"
    print_success "Reversión de terminal completada exitosamente."
    echo ""
    echo "Para reflejar los cambios en la sesión actual, ejecutar:"
    echo -e "   ${BOLD}source ~/.zshrc${RESET}"
    echo "---"
}

main() {
    confirm_action
    restore_configurations
    uninstall_installed_packages
    show_completion_report
}

main
