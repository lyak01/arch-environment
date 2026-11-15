#!/usr/bin/env bash
# dotfiles.sh - Importación de dotfiles y scripts personales (solo si el usuario aprueba)

USER_HOME="/home/${SUDO_USER:-$USER}"

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
