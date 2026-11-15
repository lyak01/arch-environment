#!/usr/bin/env bash
# =============================================================
#  install.sh - Instalación en dos fases: repos oficiales y AUR
#  Fase 1: pacman (sudo) — incluye garantía de yay
#  Fase 2: yay/AUR (sin sudo, como usuario real)
# =============================================================

# Normaliza paquetes problemáticos conocidos
normalize_package() {
  local p="$1"
  case "$p" in
    ffmpeg7.1) echo "ffmpeg" ;;
    pulseeffects) echo "easyeffects" ;;
    gwe) echo "" ;;
    *) echo "$p" ;;
  esac
}

# Construye caché de paquetes y grupos de repos oficiales
build_repo_cache() {
  REPO_CACHE_FILE="$LOG_DIR/repo-cache.txt"
  if [[ ! -f "$REPO_CACHE_FILE" ]]; then
    {
      pacman -Slq 2>/dev/null
      pacman -Sgq 2>/dev/null
    } | sort -u > "$REPO_CACHE_FILE"
  fi
  log "INFO" "Caché de repos construida ($(wc -l < "$REPO_CACHE_FILE") entradas)."
}

is_in_repo() {
  local p="$1"
  grep -qx "$p" "$REPO_CACHE_FILE"
}

split_packages() {
  REPO_PKGS=()
  AUR_PKGS=()
  build_repo_cache
  local p norm
  for p in "${SELECTED_PACKAGES[@]}"; do
    norm="$(normalize_package "$p")"
    [[ -z "$norm" ]] && continue
    if is_in_repo "$norm"; then
      REPO_PKGS+=("$norm")
    else
      AUR_PKGS+=("$norm")
    fi
  done
  log "INFO" "Repos oficiales: ${#REPO_PKGS[@]} paquetes."
  log "INFO" "Candidatos AUR: ${#AUR_PKGS[@]} paquetes."
}

ensure_yay() {
  if command -v yay &>/dev/null; then
    log "OK" "yay ya está instalado."
    return 0
  fi
  log "INFO" "yay no encontrado. Instalando desde repos oficiales..."
  if ! sudo pacman -S --needed --noconfirm yay; then
    log "ERROR" "No se pudo instalar yay. La fase AUR se omitirá."
    return 1
  fi
  log "OK" "yay instalado."
}

install_repo_pkgs() {
  if [[ ${#REPO_PKGS[@]} -eq 0 ]]; then
    log "INFO" "No hay paquetes de repos oficiales pendientes."
    return 0
  fi
  phase_header "FASE 1: PAQUETES DE REPOS OFICIALES (pacman)"
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían con pacman: ${REPO_PKGS[*]}"
    return 0
  fi
  local total=${#REPO_PKGS[@]}
  local done=0
  local p
  for p in "${REPO_PKGS[@]}"; do
    log "INFO" "Instalando (pacman): $p"
    if sudo pacman -S --needed --noconfirm "$p"; then
      echo "$p" >> "$LOG_DIR/installed-packages.log"
    else
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "Fallo instalando $p con pacman. Continuando..."
        echo "$p" >> "$LOG_DIR/failed-packages.log"
      else
        log "ERROR" "Fallo instalando $p. Abortando."
        return 1
      fi
    fi
    done=$((done+1))
    progress_bar "$done" "$total" "Repos oficiales"
  done
  log "OK" "Fase 1 (repos oficiales) completada."
}

install_aur_pkgs() {
  if [[ ${#AUR_PKGS[@]} -eq 0 ]]; then
    log "INFO" "No hay paquetes AUR pendientes."
    return 0
  fi
  phase_header "FASE 2: PAQUETES AUR (yay, sin sudo)"
  if ! ensure_yay; then
    if [[ $TOLERANT -eq 1 ]]; then
      log "WARN" "Omitiendo fase AUR por falta de yay."
      return 0
    fi
    return 1
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían con yay (como usuario ${SUDO_USER:-$USER}): ${AUR_PKGS[*]}"
    return 0
  fi
  local total=${#AUR_PKGS[@]}
  local done=0
  local p
  for p in "${AUR_PKGS[@]}"; do
    log "INFO" "Instalando (AUR/yay): $p"
    if sudo -u "${SUDO_USER:-$USER}" env HOME="/home/${SUDO_USER:-$USER}" yay -S --needed --noconfirm "$p"; then
      echo "$p" >> "$LOG_DIR/installed-aur.log"
    else
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "Fallo instalando $p con yay. Continuando..."
        echo "$p" >> "$LOG_DIR/failed-aur.log"
      else
        log "ERROR" "Fallo instalando $p. Abortando."
        return 1
      fi
    fi
    done=$((done+1))
    progress_bar "$done" "$total" "AUR"
  done
  log "OK" "Fase 2 (AUR) completada."
}

install_selected() {
  if [[ ${#SELECTED_PACKAGES[@]} -eq 0 ]]; then
    log "INFO" "No hay paquetes seleccionados. Saltando instalación."
    return 0
  fi
  phase_header "PREPARANDO INSTALACIÓN DE PAQUETES"
  split_packages
  if [[ $DRY_RUN -eq 0 ]]; then
    if ! resume_if_done "packages-repos"; then
      install_repo_pkgs
      mark_phase_done "packages-repos"
    fi
    if ! resume_if_done "packages-aur"; then
      install_aur_pkgs
      mark_phase_done "packages-aur"
    fi
  else
    install_repo_pkgs
    install_aur_pkgs
  fi
  mark_phase_done "packages"
  log "OK" "Instalación de paquetes completada (repos + AUR)."
}

install_flatpaks() {
  local f="$REPO_DIR/manifests/flatpaks.txt"
  if [[ ! -f "$f" ]]; then
    log "INFO" "No se encontró manifests/flatpaks.txt. Saltando Flatpaks."
    return 0
  fi
  local -a apps=()
  local app
  while IFS= read -r app; do
    if [[ -z "$app" || "$app" == \#* ]]; then
      continue
    fi
    apps+=("$app")
  done < "$f"
  if [[ ${#apps[@]} -eq 0 ]]; then
    log "INFO" "No hay Flatpaks listados. Saltando Flatpaks."
    return 0
  fi
  ask_multiselect "Flatpaks disponibles (opcional):" "${apps[@]}"
  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    log "INFO" "No se seleccionaron Flatpaks. Saltando Flatpaks."
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían los Flatpaks: ${SELECTED[*]}"
    return 0
  fi
  local a
  for a in "${SELECTED[@]}"; do
    if ! flatpak install -y "$a"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "Fallo instalando Flatpak $a. Continuando..."
        echo "$a" >> "$LOG_DIR/failed-flatpaks.log"
      else
        log "ERROR" "Fallo instalando Flatpak $a. Abortando."
        return 1
      fi
    else
      echo "$a" >> "$LOG_DIR/flatpaks-installed.log"
    fi
  done
  mark_phase_done "flatpaks"
  log "OK" "Flatpaks procesados."
}

dedup_packages() {
  if ! ask_yes_no "¿Deduplicar paquetes huérfanos?"; then
    log "INFO" "Deduplicación omitida por el usuario."
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se deduplicarían paquetes huérfanos."
    return 0
  fi
  if ! pacman -Qdtq | xargs -r pacman -Rns --noconfirm; then
    if [[ $TOLERANT -eq 1 ]]; then
      log "WARN" "Fallo deduplicando. Continuando..."
    else
      log "ERROR" "Fallo deduplicando. Abortando."
      return 1
    fi
  else
    mark_phase_done "dedup"
    log "OK" "Paquetes huérfanos eliminados."
  fi
}
