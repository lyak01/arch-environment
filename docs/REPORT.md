# Reporte de diagnóstico final

El Zynith Reconstructor genera al terminar un reporte en `/var/log/arch-reconstructor/report-<fecha>.txt` con:

- Paquetes instalados
- Temas importados
- Dotfiles importados
- Scripts importados
- Sugerencias de acción (ej. habilitar bluetooth.service)

**Importante:** el programa **no modifica `systemctl` ni init systems** por seguridad. Las sugerencias son solo informativas; el usuario decide si actúa. [file:47]
