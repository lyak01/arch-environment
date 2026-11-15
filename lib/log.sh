#!/usr/bin/env bash
# =============================================================
#  log.sh - Logging, colores y UI de progreso
# =============================================================

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_MAGENTA=$'\033[35m'
  C_CYAN=$'\033[36m'
  C_WHITE=$'\033[37m'
else
  C_RESET='' C_BOLD='' C_RED='' C_GREEN='' C_YELLOW=''
  C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE=''
fi

init_log() {
  LOG_DIR="/var/log/arch-reconstructor"
  mkdir -p "$LOG_DIR"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  LOG_FILE="$LOG_DIR/install-$ts.log"
  touch "$LOG_FILE"
  log "INFO" "Log inicializado en $LOG_FILE"
}

log() {
  local level="$1"
  shift
  local msg="$*"
  local color="$C_WHITE"
  case "$level" in
    INFO) color="$C_BLUE" ;;
    OK) color="$C_GREEN" ;;
    WARN) color="$C_YELLOW" ;;
    ERROR) color="$C_RED" ;;
    DRY-RUN) color="$C_MAGENTA" ;;
    PHASE) color="$C_CYAN" ;;
  esac
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s[%s] [%s]%s %s\n' "$color" "$ts" "$level" "$C_RESET" "$msg" | tee -a "$LOG_FILE"
}

phase_header() {
  local title="$1"
  {
    echo ""
    printf '%s%s════════════════════════════════════════════════════════════%s\n' "$C_BOLD$C_CYAN" "" "$C_RESET"
    printf '%s  FASE: %s%s\n' "$C_BOLD$C_CYAN" "$title" "$C_RESET"
    printf '%s%s════════════════════════════════════════════════════════════%s\n' "$C_BOLD$C_CYAN" "" "$C_RESET"
  } | tee -a "$LOG_FILE"
}

progress_bar() {
  local current="$1"
  local total="$2"
  local label="${3:-Progreso}"
  if [[ $total -le 0 ]]; then
    printf '%s[%s] %s: 100%% %s\n' "$C_GREEN" "$(date '+%H:%M:%S')" "$label" "$(printf '█%.0s' {1..30})" | tee -a "$LOG_FILE"
    return 0
  fi
  local pct=$(( current * 100 / total ))
  local filled=$(( pct * 30 / 100 ))
  local empty=$(( 30 - filled ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  local color="$C_YELLOW"
  if [[ $pct -ge 100 ]]; then color="$C_GREEN"; fi
  printf '\r%s[%s] %s: %s %3d%% %s' "$C_BOLD" "$(date '+%H:%M:%S')" "$label" "$color$bar$C_RESET" "$pct" "" | tee -a "$LOG_FILE"
  if [[ $pct -ge 100 ]]; then echo "" | tee -a "$LOG_FILE"; fi
}
