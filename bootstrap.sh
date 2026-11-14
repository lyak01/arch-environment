#!/usr/bin/env bash
# bootstrap.sh - Esqueleto del asistente CLI para arch-environment

set -euo pipefail

printf '=== ARCH RECONSTRUCTOR ===\n'
printf 'Este es un esqueleto inicial. La lógica de instalación aún no está implementada.\n'

# Detección básica (a completar)
printf '\n[1/8] Detectando sistema...\n'
printf 'Distro: %s\n' "$(. /etc/os-release && echo "$PRETTY_NAME")"
printf 'Kernel: %s\n' "$(uname -r)"

printf '\n[2/8] Selección de entorno gráfico (pendiente)\n'
printf '[3/8] Servidor gráfico (pendiente)\n'
printf '[4/8] Audio (pendiente)\n'
printf '[5/8] Navegador principal (pendiente)\n'
printf '[6/8] Gaming (pendiente)\n'
printf '[7/8] Temas y personalización (pendiente)\n'
printf '[8/8] Resumen y confirmación final (pendiente)\n'

printf '\nFin del esqueleto.\n'
