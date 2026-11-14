# Reporte de diagnóstico final

El Zynith Reconstructor genera al terminar un reporte en `/var/log/arch-reconstructor/report-<fecha>.txt` con:

- Paquetes instalados
- Temas importados
- Dotfiles importados
- Scripts importados
- Sugerencias de acción (ej. habilitar bluetooth.service)
- Fallos registrados (solo con `--tolerant`)

## Ejemplo de reporte

```text
=== DIAGNÓSTICO FINAL - Zynith Reconstructor ===
Fecha: 2026-11-14 13:00:00

--- Paquetes instalados ---
base
linux-lts
networkmanager
bluez

--- Temas importados ---
Zynith-GTK
iconos
cursor
Plymouth

--- Dotfiles importados ---
xfce4
kitty
bashrc
gitconfig

--- Scripts importados ---
midi-mode
obs-gpu

--- Sugerencias ---
- Se instaló bluez: se recomienda habilitar bluetooth.service.
- Se instaló NetworkManager: se recomienda habilitar NetworkManager.service.
- Se importó Plymouth: ya está configurado como predeterminado.

Este programa no modifica systemctl ni init systems por seguridad.
Revisa las sugerencias y actúa manualmente si lo deseas.
```

## Nota de seguridad

El programa **no modifica `systemctl` ni init systems** por seguridad. Las sugerencias son solo informativas; el usuario decide si actúa.
