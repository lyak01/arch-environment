# Reanudación y tolerancia a fallos

## Principio rector

**Nada se instala, importa o modifica sin confirmación explícita del usuario.**

- Todas las suites son omitibles.
- Todos los paquetes (core, recomendados, opcionales) requieren confirmación.
- Las sugerencias son solo propuestas; nunca se instalan automáticamente.
- Temas, dotfiles y scripts siempre preguntan antes de importarse.

## Modo tolerante (`--tolerant`)

Si un paquete, Flatpak o `git clone` falla, el script lo registra como `WARN` y continúa con el resto. Al final, el reporte lista los fallos.

Sin `--tolerant`, cualquier error aborta el proceso.

## Checkpoint (reanudación)

El script guarda fases completadas en `/var/log/arch-reconstructor/state.json`. Usa `--fresh` para ignorar/resetear el estado previo.

Fases trackeadas:
- packages
- flatpaks
- dedup
- themes
- dotfiles
- scripts

## Comandos recomendados

Primera prueba (dry-run limpio):

```bash
sudo bash bootstrap.sh --dry-run --tolerant --fresh
```

Ejecución real:

```bash
sudo bash bootstrap.sh --tolerant --fresh
```
