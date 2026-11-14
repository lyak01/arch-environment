#!/usr/bin/env bash
# log.sh - Registro de eventos

LOG_FILE="${LOG_FILE:-/tmp/arch-reconstructor.log}"

log() {
  local level="$1"; shift
  local msg="$*"
  printf '[%s] %s\n' "$level" "$msg" | tee -a "$LOG_FILE"
}
