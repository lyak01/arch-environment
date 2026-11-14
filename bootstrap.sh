#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - bootstrap.sh
#  Punto de entrada principal
#  v2.4.3 - Dry-run no marca fases ni clona temas
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/lib/log.sh"
source "$REPO_DIR/lib/detect.sh"
source "$REPO_DIR/lib/install.sh"
source "$REPO_DIR/lib/themes.sh"
source "$REPO_DIR/lib/dotfiles.sh"
source "$REPO_DIR/lib/state.sh"
source "$REPO_DIR/lib/report.sh"

DRY_RUN=0
TOLERANT=0
FORCE_XFCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --tolerant) TOLERANT=1; shift ;;
    *) shift ;;
  esac
done

init_log
init_state
log "INFO" "Iniciando Zynith Reconstructor..."

detect_hardware
detect_existing_de
ask_force_xfce

if ! resume_if_done "packages"; then
  install_all
  [[ $DRY_RUN -eq 0 ]] && mark_phase_done "packages"
fi

if ! resume_if_done "flatpaks"; then
  install_flatpaks
  [[ $DRY_RUN -eq 0 ]] && mark_phase_done "flatpaks"
fi

if ! resume_if_done "dedup"; then
  dedup_packages
  [[ $DRY_RUN -eq 0 ]] && mark_phase_done "dedup"
fi

if [[ $DRY_RUN -eq 0 ]]; then
  force_xfce
fi

if ! resume_if_done "themes"; then
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se sincronizarían e importarían temas desde zynith-themes."
  else
    sync_themes
    import_themes
    import_xfwm4
    import_plymouth
    mark_phase_done "themes"
  fi
fi

if ! resume_if_done "dotfiles"; then
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se preguntaría si importar dotfiles personales."
  else
    if ask_yes_no "¿Importar dotfiles personales?"; then
      import_dotfiles
      mark_phase_done "dotfiles"
    fi
  fi
fi

if ! resume_if_done "scripts"; then
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se preguntaría si importar scripts personales."
  else
    if ask_yes_no "¿Importar scripts personales?"; then
      import_scripts
      mark_phase_done "scripts"
    fi
  fi
fi

generate_report
log "OK" "Proceso completado."
