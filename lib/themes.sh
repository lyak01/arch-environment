#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/themes.sh
#  Importación de temas desde zynith-themes
#  v2.4 - Tolerancia a fallos en git
# =============================================================

# Clonar/actualizar zynith-themes (tolerante)
sync_themes() {
  local dir="$HOME/.local/share/zynith-themes"
  if [[ -d "$dir/.git" ]]; then
    if ! git -C "$dir" pull --ff-only; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo actualizar zynith-themes. Continuando..."
      else
        log "ERROR" "No se pudo actualizar zynith-themes. Abortando."
        exit 1
      fi
    fi
  else
    if ! git clone https://github.com/lyak01/zynith-themes.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar zynith-themes. Continuando..."
      else
        log "ERROR" "No se pudo clonar zynith-themes. Abortando."
        exit 1
      fi
    fi
  fi
  log "OK" "zynith-themes sincronizado."
}

# Importar temas GTK, iconos, cursores
import_themes() {
  local src="$HOME/.local/share/zynith-themes"
  mkdir -p ~/.themes ~/.icons
  cp -r "$src/gtk/"* ~/.themes/ 2>/dev/null
  cp -r "$src/icons/"* ~/.icons/ 2>/dev/null
  cp -r "$src/cursors/"* ~/.icons/ 2>/dev/null
  log "OK" "Temas GTK, iconos y cursores importados."
}

# Importar tema xfwm4
import_xfwm4() {
  local src="$HOME/.local/share/zynith-themes/xfwm4"
  mkdir -p ~/.themes
  cp -r "$src/"* ~/.themes/ 2>/dev/null
  log "OK" "Tema xfwm4 importado."
}

# Importar Plymouth y configurarlo como predeterminado
import_plymouth() {
  local src="$HOME/.local/share/zynith-themes/plymouth/zynith"
  if [[ -d "$src" ]]; then
    mkdir -p /usr/share/plymouth/themes/zynith
    cp -r "$src/"* /usr/share/plymouth/themes/zynith/
    if command -v plymouth-set-default-theme &>/dev/null; then
      plymouth-set-default-theme -R zynith
      log "OK" "Plymouth zynith configurado como predeterminado."
    else
      log "WARN" "plymouth-set-default-theme no disponible; instala plymouth primero."
    fi
  else
    log "WARN" "Tema Plymouth zynith no encontrado."
  fi
}
