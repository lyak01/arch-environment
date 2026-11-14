#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/install.sh
#  Instalación de paquetes y suites (Arch Linux)
#  v2.4.3 - Lee manifests/*.txt (estructura real del repo)
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

# Instalar todos los paquetes de manifests/*.txt (tolerante)
install_all() {
  log "INFO" "Instalando todos los paquetes de manifests/*.txt..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían todos los paquetes de manifests/*.txt."
  else
    for f in "$REPO_DIR"/manifests/*.txt; do
      [[ -f "$f" ]] || continue
      while read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! pacman -S --needed --noconfirm "$pkg"; then
          if [[ $TOLERANT -eq 1 ]]; then
            log "WARN" "Fallo instalando $pkg (desde $f). Continuando..."
            echo "$pkg" >> "$LOG_DIR/failed-packages.log"
          else
            log "ERROR" "Fallo instalando $pkg (desde $f). Abortando."
            exit 1
          fi
        else
          echo "$pkg" >> "$LOG_DIR/installed-packages.log"
        fi
      done < "$f"
    done
    log "OK" "Paquetes de manifests/*.txt procesados."
  fi
}

# Instalar Flatpaks (tolerante) - usa manifests/flatpaks.txt si existe, si no, nada
install_flatpaks() {
  local flatpak_file="$REPO_DIR/manifests/flatpaks.txt"
  if [[ ! -f "$flatpak_file" ]]; then
    log "INFO" "No se encontró manifests/flatpaks.txt. Saltando Flatpaks."
    return 0
  fi
  log "INFO" "Instalando Flatpaks..."
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían los Flatpaks de manifests/flatpaks.txt."
  else
    while read -r app; do
      [[ -z "$app" || "$app" == \#* ]] && continue
      if ! flatpak install -y "$app"; then
        if [[ $TOLERANT -eq 1 ]]; then
          log "WARN" "Fallo instalando Flatpak $app. Continuando..."
          echo "$app" >> "$LOG_DIR/failed-flatpaks.log"
        else
          log "ERROR" "Fallo instalando Flatpak $app. Abortando."
          exit 1
        fi
      fi
    done < "$flatpak_file"
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
