#!/usr/bin/env bash
# dotfiles.sh - Importación de dotfiles y scripts personales (solo si el usuario aprueba)

USER_HOME="/home/${SUDO_USER:-$USER}"

# Ajustes posteriores a la importación: panel automático y fastfetch Zynith
tune_desktop() {
  # Panel XFCE: quitar salida fija (DP-1) para que sea automática
  if command -v xfconf-query &>/dev/null; then
    if sudo -u "${SUDO_USER:-$USER}" env DISPLAY=:0 xfconf-query -c xfce4-panel -p /panels/panel-1/output-name -r &>/dev/null; then
      log "OK" "Panel XFCE configurado en modo automático."
    else
      log "INFO" "No se encontró salida fija en el panel; se mantiene automático."
    fi
  else
    log "WARN" "xfconf-query no disponible; el panel se ajustará al primer inicio."
  fi

  # Fastfetch: mostrar Zynith como OS si la config lo menciona
  local ff="$USER_HOME/.config/fastfetch/config.jsonc"
  if [[ -f "$ff" ]]; then
    if grep -q 'Arch Linux' "$ff"; then
      sed -i 's/Arch Linux/Zynith/g' "$ff"
      log "OK" "Fastfetch configurado para mostrar Zynith como OS."
    else
      log "INFO" "Fastfetch: no se encontró 'Arch Linux' en la config; se deja tal cual."
    fi
  else
    log "INFO" "No se encontró config de fastfetch; se creará al primer uso."
  fi
}

import_dotfiles() {
  local dir="$USER_HOME/.local/share/arch-dotfiles"
  if [[ -d "$dir/.git" ]]; then
    if ! sudo -u "${SUDO_USER:-$USER}" git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar arch-dotfiles. Continuando..."
      else
        log "ERROR" "No se pudo actualizar arch-dotfiles. Abortando."
        return 1
      fi
    fi
  else
    if ! sudo -u "${SUDO_USER:-$USER}" git clone https://github.com/lyak01/arch-dotfiles.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar arch-dotfiles. Continuando..."
      else
        log "ERROR" "No se pudo clonar arch-dotfiles. Abortando."
        return 1
      fi
    fi
  fi
  if [[ -d "$dir/.config" ]]; then
    sudo -u "${SUDO_USER:-$USER}" mkdir -p "$USER_HOME/.config"
    cp -r "$dir/.config/"* "$USER_HOME/.config/"
  fi
  local f
  for f in .bashrc .bash_profile .gitconfig; do
    if [[ -f "$dir/$f" ]]; then
      cp "$dir/$f" "$USER_HOME/$f"
      chown "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$USER_HOME/$f"
    fi
  done
  tune_desktop
  echo "dotfiles importados" >> "$LOG_DIR/dotfiles-imported.log"
  mark_phase_done "dotfiles"
  log "OK" "Dotfiles importados a $USER_HOME"
}

import_scripts() {
  local dir="$USER_HOME/.local/share/personal-scripts"
  if [[ -d "$dir/.git" ]]; then
    if ! sudo -u "${SUDO_USER:-$USER}" git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar personal-scripts. Continuando..."
      else
        log "ERROR" "No se pudo actualizar personal-scripts. Abortando."
        return 1
      fi
    fi
  else
    if ! sudo -u "${SUDO_USER:-$USER}" git clone https://github.com/lyak01/personal-scripts.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar personal-scripts. Continuando..."
      else
        log "ERROR" "No se pudo clonar personal-scripts. Abortando."
        return 1
      fi
    fi
  fi
  sudo -u "${SUDO_USER:-$USER}" mkdir -p "$USER_HOME/.local/bin"
  if command -v find &>/dev/null; then
    find "$dir" -maxdepth 1 -type f -executable -exec cp {} "$USER_HOME/.local/bin/" \;
  fi
  echo "scripts importados" >> "$LOG_DIR/scripts-imported.log"
  mark_phase_done "scripts"
  log "OK" "Scripts importados a $USER_HOME/.local/bin"
}
