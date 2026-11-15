#!/usr/bin/env bash
# themes.sh - Importación de temas Zynith, GRUB, hostname y Plymouth

USER_HOME="/home/${SUDO_USER:-$USER}"

sync_themes() {
  local dir="$USER_HOME/.local/share/zynith-themes"
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
    if ! sudo -u "${SUDO_USER:-$USER}" git clone https://github.com/lyak01/zynith-themes.git "$dir"; then
      if [[ $TOLERANT -eq 1 ]]; then
        log "WARN" "No se pudo clonar zynith-themes. Continuando..."
      else
        log "ERROR" "No se pudo clonar zynith-themes. Abortando."
        return 1
      fi
    fi
  fi
  log "OK" "zynith-themes sincronizado en $dir"
}

import_themes() {
  local src="$USER_HOME/.local/share/zynith-themes"
  if [[ ! -d "$src" ]]; then
    log "ERROR" "No existe $src. Ejecuta sync_themes primero."
    return 1
  fi
  sudo -u "${SUDO_USER:-$USER}" mkdir -p "$USER_HOME/.themes" "$USER_HOME/.icons"
  if [[ -d "$src/gtk" ]]; then
    cp -r "$src/gtk/"* "$USER_HOME/.themes/"
  fi
  if [[ -d "$src/icons" ]]; then
    cp -r "$src/icons/"* "$USER_HOME/.icons/"
  fi
  if [[ -d "$src/cursors" ]]; then
    cp -r "$src/cursors/"* "$USER_HOME/.icons/"
  fi
  echo "GTK, iconos, cursores" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Temas GTK, iconos y cursores importados a $USER_HOME"
}

import_xfwm4() {
  local src="$USER_HOME/.local/share/zynith-themes/xfwm4"
  if [[ -d "$src" ]]; then
    sudo -u "${SUDO_USER:-$USER}" mkdir -p "$USER_HOME/.themes"
    cp -r "$src/"* "$USER_HOME/.themes/"
    echo "xfwm4" >> "$LOG_DIR/themes-imported.log"
    log "OK" "Tema xfwm4 importado."
  else
    log "INFO" "No hay tema xfwm4 Zynith separado; se usará el incluido en los temas GTK."
  fi
}

import_grub() {
  local src="$USER_HOME/.local/share/zynith-themes/grub/zynith"
  if [[ ! -d "$src" ]]; then
    log "WARN" "No se encontró tema GRUB Zynith en el repo. Omitiendo GRUB."
    return 0
  fi
  mkdir -p /boot/grub/themes/zynith
  cp -r "$src/"* /boot/grub/themes/zynith/
  if ! grep -q '^GRUB_THEME=' /etc/default/grub; then
    echo 'GRUB_THEME="/boot/grub/themes/zynith/theme.txt"' >> /etc/default/grub
  else
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/zynith/theme.txt"|' /etc/default/grub
  fi
  if ! grep -q '^GRUB_GFXMODE=' /etc/default/grub; then
    echo 'GRUB_GFXMODE="auto"' >> /etc/default/grub
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "grub zynith" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Tema GRUB Zynith instalado y grub.cfg regenerado."
}

set_hostname() {
  local newname="Zynith"
  if command -v hostnamectl &>/dev/null; then
    hostnamectl set-hostname "$newname"
  else
    echo "$newname" > /etc/hostname
  fi
  echo "hostname $newname" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Hostname cambiado a $newname."
}

# Asegura que el hook plymouth esté en HOOKS de mkinitcpio
ensure_plymouth_hook() {
  local conf="/etc/mkinitcpio.conf"
  if grep -qE '^HOOKS=.*plymouth' "$conf"; then
    log "INFO" "Hook plymouth ya presente en mkinitcpio."
    return 0
  fi
  if grep -q '^HOOKS=' "$conf"; then
    sed -i '/^HOOKS=/s/filesystems/plymouth filesystems/' "$conf"
    log "OK" "Hook plymouth añadido a HOOKS en $conf"
  else
    log "WARN" "No se encontró línea HOOKS en $conf."
    return 1
  fi
}

import_plymouth() {
  local src="$USER_HOME/.local/share/zynith-themes/plymouth/zynith"
  if [[ ! -d "$src" ]]; then
    log "WARN" "No se encontró tema Plymouth Zynith en el repo. Omitiendo Plymouth."
    return 0
  fi
  if ! command -v plymouth-set-default-theme &>/dev/null; then
    log "INFO" "Plymouth no está instalado. Instalando..."
    if ! pacman -S --needed --noconfirm plymouth; then
      log "ERROR" "No se pudo instalar plymouth."
      return 1
    fi
  fi
  mkdir -p /usr/share/plymouth/themes/zynith
  cp -r "$src/"* /usr/share/plymouth/themes/zynith/
  ensure_plymouth_hook
  plymouth-set-default-theme -R zynith
  echo "plymouth zynith" >> "$LOG_DIR/themes-imported.log"
  log "OK" "Plymouth Zynith configurado como predeterminado e initramfs regenerado."
}
