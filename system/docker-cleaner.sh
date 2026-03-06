#!/usr/bin/env bash
# ============================================================
# Script: docker-cleaner.sh
# Descripción: Limpia recursos de Docker (contenedores, imágenes, 
#               volúmenes y caché) con opciones de confirmación.
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
confirm() {
    local message="$1"
    read -p "$(echo -e "${YELLOW}${BOLD}¿$message? (s/n): ${RESET}")" -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Ss]$ ]]
}

clean_containers() {
    echo -e "\n${CYAN}--- Gestión de Contenedores ---${RESET}"
    if [ "$(docker ps -aq | wc -l)" -eq 0 ]; then
        echo "No hay contenedores en el sistema."
        return
    fi

    if confirm "Deseas DETENER y ELIMINAR TODOS los contenedores (incluyendo activos)"; then
        docker stop $(docker ps -aq) 2>/dev/null || true
        docker rm -f $(docker ps -aq) 2>/dev/null || true
        echo -e "${GREEN}Todos los contenedores han sido eliminados.${RESET}"
    else
        echo -e "${CYAN}Limpiando solo contenedores detenidos...${RESET}"
        docker container prune -f
    fi
}

clean_images() {
    echo -e "\n${CYAN}--- Gestión de Imágenes ---${RESET}"
    if [ "$(docker images -q | wc -l)" -eq 0 ]; then
        echo "No hay imágenes en el sistema."
        return
    fi

    if confirm "Deseas eliminar TODAS las imágenes del sistema (incluso las usadas)"; then
        docker rmi -f $(docker images -aq) 2>/dev/null || true
        echo -e "${GREEN}Todas las imágenes han sido eliminadas.${RESET}"
    else
        echo -e "${CYAN}Limpiando solo imágenes sin uso (dangling) o no referenciadas...${RESET}"
        docker image prune -a -f
    fi
}

clean_volumes() {
    echo -e "\n${CYAN}--- Gestión de Volúmenes ---${RESET}"
    if [ "$(docker volume ls -q | wc -l)" -eq 0 ]; then
        echo "No hay volúmenes en el sistema."
        return
    fi

    if confirm "Deseas eliminar ABSOLUTAMENTE TODOS los volúmenes"; then
        docker volume rm $(docker volume ls -q) 2>/dev/null || true
        echo -e "${GREEN}Todos los volúmenes han sido eliminados.${RESET}"
    else
        echo -e "${CYAN}Limpiando solo volúmenes huerfanos (dangling)...${RESET}"
        docker volume prune -f
    fi
}

clean_cache() {
    echo -e "\n${CYAN}--- Gestión de Caché de Construcción ---${RESET}"
    if confirm "Deseas limpiar la caché de construcción (Builder Cache)"; then
        docker builder prune -f
        echo -e "${GREEN}Caché de construcción eliminada.${RESET}"
    fi
}

main() {
    echo -e "\n${BOLD}${RED}Limpiador Inteligente de Docker${RESET}"
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    echo -e "${CYAN}Estado de uso de disco ANTES de la limpieza:${RESET}"
    docker system df
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    clean_containers
    clean_images
    clean_volumes
    clean_cache
    
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    echo -e "${GREEN}${BOLD}Proceso de limpieza finalizado.${RESET}\n"
    
    echo -e "${CYAN}Estado de uso de disco DESPUÉS de la limpieza:${RESET}"
    docker system df
    echo -e "${RED}────────────────────────────────────────────────────${RESET}"
    
    echo -e "${CYAN}Resumen de recursos restantes:${RESET}"
    echo "Contenedores: $(docker ps -a | wc -l | xargs -n1 expr -1) restantes"
    echo "Imágenes: $(docker images | wc -l | xargs -n1 expr -1) restantes"
    echo "Volúmenes: $(docker volume ls -q | wc -l) restantes"
}

# Ejecutar
main "$@"