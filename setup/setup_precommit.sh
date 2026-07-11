#!/bin/bash
# Descripcion: Configura un hook de pre-commit de git para ejecutar gitleaks de forma automática.
# Requisitos: gitleaks

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
HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

# Funciones
check_deps() {
  if [ ! -d ".git" ]; then
    echo -e "${RED}[ERROR] Este directorio no es un repositorio git. Ejecuta esto desde la raíz del proyecto.${RESET}"
    exit 1
  fi
  
  if ! command -v gitleaks >/dev/null 2>&1; then
    echo -e "${YELLOW}[INFO] gitleaks no está instalado. Se instalará vía Homebrew...${RESET}"
    if command -v brew >/dev/null 2>&1; then
      brew install gitleaks
    else
      echo -e "${RED}[ERROR] Homebrew no está instalado. Instala Homebrew o gitleaks manualmente.${RESET}"
      exit 1
    fi
  fi
}

setup_hook() {
  echo "=== CONFIGURACIÓN DE SEGURIDAD ==="
  echo "Instalando pre-commit hook de gitleaks..."
  
  mkdir -p "$HOOK_DIR"
  
  cat << 'EOF' > "$HOOK_FILE"
#!/bin/bash
# Script generado automáticamente por setup_precommit.sh
echo "[Pre-commit] Escaneando commits en busca de secretos con gitleaks..."
gitleaks protect -v --staged
EOF
  
  chmod +x "$HOOK_FILE"
  echo -e "${GREEN}[OK] Hook de pre-commit configurado exitosamente en $HOOK_FILE.${RESET}"
  echo "=== PROCESO COMPLETADO ==="
}

main() {
  check_deps
  setup_hook
}

main
