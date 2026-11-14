#!/usr/bin/env bash
# ask.sh - Preguntas del asistente

confirm() {
  local q="$1"
  read -rp "$q (s/n): " ans
  [[ "$ans" =~ ^[sS]$ ]]
}

ask_profile() {
  if confirm "¿Aplicar perfil base?"; then
    PROFILE_BASE=1
  else
    PROFILE_BASE=0
  fi
}

ask_desktop() {
  read -rp "¿Qué entorno gráfico deseas? (xfce/kde/gnome/hyprland/i3/none): " DE
  DE="${DE:-none}"
  log "INFO" "Entorno seleccionado: $DE"
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

show_summary() {
  log "INFO" "Resumen:"
  log "INFO" "Perfil base: $PROFILE_BASE"
  log "INFO" "Entorno: $DE"
  log "INFO" "Audio: $AUDIO_CHOICE"
  log "INFO" "Navegador: $BROWSER"
  log "INFO" "Suites: $INSTALL_SUITES"
  log "INFO" "Temas: $APPLY_THEMES"
}
