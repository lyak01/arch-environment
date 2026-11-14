#!/usr/bin/env bash
# scripts.sh - Importación de scripts personales bajo demanda

import_scripts() {
  if [[ $IMPORT_SCRIPTS -ne 1 || -z "$SCRIPTS_URL" ]]; then
    return 0
  fi
  local tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  if [[ $DRY_RUN -eq 1 ]]; then
    log "INFO" "[DRY-RUN] Se clonaría $SCRIPTS_URL e importarían scripts."
    return 0
  fi

  if ! git clone --depth 1 "$SCRIPTS_URL" "$tmp/scripts"; then
    log "ERROR" "No se pudo clonar $SCRIPTS_URL"
    return 1
  fi

  mkdir -p ~/.local/bin
  cp -r "$tmp/scripts/"* ~/.local/bin/ 2>/dev/null || true
  chmod +x ~/.local/bin/* 2>/dev/null || true
  log "OK" "Scripts personales importados"

  log "INFO" "Importación de scripts finalizada."
}
