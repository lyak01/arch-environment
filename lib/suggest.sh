#!/usr/bin/env bash
# suggest.sh - Sugerencias condicionales según hardware/entorno

build_suggestions() {
  SUGGESTIONS=()
  if [[ "$GPU" == *nvidia* || "$GPU" == *NVIDIA* ]]; then
    SUGGESTIONS+=(gwe nvidia-580xx-settings)
  fi
  if [[ "$AUDIO" == "PulseAudio" ]]; then
    SUGGESTIONS+=(pulseeffects pulseaudio-equalizer-ladspa)
  fi
  if [[ "${DESKTOP_VARIANT:-}" == "xfce" ]]; then
    SUGGESTIONS+=(xfce4-docklike-plugin xfce4-whiskermenu-plugin)
  fi
  if [[ "${DESKTOP_VARIANT:-}" == "kde" ]]; then
    SUGGESTIONS+=(konsole dolphin)
  fi
  local -A seen=()
  local -a uniq=()
  local p
  for p in "${SUGGESTIONS[@]}"; do
    if [[ -z "${seen[$p]:-}" ]]; then
      seen[$p]=1
      uniq+=("$p")
    fi
  done
  SUGGESTIONS=("${uniq[@]}")
}

ask_suggestions() {
  if [[ ${#SUGGESTIONS[@]} -eq 0 ]]; then
    log "INFO" "No hay sugerencias adicionales para tu hardware/entorno."
    return 0
  fi
  ask_multiselect "Sugerencias personalizadas (opcional):" "${SUGGESTIONS[@]}"
  if [[ ${#SELECTED[@]} -gt 0 ]]; then
    SELECTED_PACKAGES+=("${SELECTED[@]}")
    local -A seen=()
    local -a uniq=()
    local p
    for p in "${SELECTED_PACKAGES[@]}"; do
      if [[ -z "${seen[$p]:-}" ]]; then
        seen[$p]=1
        uniq+=("$p")
      fi
    done
    SELECTED_PACKAGES=("${uniq[@]}")
    log "INFO" "Sugerencias añadidas: ${SELECTED[*]}"
  else
    log "INFO" "No se añadieron sugerencias."
  fi
}
