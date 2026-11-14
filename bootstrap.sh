#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - bootstrap.sh
#  Punto de entrada principal
#  v2.3 - Fuerza XFCE + Plymouth + reporte final
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/lib/log.sh"
source "$REPO_DIR/lib/detect.sh"
source "$REPO_DIR/lib/install.sh"
source "$REPO_DIR/lib/themes.sh"
source "$REPO_DIR/lib/dotfiles.sh"
source "$REPO_DIR/lib/report.sh"

DRY_RUN=0
FORCE_XFCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    *) shift ;;
  esac
done

init_log
log "INFO" "Iniciando Zynith Reconstructor..."

detect_hardware
detect_existing_de
ask_force_xfce

install_all
install_flatpaks
dedup_packages

if [[ $DRY_RUN -eq 0 ]]; then
  force_xfce
fi

sync_themes
import_themes
import_xfwm4
import_plymouth

if ask_yes_no "¿Importar dotfiles personales?"; then
  import_dotfiles
fi

if ask_yes_no "¿Importar scripts personales?"; then
  import_scripts
fi

generate_report
log "OK" "Proceso completado."
