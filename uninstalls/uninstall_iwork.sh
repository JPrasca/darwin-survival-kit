#!/usr/bin/env bash

# ============================================================
# Script: uninstall_iwork.sh
# Descripción: Desinstala la suite de ofimática de Apple (iWork):
#              Pages, Numbers y Keynote, además de limpiar sus 
#              residuos en la carpeta de Containers.
# ============================================================

set -euo pipefail

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}Iniciando la desinstalación de la suite Apple iWork...${RESET}"

# Verificar si se corre con sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Este script requiere permisos de administrador. Por favor, ejecútalo con sudo:${RESET}"
  echo -e "sudo $0"
  exit 1
fi

APPS_TO_REMOVE=(
    "/Applications/Pages Creator Studio.app"
    "/Applications/Numbers Creator Studio.app"
    "/Applications/Keynote Creator Studio.app"
)

CONTAINERS_TO_REMOVE=(
    "$HOME/Library/Containers/com.apple.iWork.Pages"
    "$HOME/Library/Containers/com.apple.iWork.Numbers"
    "$HOME/Library/Containers/com.apple.iWork.Keynote"
)

# Eliminar Aplicaciones
for app in "${APPS_TO_REMOVE[@]}"; do
    if [ -d "$app" ]; then
        echo -e "Eliminando ${app}..."
        rm -rf "$app"
    else
        echo -e "La aplicación ${app} no se encontró."
    fi
done

# Eliminar Contenedores (Residuos)
for container in "${CONTAINERS_TO_REMOVE[@]}"; do
    if [ -d "$container" ]; then
        echo -e "Eliminando residuos de ${container}..."
        rm -rf "$container"
    fi
done

echo -e "\n${BOLD}${GREEN}¡Desinstalación de iWork completada exitosamente!${RESET}"
