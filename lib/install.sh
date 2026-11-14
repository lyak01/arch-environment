#!/usr/bin/env bash
# install.sh - Instalación de paquetes seleccionados (tolerante/estricto)

install_selected() {
  if [[ ${#SELECTED_PACKAGES[@]} -eq 0 ]]; then
    log "INFO" "No hay paquetes seleccionados. Saltando instalación."
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY-RUN" "Se instalarían: ${SELECTED_PACKAGES[*]}"
    return 0
  fi
  local pkg
  for pkg in "${SELECTED_PACKAGES[@]}"; do
    if ! pacman -S --needed --noconfirm "$pkg"; then
      if command -v yay &>/dev/null; then
        log "INFO" "Reintentando $pkg con yay (AUR)..."
        if ! yay -S --needed --noconfirm "$pkg"; then
          if [[ $TOLERANT -eq 1 ]]; then
            log "WARN" "Fallo instalando $pkg. Continuando..."
            echo "$pkg" >> "$LOG_DIR/failed-packages.log"
          else
            log "ERROR" "Fallo instalando $pkg. Abortando."
            return 1
          fi
        else
          echo "$pkg" >> "$LOG_DIR/installed-packages.log"
        fi
      else
        if [[ $TOLERANT -eq 1 ]]; then
          log "WARN" "Fallo instalando $pkg. Continuando..."
          echo "$pkg" >> "$LOG_DIR/failed-packages.log"
        else
          log "ERROR" "Fallo instalando $pkg. Abortando."
          return 1
        fi
      fi
    else
      echo "$pkg" >> "$LOG_DIR/installed-packages.log"
    fi
  done
  mark_phase_done "packages"
  log "OK" "Instalación de paquetes completada."
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
    log "INFO" "No hay Flatpaks listados. Saltando."
    return 0
  fi
  ask_multiselect "Flatpaks disponibles (opcional):" "${apps[@]}"
  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    log "INFO" "No se seleccionaron Flatpaks. Saltando."
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
