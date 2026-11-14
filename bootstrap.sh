#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - bootstrap.sh
#  Punto de entrada principal
#  v3.0 - Asistente interactivo: suites omitibles, selección
#  múltiple desde sugerencias, confirmación explícita, dry-run,
#  tolerancia a fallos, checkpoint y reporte final.
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/lib/log.sh"
source "$REPO_DIR/lib/detect.sh"
source "$REPO_DIR/lib/suites.sh"
source "$REPO_DIR/lib/suggest.sh"
source "$REPO_DIR/lib/install.sh"
source "$REPO_DIR/lib/themes.sh"
source "$REPO_DIR/lib/dotfiles.sh"
source "$REPO_DIR/lib/state.sh"
source "$REPO_DIR/lib/report.sh"

DRY_RUN=0
TOLERANT=0
FRESH=0
FORCE_XFCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --tolerant)
      TOLERANT=1
      shift
      ;;
    --fresh)
      FRESH=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

init_log
if [[ $FRESH -eq 1 ]]; then
  rm -f "$LOG_DIR/state.json"
  log "INFO" "Estado previo eliminado (--fresh)."
fi
init_state
log "INFO" "Iniciando Zynith Reconstructor..."

detect_system
detect_hardware
detect_existing_de

parse_suites
select_suites
maybe_force_xfce
collect_packages
build_suggestions
ask_suggestions

if [[ ${#SELECTED_PACKAGES[@]} -gt 0 ]]; then
  echo "=== PAQUETES SELECCIONADOS ==="
  local p
  for p in "${SELECTED_PACKAGES[@]}"; do
    echo " - $p"
  done
  if [[ $DRY_RUN -eq 0 ]]; then
    local c
    read -rp "¿Confirmar instalación? (escribe SI): " c
    if [[ "$c" != "SI" ]]; then
      log "INFO" "Instalación cancelada por el usuario."
      exit 0
    fi
  fi
fi

if [[ -f /var/lib/pacman/db.lck ]]; then
  log "WARN" "Existe /var/lib/pacman/db.lck. Puede haber otra transacción de pacman en curso."
fi

if ! resume_if_done "packages"; then
  install_selected
fi

if ! resume_if_done "flatpaks"; then
  install_flatpaks
fi

if ! resume_if_done "dedup"; then
  dedup_packages
fi

if [[ $DRY_RUN -eq 0 ]]; then
  force_xfce
fi

if ! resume_if_done "themes"; then
  if ask_yes_no "¿Importar temas Zynith (GTK, iconos, cursores, Plymouth)?"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "DRY-RUN" "Se importarían temas Zynith."
    else
      sync_themes
      import_themes
      import_xfwm4
      import_plymouth
      mark_phase_done "themes"
    fi
  else
    log "INFO" "Temas omitidos por el usuario."
  fi
fi

if ! resume_if_done "dotfiles"; then
  if ask_yes_no "¿Importar dotfiles personales?"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "DRY-RUN" "Se importarían dotfiles personales."
    else
      import_dotfiles
    fi
  else
    log "INFO" "Dotfiles omitidos por el usuario."
  fi
fi

if ! resume_if_done "scripts"; then
  if ask_yes_no "¿Importar scripts personales?"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "DRY-RUN" "Se importarían scripts personales."
    else
      import_scripts
    fi
  else
    log "INFO" "Scripts omitidos por el usuario."
  fi
fi

generate_report
log "OK" "Proceso completado."
