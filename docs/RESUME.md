# Reanudación y tolerancia a fallos

## Modo tolerante (`--tolerant`)

Si un paquete, Flatpak o `git clone` falla, el script lo registra como `WARN` y continúa con el resto. Al final, el reporte lista los fallos para que decidas qué reintentar.

Sin `--tolerant`, cualquier error aborta el proceso (comportamiento estricto, útil para primera instalación controlada).

## Checkpoint (reanudación)

El script guarda el estado de fases completadas en `/var/log/arch-reconstructor/state.json`. Si vuelves a ejecutar, salta las fases ya completadas.

Fases trackeadas:
- packages
- flatpaks
- dedup
- themes
- dotfiles
- scripts

**Nota:** el checkpoint es por fase, no por paquete individual. Si una fase falla a medias, se reintentará completa al reanudar. [file:53]
