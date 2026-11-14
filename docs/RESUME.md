# Reanudación y tolerancia a fallos

## Modo tolerante (`--tolerant`)

Si un paquete, Flatpak o `git clone` falla, el script lo registra como `WARN` y continúa con el resto. Al final, el reporte lista los fallos para que decidas qué reintentar.

Sin `--tolerant`, cualquier error aborta el proceso (comportamiento estricto, útil para primera instalación controlada).

## Checkpoint (reanudación)

El script guarda el estado de fases completadas en `/var/log/arch-reconstructor/state.json`. Si vuelves a ejecutar, salta las fases ya completadas.

### Fases trackeadas

- packages
- flatpaks
- dedup
- themes
- dotfiles
- scripts

### Ejemplo de `state.json`

```json
{
  "fases_completadas": ["packages", "flatpaks", "themes"]
}
```

## Nota importante

El checkpoint es **por fase**, no por paquete individual. Si una fase falla a medias, se reintentará completa al reanudar.

## Combinación recomendada

Para la primera prueba, usa:

```bash
./bootstrap.sh --dry-run --tolerant
```

Para ejecución real:

```bash
./bootstrap.sh --tolerant
```
