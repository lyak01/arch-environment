#!/usr/bin/env bash
# log.sh - Registro de eventos y utilidades de interacción

LOG_DIR="${LOG_DIR:-/var/log/arch-reconstructor}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log}"

init_log() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  log "INFO" "Log inicializado en $LOG_FILE"
}

log() {
  local level="$1"
  shift
  local msg="$*"
  printf '[%s] %s\n' "$level" "$msg" | tee -a "$LOG_FILE"
}

ask_yes_no() {
  local prompt="$1"
  local r
  read -rp "$prompt (s/N): " r
  [[ "$r" =~ ^[Ss]$ ]]
}
