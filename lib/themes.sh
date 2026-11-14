#!/usr/bin/env bash
# themes.sh - Importación de temas Zynith (solo si el usuario aprueba)

sync_themes() {
  local dir="$HOME/.local/share/zynith-themes"
  if [[ -d "$dir/.git" ]]; then
    if ! git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar zynith-themes. Continuando..."
      else
        log "ERROR" "No se pudo actualizar zynith-themes. Abortando."
        return 1
      fi
    fi
  else
    if ! git clone https://github.com/lyak01/zynith-themes.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar zynith-themes. Continuando..."
      else
        log "ERROR" "No se pudo clonar zynith-themes. Abortando."
        return 1
      fi
    fi
  fi
  log "OK" "zynith-themes sincronizado."
}

import_themes() {
  local src="$HOME/.local/share/zynith-themes"
  mkdir -p "$HOME/.themes" "$HOME/.icons"
  cp -r "$src/gtk/"* "$HOME/.themes/" 2>/dev/null || true
  cp -r "$src/icons/"* "$HOME/.icons/" 2>/dev/null || true
  cp -r "$src/cursors/"* "$HOME/.icons/" 2>/dev/null || true
  echo "GTK, iconos, cursores" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Temas GTK, iconos y cursores importados."
}

import_xfwm4() {
  local src="$HOME/.local/share/zynith-themes/xfwm4"
  mkdir -p "$HOME/.themes"
  cp -r "$src/"* "$HOME/.themes/" 2>/dev/null || true
  echo "xfwm4" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Tema xfwm4 importado."
}

import_plymouth() {
  local src="$HOME/.local/share/zynith-themes/plymouth/zynith"
  if [[ -d "$src" ]]; then
    mkdir -p /usr/share/plymouth/themes/zynith
    cp -r "$src/"* /usr/share/plymouth/themes/zynith/
    if command -v plymouth-set-default-theme &>/dev/null; then
      plymouth-set-default-theme -R zynith
      echo "plymouth zynith" >> "$LOG_DIR/themes-imported.log"
      log "OK" "Plymouth zynith configurado como predeterminado."
    else
      log "WARN" "plymouth-set-default-theme no disponible; instala plymouth primero."
    fi
  else
    log "WARN" "Tema Plymouth zynith no encontrado."
  fi
}
