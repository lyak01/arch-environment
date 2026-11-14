#!/usr/bin/env bash
# install.sh - Instalación con prioridad de fuentes

DRY_RUN="${DRY_RUN:-0}"

install_package() {
  local pkg="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    if pacman -Si "$pkg" &>/dev/null; then
      log "INFO" "[DRY-RUN] Se instalaría $pkg desde repositorio oficial."
    elif pacman -Sg "$pkg" &>/dev/null; then
      log "INFO" "[DRY-RUN] Se instalaría $pkg (grupo) desde repositorio oficial."
    elif command -v yay &>/dev/null && yay -Si "$pkg" &>/dev/null; then
      log "INFO" "[DRY-RUN] Se instalaría $pkg desde AUR."
    else
      log "WARN" "[DRY-RUN] $pkg paquete no se encuentra disponible en los mirrors oficiales ni en un binario disponible del AUR, se ha omitido por seguridad, lamentamos este inconveniente y se sugiere modificar/montar el paquete manualmente."
    fi
    return 0
  fi
  if pacman -Si "$pkg" &>/dev/null; then
    if pacman -S --noconfirm "$pkg"; then
      log "OK" "$pkg instalado desde repositorio oficial"
      return 0
    fi
  fi
  if pacman -Sg "$pkg" &>/dev/null; then
    if pacman -S --noconfirm "$pkg"; then
      log "OK" "$pkg (grupo) instalado desde repositorio oficial"
      return 0
    fi
  fi
  if command -v yay &>/dev/null && yay -Si "$pkg" &>/dev/null; then
    if yay -S --noconfirm "$pkg"; then
      log "OK" "$pkg instalado desde AUR"
      return 0
    fi
  fi
  log "WARN" "$pkg paquete no se encuentra disponible en los mirrors oficiales ni en un binario disponible del AUR, se ha omitido por seguridad, lamentamos este inconveniente y se sugiere modificar/montar el paquete manualmente."
  return 1
}

install_flatpak() {
  local app="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    log "INFO" "[DRY-RUN] Se instalaría Flatpak $app."
    return 0
  fi
  if flatpak install -y --noninteractive "$app"; then
    log "OK" "Flatpak $app instalado"
    return 0
  fi
  log "WARN" "Flatpak $app no se pudo instalar."
  return 1
}

install_manifest() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  local pkgs=()
  local flatpaks=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    if [[ "$line" =~ ^flatpak: ]]; then
      flatpaks+=("${line#flatpak:}")
    else
      pkgs+=("$line")
    fi
  done < "$file"
  # Deduplicar
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | sort -u)
  fi
  if [[ ${#flatpaks[@]} -gt 0 ]]; then
    mapfile -t flatpaks < <(printf '%s\n' "${flatpaks[@]}" | sort -u)
  fi
  for pkg in "${pkgs[@]}"; do
    install_package "$pkg" || true
  done
  for app in "${flatpaks[@]}"; do
    install_flatpak "$app" || true
  done
}

install_selected() {
  local manifest_dir="$SCRIPT_DIR/manifests"
  if [[ $PROFILE_BASE -eq 1 ]]; then
    install_manifest "$manifest_dir/base.txt"
  fi
  case "$DE" in
    xfce) install_manifest "$manifest_dir/desktop-xfce.txt" ;;
    kde) install_manifest "$manifest_dir/desktop-kde.txt" ;;
    gnome) install_manifest "$manifest_dir/desktop-gnome.txt" ;;
    hyprland) install_manifest "$manifest_dir/desktop-hyprland.txt" ;;
    i3) install_manifest "$manifest_dir/desktop-i3.txt" ;;
    none) ;;
  esac
  case "$AUDIO_CHOICE" in
    pulse) install_manifest "$manifest_dir/audio-production.txt" ;;
  esac
  case "$BROWSER" in
    brave) install_manifest "$manifest_dir/browsers.txt" ;;
  esac
  if [[ $INSTALL_SUITES -eq 1 ]]; then
    for f in "$manifest_dir"/terminal.txt "$manifest_dir"/network.txt "$manifest_dir"/music-playback.txt "$manifest_dir"/video-editing.txt "$manifest_dir"/design-art.txt "$manifest_dir"/office.txt "$manifest_dir"/development.txt "$manifest_dir"/android.txt "$manifest_dir"/security-networking.txt "$manifest_dir"/virtualization.txt "$manifest_dir"/gaming-core.txt "$manifest_dir"/misc-system.txt; do
      install_manifest "$f"
    done
  fi
}

finalize() {
  log "INFO" "Instalación finalizada. Revisa el log en $LOG_FILE"
}
