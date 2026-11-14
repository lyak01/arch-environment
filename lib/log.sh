#!/usr/bin/env bash
# log.sh - Registro de eventos
# v2.4.1 - Añade init_log y LOG_DIR global

LOG_DIR="${LOG_DIR:-/var/log/arch-reconstructor}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log}"

init_log() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  log "INFO" "Log inicializado en $LOG_FILE"
}

log() {
  local level="$1"; shift
  local msg="$*"
  printf '[%s] %s\n' "$level" "$msg" | tee -a "$LOG_FILE"
}
