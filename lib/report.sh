#!/usr/bin/env bash
# report.sh - Diagnóstico final: cambios y sugerencias

generate_report() {
  local report="$LOG_DIR/report-$(date +%Y%m%d-%H%M%S).txt"
  {
    echo "=== DIAGNÓSTICO FINAL - Zynith Reconstructor ==="
    echo "Fecha: $(date)"
    echo
    echo "--- Suites seleccionadas ---"
    if [[ ${#SELECTED_SUITES[@]} -gt 0 ]]; then
      printf ' - %s\n' "${SELECTED_SUITES[@]}"
    else
      echo "(ninguna)"
    fi
    echo
    echo "--- Paquetes seleccionados ---"
    if [[ ${#SELECTED_PACKAGES[@]} -gt 0 ]]; then
      printf ' - %s\n' "${SELECTED_PACKAGES[@]}"
    else
      echo "(ninguno)"
    fi
    echo
    echo "--- Paquetes instalados ---"
    if [[ -f "$LOG_DIR/installed-packages.log" ]]; then
      cat "$LOG_DIR/installed-packages.log"
    else
      echo "(ninguno)"
    fi
    echo
    echo "--- Paquetes que fallaron ---"
    if [[ -f "$LOG_DIR/failed-packages.log" ]]; then
      cat "$LOG_DIR/failed-packages.log"
    else
      echo "(ninguno)"
    fi
    echo
    echo "--- Flatpaks instalados ---"
    if [[ -f "$LOG_DIR/flatpaks-installed.log" ]]; then
      cat "$LOG_DIR/flatpaks-installed.log"
    else
      echo "(ninguno)"
    fi
    echo
    echo "--- Temas / Dotfiles / Scripts ---"
    local f
    for f in themes-imported.log dotfiles-imported.log scripts-imported.log; do
      if [[ -f "$LOG_DIR/$f" ]]; then
        echo "[$f]"
        cat "$LOG_DIR/$f"
      fi
    done
    echo
    echo "--- Sugerencias disponibles ---"
    if [[ ${#SUGGESTIONS[@]} -gt 0 ]]; then
      printf ' - %s\n' "${SUGGESTIONS[@]}"
    else
      echo "(ninguna)"
    fi
    echo
    echo "Este programa no modifica systemctl ni init systems por seguridad."
  } > "$report"
  log "OK" "Reporte generado: $report"
}
