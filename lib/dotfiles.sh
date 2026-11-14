#!/usr/bin/env bash
# dotfiles.sh - Importación de dotfiles y scripts personales (solo si el usuario aprueba)

import_dotfiles() {
  local dir="$HOME/.local/share/arch-dotfiles"
  if [[ -d "$dir/.git" ]]; then
    if ! git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar arch-dotfiles. Continuando..."
      else
        log "ERROR" "No se pudo actualizar arch-dotfiles. Abortando."
        return 1
      fi
    fi
  else
    if ! git clone https://github.com/lyak01/arch-dotfiles.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar arch-dotfiles. Continuando..."
      else
        log "ERROR" "No se pudo clonar arch-dotfiles. Abortando."
        return 1
      fi
    fi
  fi
  if [[ -d "$dir/.config" ]]; then
    mkdir -p "$HOME/.config"
    cp -r "$dir/.config/"* "$HOME/.config/" 2>/dev/null || true
  fi
  local f
  for f in .bashrc .bash_profile .gitconfig; do
    if [[ -f "$dir/$f" ]]; then
      cp "$dir/$f" "$HOME/$f"
    fi
  done
  echo "dotfiles importados" >> "$LOG_DIR/dotfiles-imported.log"
  mark_phase_done "dotfiles"
  log "OK" "Dotfiles importados."
}

import_scripts() {
  local dir="$HOME/.local/share/personal-scripts"
  if [[ -d "$dir/.git" ]]; then
    if ! git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar personal-scripts. Continuando..."
      else
        log "ERROR" "No se pudo actualizar personal-scripts. Abortando."
        return 1
      fi
    fi
  else
    if ! git clone https://github.com/lyak01/personal-scripts.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar personal-scripts. Continuando..."
      else
        log "ERROR" "No se pudo clonar personal-scripts. Abortando."
        return 1
      fi
    fi
  fi
  mkdir -p "$HOME/.local/bin"
  if command -v find &>/dev/null; then
    find "$dir" -maxdepth 1 -type f -executable -exec cp {} "$HOME/.local/bin/" \; 2>/dev/null || true
  fi
  echo "scripts importados" >> "$LOG_DIR/scripts-imported.log"
  mark_phase_done "scripts"
  log "OK" "Scripts importados."
}
