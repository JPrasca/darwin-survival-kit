#!/usr/bin/env bash
# Script: scan-sql.sh
# Descripción: Busca sentencias SQL potencialmente peligrosas (DROP, DELETE sin WHERE, etc.)
# Requisitos: grep con soporte Perl-regexp (-P)

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

# Expresiones para sentencias con un enfoque estricto
declare -A patterns=(
  ["DROP"]="DROP\s+(TABLE|DATABASE)"
  ["DELETE-ALL"]="DELETE\s+FROM\s+\w+\s*$;"
  ["TRUNCATE"]="TRUNCATE\s+TABLE"
  ["ALTER"]="ALTER\s+TABLE"
  ["EXEC"]="EXEC(UTE)?\s+"
  ["UPDATE-ALL"]="UPDATE\s+\w+\s+SET\s+.*(?<!\sWHERE)\s*;"
)

scan_file() {
    local file="$1"
    # Lee el archivo completo en una sola variable, reemplazando saltos de línea por espacios
    local sql_content
    sql_content=$(tr '\n' ' ' < "$file" | tr -s ' ')

    # Por cada patrón, busca en todo el contenido del archivo
    for key in "${!patterns[@]}"; do
        if echo "$sql_content" | grep -iqPE "${patterns[$key]}"; then
            echo -e "${RED}[ALERT]${RESET} ${YELLOW}$key${RESET} detectado en: ${CYAN}$file${RESET}"
        fi
    done
}

main() {
    local base_dir="${1:-.}"

    echo -e "\n${BOLD}${CYAN}🔍 Buscando SQL peligroso en: $base_dir${RESET}"
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"

    # Encuentra todos los archivos .sql
    local found=0
    while IFS= read -r file; do
        scan_file "$file"
        found=1
    done < <(find "$base_dir" -type f -name "*.sql")

    if [ "$found" -eq 0 ]; then
        echo -e "${GREEN}No se encontraron archivos .sql para analizar.${RESET}"
    fi

    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}\n"
}

main "$@"