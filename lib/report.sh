#!/usr/bin/env bash
# =============================================================
#  Zynith Reconstructor - lib/report.sh
#  Diagnóstico final: cambios y sugerencias
#  v2.3 - Reporte de seguridad (no toca systemctl)
# =============================================================

# Generar reporte final
generate_report() {
  local report="$LOG_DIR/report-$(date +%Y%m%d-%H%M%S).txt"
  {
    echo "=== DIAGNÓSTICO FINAL - Zynith Reconstructor ==="
    echo "Fecha: $(date)"
    echo
    echo "--- Paquetes instalados ---"
    if [[ -f "$LOG_DIR/installed-packages.log" ]]; then
      cat "$LOG_DIR/installed-packages.log"
    else
      echo "(no se registraron paquetes)"
    fi
    echo
    echo "--- Temas importados ---"
    if [[ -f "$LOG_DIR/themes-imported.log" ]]; then
      cat "$LOG_DIR/themes-imported.log"
    else
      echo "(no se importaron temas)"
    fi
    echo
    echo "--- Dotfiles importados ---"
    if [[ -f "$LOG_DIR/dotfiles-imported.log" ]]; then
      cat "$LOG_DIR/dotfiles-imported.log"
    else
      echo "(no se importaron dotfiles)"
    fi
    echo
    echo "--- Scripts importados ---"
    if [[ -f "$LOG_DIR/scripts-imported.log" ]]; then
      cat "$LOG_DIR/scripts-imported.log"
    else
      echo "(no se importaron scripts)"
    fi
    echo
    echo "--- Sugerencias ---"
    if grep -q "bluez" "$LOG_DIR/installed-packages.log" 2>/dev/null; then
      echo "- Se instaló bluez: se recomienda habilitar bluetooth.service."
    fi
    if grep -q "networkmanager" "$LOG_DIR/installed-packages.log" 2>/dev/null; then
      echo "- Se instaló NetworkManager: se recomienda habilitar NetworkManager.service."
    fi
    if grep -q "plymouth" "$LOG_DIR/installed-packages.log" 2>/dev/null; then
      echo "- Se importó Plymouth: ya está configurado como predeterminado."
    fi
    echo
    echo "Este programa no modifica systemctl ni init systems por seguridad."
    echo "Revisa las sugerencias y actúa manualmente si lo deseas."
  } > "$report"
  log "OK" "Reporte generado: $report"
}
