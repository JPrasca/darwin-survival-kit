#!/bin/bash
# Descripcion: Verifica la existencia de claves SSH o crea una nueva si no existe
# Requisitos: ssh-keygen

set -euo pipefail

# Configuración de colores
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  RESET='\033[0m'
else
  GREEN=''
  YELLOW=''
  RED=''
  RESET=''
fi

# Variables
SSH_DIR="$HOME/.ssh"
SSH_KEY_TYPE="ed25519"
SSH_KEY_PATH="$SSH_DIR/id_$SSH_KEY_TYPE"

# Funciones
check_deps() {
  if ! command -v ssh-keygen >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] ssh-keygen no está instalado.${RESET}"
    exit 1
  fi
}

verify_or_create_key() {
  echo "=== CONFIGURACIÓN DE SSH ==="
  echo "Verificando claves SSH..."

  if [ -f "$SSH_KEY_PATH" ]; then
    echo -e "${GREEN}[OK] Clave SSH encontrada: $SSH_KEY_PATH${RESET}"
    echo "Clave pública:"
    cat "${SSH_KEY_PATH}.pub"
  else
    echo -e "${YELLOW}[INFO] No se encontró clave SSH. Generando nueva clave...${RESET}"
    
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    ssh-keygen -t "$SSH_KEY_TYPE" -f "$SSH_KEY_PATH" -N "" -q
    
    echo -e "${GREEN}[OK] Clave SSH generada exitosamente.${RESET}"
    echo "Clave pública:"
    cat "${SSH_KEY_PATH}.pub"
  fi
  
  echo "=== PROCESO COMPLETADO ==="
}

main() {
  check_deps
  verify_or_create_key
}

main
