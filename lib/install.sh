#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/install.sh
#  Instalación de paquetes y suites (Arch Linux)
#  v2.3 - Fuerza XFCE real + Plymouth + reporte final
# =============================================================

# Detectar entorno de escritorio existente
detect_existing_de() {
  if command -v plasmashell &>/dev/null; then EXISTING_DE="plasma"
  elif command -v gnome-shell &>/dev/null; then EXISTING_DE="gnome"
  elif command -v Hyprland &>/dev/null; then EXISTING_DE="hyprland"
  elif command -v i3 &>/dev/null; then EXISTING_DE="i3-wm"
  elif command -v xfce4-session &>/dev/null; then EXISTING_DE="xfce"
  else EXISTING_DE="none"
  fi
  log "INFO" "Entorno existente detectado: $EXISTING_DE"
}

# Preguntar si forzar XFCE (doble confirmación)
ask_force_xfce() {
  if [[ "$EXISTING_DE" != "none" && "$EXISTING_DE" != "xfce" ]]; then
    read -rp "Se detectó $EXISTING_DE. ¿Forzar XFCE? (s/N): " r1
    if [[ "$r1" =~ ^[Ss]$ ]]; then
      read -rp "Esto DESINSTALARÁ $EXISTING_DE. ¿Confirmar? (escriba 'SI'): " r2
      if [[ "$r2" == "SI" ]]; then
        FORCE_XFCE=1
        log "WARN" "Forzar XFCE activado para $EXISTING_DE."
      fi
    fi
  fi
}

# Forzar XFCE: desinstalar DE anterior
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

# Instalar paquetes de una suite
install_suite() {
  local suite=$1
  local pkgs="${SUITES[$suite]}"
  log "INFO" "Instalando suite: $suite"
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían: $pkgs"
  else
    pacman -S --needed --noconfirm $pkgs
    log "OK" "Suite $suite instalada."
  fi
}

# Instalar todos los paquetes del manifiesto
install_all() {
  log "INFO" "Instalando todos los paquetes del manifiesto..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían todos los paquetes del manifiesto."
  else
    xargs -a "$REPO_DIR/manifest/packages.txt" pacman -S --needed --noconfirm
    log "OK" "Todos los paquetes instalados."
  fi
}

# Instalar Flatpaks
install_flatpaks() {
  log "INFO" "Instalando Flatpaks..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían los Flatpaks del manifiesto."
  else
    while read -r app; do
      flatpak install -y "$app"
    done < "$REPO_DIR/manifest/flatpaks.txt"
    log "OK" "Flatpaks instalados."
  fi
}

# Deduplicar paquetes (solo si el usuario lo pide)
dedup_packages() {
  log "INFO" "Deduplicando paquetes..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se deduplicarían paquetes redundantes."
  else
    pacman -Qdtq | xargs -r pacman -Rns --noconfirm
    log "OK" "Paquetes redundantes eliminados."
  fi
}
