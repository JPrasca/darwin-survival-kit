#!/bin/bash
# Nombre: setup_terminal.sh
# Descripcion: Configuración visual y de productividad para la terminal nativa de macOS.
#              Instala JetBrains Mono Nerd Font, plugins de Zsh, eza y genera respaldo previo.
# Requisitos: Homebrew, bash, macOS

set -euo pipefail

# Detección de TTY y configuración de colores
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    RESET=''
fi

# Variables de rutas
BACKUP_BASE="$HOME/.darwin_terminal_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
LATEST_DIR="$BACKUP_BASE/latest"
ZSHRC="$HOME/.zshrc"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
MANIFEST_FILE="$BACKUP_DIR/installed_packages.txt"

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

check_deps() {
    print_info "VERIFICANDO DEPENDENCIAS"
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew no está instalado. Ejecutar previamente setup/setup_brew.sh."
        exit 1
    fi
    print_success "Homebrew detectado correctamente."
}

create_backup() {
    print_info "CREANDO RESPALDO DE SEGURIDAD"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_BASE"
    touch "$MANIFEST_FILE"

    if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "$BACKUP_DIR/zshrc"
        echo "Respaldo generado: $BACKUP_DIR/zshrc"
    else
        echo "No se detectó .zshrc existente. Se creará uno nuevo."
        touch "$BACKUP_DIR/zshrc_was_missing"
    fi

    if [ -f "$STARSHIP_CONFIG" ]; then
        cp "$STARSHIP_CONFIG" "$BACKUP_DIR/starship.toml"
        echo "Respaldo generado: $BACKUP_DIR/starship.toml"
    fi

    if [ -f "$HOME/.config/starship_pwd.sh" ]; then
        cp "$HOME/.config/starship_pwd.sh" "$BACKUP_DIR/starship_pwd.sh"
        echo "Respaldo generado: $BACKUP_DIR/starship_pwd.sh"
    fi

    rm -rf "$LATEST_DIR"
    ln -s "$BACKUP_DIR" "$LATEST_DIR"
    print_success "Directorio de respaldo activo: $LATEST_DIR"
}

install_tool() {
    local type="$1"
    local name="$2"

    if [ "$type" == "formula" ]; then
        if brew list --formula 2>/dev/null | grep -qx "$name"; then
            echo "Fórmula ya instalada: $name"
        else
            echo "Instalando fórmula: $name..."
            brew install "$name"
            echo "formula:$name" >> "$MANIFEST_FILE"
        fi
    elif [ "$type" == "cask" ]; then
        if brew list --cask 2>/dev/null | grep -qx "$name"; then
            echo "Cask ya instalado: $name"
        else
            echo "Instalando cask: $name..."
            brew install --cask "$name"
            echo "cask:$name" >> "$MANIFEST_FILE"
        fi
    fi
}

install_dependencies() {
    print_info "INSTALANDO COMPONENTES VISUALES Y PLUGINS"
    
    # Fuente con soporte completo de glifos e iconos
    install_tool "cask" "font-jetbrains-mono-nerd-font"

    # Plugins de productividad para Zsh
    install_tool "formula" "zsh-autosuggestions"
    install_tool "formula" "zsh-syntax-highlighting"

    # Reemplazo moderno de ls con iconos
    install_tool "formula" "eza"
}

configure_zshrc() {
    print_info "CONFIGURANDO ENTORNO ZSH (~/.zshrc)"

    local start_marker="# >>> darwin-survival-kit terminal config >>>"
    local end_marker="# <<< darwin-survival-kit terminal config <<<"

    # Preparar el bloque de configuración
    local config_block
    config_block=$(cat << 'EOF'
# >>> darwin-survival-kit terminal config >>>
# Integración Homebrew
if command -v brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX="$(brew --prefix)"

    # Plugin: zsh-autosuggestions (optimizado para fondo claro)
    if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
    fi

    # Plugin: zsh-syntax-highlighting (debe cargarse al final de los plugins)
    if [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        # Estilos de alto contraste para fondo claro
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[command]='fg=28,bold'
        ZSH_HIGHLIGHT_STYLES[builtin]='fg=28,bold'
        ZSH_HIGHLIGHT_STYLES[alias]='fg=28,bold'
        ZSH_HIGHLIGHT_STYLES[function]='fg=28,bold'
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=160,bold'
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi

# Starship Prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Zoxide (navegación inteligente: comando z)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# FZF (atajos interactivos de historial y archivos)
if [ -f "$HOME/.fzf.zsh" ]; then
    source "$HOME/.fzf.zsh"
fi

# Tema de sintaxis de alto contraste para bat en fondo claro
export BAT_THEME="GitHub"

# Aliases de visualización y productividad
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --icons=auto --group-directories-first"
    alias ll="eza -la --icons=auto --git --group-directories-first"
    alias lt="eza --tree --level=2 --icons=auto"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat="bat --paging=never --style=plain"
fi

# Optimización de historial Zsh
setopt HIST_IGNORE_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY
# <<< darwin-survival-kit terminal config <<<
EOF
)

    touch "$ZSHRC"

    # Si ya existía una versión anterior del bloque, se reemplaza limpiamente
    if grep -qF "$start_marker" "$ZSHRC"; then
        echo "Actualizando bloque de configuración previo en $ZSHRC..."
        # Remover bloque previo
        sed -i.tmp "/$start_marker/,/$end_marker/d" "$ZSHRC"
        rm -f "${ZSHRC}.tmp"
    fi

    # Agregar bloque al final
    echo "" >> "$ZSHRC"
    echo "$config_block" >> "$ZSHRC"

    print_success "Configuración integrada en $ZSHRC."
}

show_completion_report() {
    echo -e "\n---"
    print_success "Configuración de terminal completada exitosamente."
    echo ""
    echo "Pasos adicionales recomendados:"
    echo "1. Para aplicar los cambios en la sesión actual, ejecutar:"
    echo -e "   ${BOLD}source ~/.zshrc${RESET}"
    echo ""
    echo "2. Para activar la tipografía con iconos en Terminal.app:"
    echo "   Ajustes (Cmd + ,) -> Perfiles -> Texto -> Tipo de letra -> Seleccionar 'JetBrainsMono Nerd Font'."
    echo ""
    echo "3. En caso de requerir revertir los cambios en cualquier momento:"
    echo -e "   ${BOLD}./setup/revert_terminal.sh${RESET}"
    echo "---"
}

main() {
    check_deps
    create_backup
    install_dependencies
    configure_zshrc
    show_completion_report
}

main
