#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/install.sh
#  Instalación de paquetes y suites (Arch Linux)
#  v2.4.2 - Tolerancia a fallos + detección/fuerza XFCE restauradas
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

# Instalar paquetes de una suite (tolerante si --tolerant)
install_suite() {
  local suite=$1
  local pkgs="${SUITES[$suite]}"
  log "INFO" "Instalando suite: $suite"
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían: $pkgs"
  else
    if ! pacman -S --needed --noconfirm $pkgs; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "Fallo instalando suite $suite. Continuando..."
        echo "$suite" >> "$LOG_DIR/failed-suites.log"
      else
        log "ERROR" "Fallo instalando suite $suite. Abortando."
        exit 1
      fi
    else
      log "OK" "Suite $suite instalada."
    fi
  fi
}

# Instalar todos los paquetes del manifiesto (tolerante)
install_all() {
  log "INFO" "Instalando todos los paquetes del manifiesto..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían todos los paquetes del manifiesto."
  else
    while read -r pkg; do
      if ! pacman -S --needed --noconfirm "$pkg"; then
        if [[ $TOLERANT -eq 1 ]]; then
          log "WARN" "Fallo instalando $pkg. Continuando..."
          echo "$pkg" >> "$LOG_DIR/failed-packages.log"
        else
          log "ERROR" "Fallo instalando $pkg. Abortando."
          exit 1
        fi
      else
        echo "$pkg" >> "$LOG_DIR/installed-packages.log"
      fi
    done < "$REPO_DIR/manifest/packages.txt"
    log "OK" "Paquetes del manifiesto procesados."
  fi
}

# Instalar Flatpaks (tolerante)
install_flatpaks() {
  log "INFO" "Instalando Flatpaks..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían los Flatpaks del manifiesto."
  else
    while read -r app; do
      if ! flatpak install -y "$app"; then
        if [[ $TOLERANT -eq 1 ]]; then
          log "WARN" "Fallo instalando Flatpak $app. Continuando..."
          echo "$app" >> "$LOG_DIR/failed-flatpaks.log"
        else
          log "ERROR" "Fallo instalando Flatpak $app. Abortando."
          exit 1
        fi
      fi
    done < "$REPO_DIR/manifest/flatpaks.txt"
    log "OK" "Flatpaks procesados."
  fi
}

# Deduplicar paquetes (tolerante)
dedup_packages() {
  log "INFO" "Deduplicando paquetes..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se deduplicarían paquetes redundantes."
  else
    if ! pacman -Qdtq | xargs -r pacman -Rns --noconfirm; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "Fallo deduplicando. Continuando..."
      else
        log "ERROR" "Fallo deduplicando. Abortando."
        exit 1
      fi
    else
      log "OK" "Paquetes redundantes eliminados."
    fi
  fi
}
