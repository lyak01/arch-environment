#!/usr/bin/env bash
# state.sh - Checkpoint: guardar/leer estado de fases

LOG_DIR="${LOG_DIR:-/var/log/arch-reconstructor}"
STATE_FILE="$LOG_DIR/state.json"

init_state() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"fases_completadas": []}' > "$STATE_FILE"
  fi
}

mark_phase_done() {
  local phase=$1
  if ! grep -q "\"$phase\"" "$STATE_FILE"; then
    sed -i "s/\"fases_completadas\": \[/\"fases_completadas\": [\"$phase\", /" "$STATE_FILE"
  fi
  log "INFO" "Fase $phase marcada como completada."
}

is_phase_done() {
  local phase=$1
  grep -q "\"$phase\"" "$STATE_FILE"
}

resume_if_done() {
  local phase=$1
  if is_phase_done "$phase"; then
    log "INFO" "Fase $phase ya completada. Saltando."
    return 0
  fi
  return 1
}
