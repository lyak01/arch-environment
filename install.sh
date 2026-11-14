#!/usr/bin/env bash
# install.sh - Punto de entrada de una sola línea
# Clona el repo en un directorio temporal, ejecuta bootstrap y limpia al salir.

set -euo pipefail

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if ! command -v git &>/dev/null; then
  echo "git no está instalado, instalando..."
  sudo pacman -Sy --noconfirm git
fi

git clone --depth 1 https://github.com/lyak01/arch-environment.git "$TMP/arch-environment"
cd "$TMP/arch-environment"
chmod +x bootstrap.sh
sudo ./bootstrap.sh "$@"
