#!/usr/bin/env bash
# Script: check-antigravity-quota.sh
# Descripción: Consulta el estado de cuota y suscripción de Google/Gemini.
# Requisitos: gcloud CLI, jq, curl.

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

export PATH="/opt/homebrew/share/google-cloud-sdk/bin:/usr/local/share/google-cloud-sdk/bin:$PATH"
export CLOUDSDK_PYTHON="${CLOUDSDK_PYTHON:-$(which python3 || echo "python3")}"

sep() { echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}"; sep; }

check_deps() {
    local missing=0
    for cmd in gcloud curl jq; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}✗ Falta instalar: $cmd${RESET}"
            missing=1
        fi
    done
    [[ $missing -eq 1 ]] && exit 1
}

get_token() {
    gcloud auth print-access-token 2>/dev/null || {
        echo -e "${RED}✗ No autenticado. Ejecuta: gcloud auth login${RESET}"
        exit 1
    }
}

show_account_info() {
    header "Cuenta de Google activa"
    gcloud config list account --format="value(core.account)" | xargs -I{} echo -e "  ${GREEN}Email: {}${RESET}"
    
    echo -e "\n  ${BOLD}Proyectos GCP:${RESET}"
    gcloud projects list --format="table(projectId,name,lifecycleState)" 2>/dev/null || echo "  Sin proyectos."
}

show_gemini_models() {
    header "Modelos Gemini disponibles"
    local token
    token=$(get_token)
    
    local response
    response=$(curl -s -H "Authorization: Bearer $token" "https://generativelanguage.googleapis.com/v1/models" 2>/dev/null)

    if echo "$response" | jq -e '.models' &>/dev/null; then
        echo "$response" | jq -r '.models[] | select(.name | test("gemini")) | "  \(.displayName // .name)\n    └─ In: \(.inputTokenLimit) | Out: \(.outputTokenLimit)"'
    else
        echo -e "  ${YELLOW}No se pudo obtener la lista de modelos.${RESET}"
    fi
}

main() {
    echo -e "\n${BOLD}${CYAN}🌐 Antigravity / Gemini — Auditoría de Cuota${RESET}"
    echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"
    
    check_deps
    show_account_info
    show_gemini_models
    
    header "Resumen de acceso"
    echo -e "  Gestiona tu suscripción en: ${CYAN}https://one.google.com/about/plans${RESET}"
    echo -e "  Ver cuotas en tiempo real: ${CYAN}https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com/quotas${RESET}"
    
    echo ""
    sep
    echo -e "${GREEN}✅ Consulta completada.${RESET}"
    sep
    echo ""
}

main "$@"
