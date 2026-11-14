#!/usr/bin/env bash
# bootstrap.sh - Asistente CLI para arch-environment

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/ask.sh"
source "$SCRIPT_DIR/lib/install.sh"
source "$SCRIPT_DIR/lib/themes.sh"
source "$SCRIPT_DIR/lib/dotfiles.sh"
source "$SCRIPT_DIR/lib/scripts.sh"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

LOG_DIR="/var/log/arch-reconstructor"
mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d-%H%M%S).log"

if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse con sudo o como root."
  exit 1
fi

ensure_git() {
  if ! command -v git &>/dev/null; then
    log "INFO" "git no está instalado, instalando..."
    if [[ $DRY_RUN -eq 1 ]]; then
      log "INFO" "[DRY-RUN] Se instalaría git."
    else
      pacman -Sy --noconfirm git
    fi
  fi
}

log "INFO" "=== ARCH RECONSTRUCTOR ==="
if [[ $DRY_RUN -eq 1 ]]; then
  log "INFO" "Modo DRY-RUN activado: no se instalará nada."
fi
ensure_git
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
ask_dotfiles
ask_scripts

show_summary
if confirm "¿Confirmar e iniciar instalación?"; then
  install_selected
  if [[ $APPLY_THEMES -eq 1 ]]; then
    import_themes
  fi
  import_dotfiles
  import_scripts
else
  log "INFO" "Instalación cancelada por el usuario."
  exit 0
fi

finalize
