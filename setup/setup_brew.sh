#!/bin/bash
# Nombre: setup_brew.sh
# Descripcion: Instalación y configuración de Homebrew y dependencias base.
# Requisitos: curl, bash (entorno macOS).

set -euo pipefail

if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
else
    GREEN=''
    YELLOW=''
    BLUE=''
    RESET=''
fi

print_info() {
    echo -e "${BLUE}=== $1 ===${RESET}"
}

print_success() {
    echo -e "${GREEN}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}$1${RESET}"
}

install_homebrew() {
    print_info "VERIFICANDO HOMEBREW"
    if ! command -v brew > /dev/null 2>&1; then
        print_info "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_warning "Homebrew ya se encuentra instalado."
    fi
}

configure_path() {
    print_info "CONFIGURANDO PATH"
    # shellcheck disable=SC2016
    if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zshrc 2>/dev/null; then
        # shellcheck disable=SC2016
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

update_brew() {
    print_info "ACTUALIZANDO BREW"
    echo "Actualizando índices de Homebrew..."
    brew update
}

install_base_tools() {
    print_info "INSTALANDO HERRAMIENTAS BASE"
    echo "Instalando dependencias (displayplacer, wget, htop, git)..."
    brew install displayplacer wget htop git
}

main() {
    install_homebrew
    configure_path
    update_brew
    install_base_tools
    
    echo -e "\n---"
    print_success "Proceso de configuración completado."
}

main
