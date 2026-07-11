#!/bin/bash
# Descripcion: Escanea el repositorio en busca de datos sensibles (API keys, claves privadas, tokens) usando gitleaks.
# Requisitos: gitleaks, brew

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

# Funciones
check_deps() {
  if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Homebrew no está instalado. No se puede instalar dependencias automáticamente.${RESET}"
    exit 1
  fi

  if ! command -v gitleaks >/dev/null 2>&1; then
    echo -e "${YELLOW}[INFO] gitleaks no está instalado. Procediendo con la instalación vía Homebrew...${RESET}"
    brew install gitleaks
  fi
}

scan_repo() {
  echo "=== AUDITORÍA DE SEGURIDAD: DATOS SENSIBLES ==="
  echo "Escaneando el historial de git en busca de secretos, tokens o claves filtradas..."
  
  # gitleaks detect escanea el repositorio actual. 
  # set +e se usa temporalmente porque gitleaks retorna exit code 1 si encuentra secretos
  set +e
  gitleaks detect -v --source .
  EXIT_CODE=$?
  set -e
  
  if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}[OK] No se encontraron datos sensibles expuestos en el repositorio.${RESET}"
  elif [ $EXIT_CODE -eq 1 ]; then
    echo -e "${RED}[ALERTA] Se detectaron posibles secretos o datos sensibles. Por favor, revisa la salida anterior.${RESET}"
  else
    echo -e "${RED}[ERROR] Ocurrió un error inesperado al ejecutar gitleaks.${RESET}"
  fi
  
  echo "=== PROCESO COMPLETADO ==="
}

main() {
  check_deps
  scan_repo
}

main
