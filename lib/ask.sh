#!/usr/bin/env bash
# ask.sh - Preguntas del asistente

confirm() {
  local q="$1"
  read -rp "$q (s/n): " ans
  [[ "$ans" =~ ^[sS]$ ]]
}

ask_yes_no() {
  local q="$1"
  local ans
  read -rp "$q (s/N): " ans
  [[ "$ans" =~ ^[sS]$ ]]
}

ask_profile() {
  if confirm "¿Aplicar perfil base?"; then
    PROFILE_BASE=1
  else
    PROFILE_BASE=0
  fi
}

detect_existing_de() {
  for de in plasma gnome hyprland i3-wm; do
    if pacman -Q "$de" &>/dev/null; then
      echo "$de"
      return 0
    fi
  done
  echo "none"
}

ask_desktop() {
  read -rp "¿Qué entorno gráfico deseas? (xfce/kde/gnome/hyprland/i3/none): " DE
  DE="${DE:-none}"
  log "INFO" "Entorno seleccionado: $DE"
  if [[ "$DE" == "xfce" ]]; then
    EXISTING=$(detect_existing_de)
    if [[ "$EXISTING" != "none" && "$EXISTING" != "xfce" ]]; then
      log "INFO" "Detectado: $EXISTING"
      if confirm "¿Deseas forzar XFCE y retirar $EXISTING?"; then
        if confirm "Esta acción desinstalará paquetes de $EXISTING. ¿Confirmas?"; then
          FORCE_XFCE=1
          log "INFO" "Forzar XFCE activado."
        else
          FORCE_XFCE=0
          log "INFO" "Forzar XFCE cancelado."
        fi
      else
        FORCE_XFCE=0
      fi
    else
      FORCE_XFCE=0
    fi
  else
    FORCE_XFCE=0
  fi
}

ask_audio() {
  read -rp "¿Qué servidor de audio? (pulse/pipewire/none): " AUDIO_CHOICE
  AUDIO_CHOICE="${AUDIO_CHOICE:-pulse}"
  log "INFO" "Audio seleccionado: $AUDIO_CHOICE"
}

ask_browser() {
  read -rp "¿Navegador principal? (brave/firefox/chromium/none): " BROWSER
  BROWSER="${BROWSER:-brave}"
  log "INFO" "Navegador seleccionado: $BROWSER"
}

ask_suites() {
  if confirm "¿Instalar suites opcionales?"; then
    INSTALL_SUITES=1
  else
    INSTALL_SUITES=0
  fi
}

ask_themes() {
  if confirm "¿Aplicar temas y personalización?"; then
    APPLY_THEMES=1
  else
    APPLY_THEMES=0
  fi
}

ask_dotfiles() {
  if confirm "¿Deseas importar dotfiles desde un repositorio?"; then
    read -rp "URL del repositorio de dotfiles: " DOTFILES_URL
    IMPORT_DOTFILES=1
  else
    IMPORT_DOTFILES=0
    DOTFILES_URL=""
  fi
}

ask_scripts() {
  if confirm "¿Deseas importar scripts y programas personalizados?"; then
    read -rp "URL del repositorio de scripts: " SCRIPTS_URL
    IMPORT_SCRIPTS=1
  else
    IMPORT_SCRIPTS=0
    SCRIPTS_URL=""
  fi
}

show_summary() {
  log "INFO" "Resumen:"
  log "INFO" "Perfil base: $PROFILE_BASE"
  log "INFO" "Entorno: $DE"
  log "INFO" "Forzar XFCE: $FORCE_XFCE"
  log "INFO" "Audio: $AUDIO_CHOICE"
  log "INFO" "Navegador: $BROWSER"
  log "INFO" "Suites: $INSTALL_SUITES"
  log "INFO" "Temas: $APPLY_THEMES"
  log "INFO" "Dotfiles: $IMPORT_DOTFILES"
  log "INFO" "Scripts: $IMPORT_SCRIPTS"
}
