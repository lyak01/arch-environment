# Reporte de diagnóstico final

El Zynith Reconstructor genera al terminar un reporte en `/var/log/arch-reconstructor/report-<fecha>.txt` con:

- Suites seleccionadas
- Paquetes seleccionados
- Paquetes instalados
- Paquetes que fallaron
- Flatpaks instalados
- Temas / dotfiles / scripts importados
- Sugerencias disponibles

## Principio de seguridad

El programa **no modifica `systemctl` ni init systems** por seguridad. Las sugerencias son solo informativas; el usuario decide si actúa.

## Ejecución recomendada

```bash
sudo bash bootstrap.sh --dry-run --tolerant --fresh
```

Para ejecución real:

```bash
sudo bash bootstrap.sh --tolerant --fresh
```
