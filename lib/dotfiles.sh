#!/usr/bin/env bash
# dotfiles.sh - Importación de dotfiles bajo demanda

import_dotfiles() {
  if [[ $IMPORT_DOTFILES -ne 1 || -z "$DOTFILES_URL" ]]; then
    return 0
  fi
  local tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  if [[ $DRY_RUN -eq 1 ]]; then
    log "INFO" "[DRY-RUN] Se clonaría $DOTFILES_URL e importarían dotfiles."
    return 0
  fi

  if ! git clone --depth 1 "$DOTFILES_URL" "$tmp/dotfiles"; then
    log "ERROR" "No se pudo clonar $DOTFILES_URL"
    return 1
  fi

  local src="$tmp/dotfiles"

  # Rutas seguras
  for d in xfce4 Thunar kitty fastfetch htop mpv gtk-3.0 gtk-2.0; do
    if [ -d "$src/.config/$d" ]; then
      mkdir -p ~/.config
      cp -r "$src/.config/$d" ~/.config/
      log "OK" "Dotfile $d importado"
    fi
  done
  for f in starship.toml mimeapps.list user-dirs.dirs; do
    if [ -f "$src/.config/$f" ]; then
      mkdir -p ~/.config
      cp "$src/.config/$f" ~/.config/
      log "OK" "Dotfile $f importado"
    fi
  done
  for f in .bashrc .bash_profile .gitconfig; do
    if [ -f "$src/$f" ]; then
      cp "$src/$f" ~/"$f"
      log "OK" "Dotfile $f importado"
    fi
  done

  log "INFO" "Importación de dotfiles finalizada."
}
