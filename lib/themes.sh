#!/usr/bin/env bash
# themes.sh - Importación de temas desde zynith-themes

import_themes() {
  local repo="https://github.com/lyak01/zynith-themes.git"
  local tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  if [[ $DRY_RUN -eq 1 ]]; then
    log "INFO" "[DRY-RUN] Se clonaría $repo e importarían temas."
    return 0
  fi

  if ! git clone --depth 1 "$repo" "$tmp/zynith-themes"; then
    log "ERROR" "No se pudo clonar $repo"
    return 1
  fi

  local src="$tmp/zynith-themes"

  # GTK themes
  if [ -d "$src/gtk" ]; then
    mkdir -p ~/.themes
    cp -r "$src/gtk/"* ~/.themes/ 2>/dev/null || true
    log "OK" "Temas GTK importados"
  else
    log "WARN" "No se encontró gtk/ en el repo"
  fi

  # xfwm4 themes
  if [ -d "$src/xfwm4" ]; then
    mkdir -p /usr/share/themes
    cp -r "$src/xfwm4/"* /usr/share/themes/ 2>/dev/null || true
    log "OK" "Temas xfwm4 importados"
  else
    log "WARN" "No se encontró xfwm4/ en el repo"
  fi

  # Iconos
  if [ -d "$src/icons" ]; then
    mkdir -p ~/.icons
    cp -r "$src/icons/"* ~/.icons/ 2>/dev/null || true
    log "OK" "Iconos importados"
  else
    log "WARN" "No se encontró icons/ en el repo"
  fi

  # Cursores
  if [ -d "$src/cursors" ]; then
    mkdir -p ~/.icons
    cp -r "$src/cursors/"* ~/.icons/ 2>/dev/null || true
    log "OK" "Cursores importados"
  else
    log "WARN" "No se encontró cursors/ en el repo"
  fi

  # Plymouth
  if [ -d "$src/plymouth" ]; then
    mkdir -p /usr/share/plymouth/themes
    cp -r "$src/plymouth/"* /usr/share/plymouth/themes/ 2>/dev/null || true
    log "OK" "Plymouth importado"
  else
    log "WARN" "No se encontró plymouth/ en el repo"
  fi

  log "INFO" "Importación de temas finalizada."
}
