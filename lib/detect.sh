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
  AUDIO="$(pactl info 2>/dev/null | grep -i 'server name' | head -1 || echo 'desconocido')"
  log "INFO" "GPU: $GPU"
  log "INFO" "Audio: $AUDIO"
}
