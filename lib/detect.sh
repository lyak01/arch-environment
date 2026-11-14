#!/usr/bin/env bash
# detect.sh - Detección de sistema y hardware

detect_system() {
  DISTRO="$(. /etc/os-release && echo "$ID")"
  KERNEL="$(uname -r)"
  PKG_MGR="pacman"
  log "INFO" "Distro: $DISTRO"
  log "INFO" "Kernel: $KERNEL"
  log "INFO" "Gestor de paquetes: $PKG_MGR"
}

detect_hardware() {
  GPU="$(lspci -k | grep -i -A3 vga | grep -i -E 'nvidia|amd|intel' | head -1 || echo 'desconocida')"
  if pactl info &>/dev/null; then
    AUDIO="PulseAudio"
  elif systemctl --user is-active pipewire &>/dev/null; then
    AUDIO="PipeWire"
  else
    AUDIO="desconocido"
  fi
  log "INFO" "GPU: $GPU"
  log "INFO" "Audio: $AUDIO"
}
