#!/usr/bin/env bash
# bootstrap.sh - Asistente CLI para arch-environment

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/ask.sh"
source "$SCRIPT_DIR/lib/install.sh"

LOG_DIR="/var/log/arch-reconstructor"
mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d-%H%M%S).log"

if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse con sudo o como root."
  exit 1
fi

log "INFO" "=== ARCH RECONSTRUCTOR ==="
log "INFO" "Detectando sistema..."
detect_system
log "INFO" "Detectando hardware..."
detect_hardware

ask_profile
ask_desktop
ask_audio
ask_browser
ask_suites
ask_themes

show_summary
if confirm "¿Confirmar e iniciar instalación?"; then
  install_selected
else
  log "INFO" "Instalación cancelada por el usuario."
  exit 0
fi

finalize
