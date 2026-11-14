#!/usr/bin/env bash
# detect.sh - Detección de sistema, hardware y entorno de escritorio

detect_system() {
  DISTRO="$(. /etc/os-release && echo "$ID")"
  KERNEL="$(uname -r)"
  log "INFO" "Distro: $DISTRO"
  log "INFO" "Kernel: $KERNEL"
}

detect_hardware() {
  GPU="$(lspci -k 2>/dev/null | grep -i -A3 vga | grep -i -E 'nvidia|amd|intel' | head -1 || echo 'desconocida')"
  if command -v pactl &>/dev/null && pactl info &>/dev/null; then
    AUDIO="PulseAudio"
  elif systemctl --user is-active pipewire &>/dev/null; then
    AUDIO="PipeWire"
  else
    AUDIO="desconocido"
  fi
  log "INFO" "GPU: $GPU"
  log "INFO" "Audio: $AUDIO"
}

detect_existing_de() {
  if command -v plasmashell &>/dev/null; then
    EXISTING_DE="plasma"
  elif command -v gnome-shell &>/dev/null; then
    EXISTING_DE="gnome"
  elif command -v Hyprland &>/dev/null; then
    EXISTING_DE="hyprland"
  elif command -v i3 &>/dev/null; then
    EXISTING_DE="i3-wm"
  elif command -v xfce4-session &>/dev/null; then
    EXISTING_DE="xfce"
  else
    EXISTING_DE="none"
  fi
  log "INFO" "Entorno existente detectado: $EXISTING_DE"
}

maybe_force_xfce() {
  if [[ -z "${DESKTOP_VARIANT:-}" || "$DESKTOP_VARIANT" == "none" ]]; then
    return 0
  fi
  if [[ -z "$EXISTING_DE" || "$EXISTING_DE" == "none" || "$EXISTING_DE" == "xfce" ]]; then
    return 0
  fi
  if [[ "$EXISTING_DE" == "$DESKTOP_VARIANT" ]]; then
    return 0
  fi
  local r1 r2
  read -rp "Se detectó $EXISTING_DE y elegiste $DESKTOP_VARIANT. ¿Forzar reemplazo? (s/N): " r1
  if [[ "$r1" =~ ^[Ss]$ ]]; then
    read -rp "Esto DESINSTALARÁ $EXISTING_DE. ¿Confirmar? (escribe SI): " r2
    if [[ "$r2" == "SI" ]]; then
      FORCE_XFCE=1
      log "WARN" "Forzar reemplazo de $EXISTING_DE por $DESKTOP_VARIANT activado."
    fi
  fi
}

force_xfce() {
  if [[ ${FORCE_XFCE:-0} -eq 1 ]]; then
    case "$EXISTING_DE" in
      plasma)
        log "INFO" "Desinstalando Plasma..."
        pacman -Rns --noconfirm plasma sddm 2>/dev/null || log "WARN" "Algunos paquetes de Plasma no se pudieron desinstalar."
        ;;
      gnome)
        log "INFO" "Desinstalando GNOME..."
        pacman -Rns --noconfirm gnome gdm 2>/dev/null || log "WARN" "Algunos paquetes de GNOME no se pudieron desinstalar."
        ;;
      hyprland)
        log "INFO" "Desinstalando Hyprland..."
        pacman -Rns --noconfirm hyprland waybar rofi dunst 2>/dev/null || log "WARN" "Algunos paquetes de Hyprland no se pudieron desinstalar."
        ;;
      i3-wm)
        log "INFO" "Desinstalando i3..."
        pacman -Rns --noconfirm i3-wm i3status rofi picom 2>/dev/null || log "WARN" "Algunos paquetes de i3 no se pudieron desinstalar."
        ;;
    esac
    log "OK" "Entorno anterior ($EXISTING_DE) desinstalado."
  fi
}
