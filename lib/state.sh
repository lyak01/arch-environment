#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/state.sh
#  Checkpoint: guardar/leer estado de fases
#  v2.4 - Reanudación de instalación incompleta
# =============================================================

STATE_FILE="$LOG_DIR/state.json"

# Inicializar estado si no existe
init_state() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"fases_completadas": []}' > "$STATE_FILE"
  fi
}

# Marcar fase como completada
mark_phase_done() {
  local phase=$1
  if ! grep -q "$phase" "$STATE_FILE"; then
    sed -i "s/\"fases_completadas\": \[/\"fases_completadas\": [\"$phase\", /" "$STATE_FILE"
  fi
  log "INFO" "Fase $phase marcada como completada."
}

# Verificar si fase ya está completada
is_phase_done() {
  local phase=$1
  grep -q "\"$phase\"" "$STATE_FILE"
}

# Reanudar: saltar fases completadas
resume_if_done() {
  local phase=$1
  if is_phase_done "$phase"; then
    log "INFO" "Fase $phase ya completada. Saltando."
    return 0
  fi
  return 1
}
