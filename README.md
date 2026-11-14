# Zynith Reconstructor

> **Reconstruye un entorno Arch Linux completo con mínima intervención.**

Zynith Reconstructor es un script Bash modular que instala paquetes, importa temas, dotfiles y scripts personales, y genera un reporte de diagnóstico final. Está diseñado para Arch Linux (y derivados que usen `pacman`).

---

## Características

- Instalación de paquetes desde manifiesto (`manifest/packages.txt`).
- Instalación de Flatpaks desde manifiesto (`manifest/flatpaks.txt`).
- Importación de temas desde `zynith-themes` (GTK, iconos, cursores, xfwm4, Plymouth).
- Importación de dotfiles personales desde `arch-dotfiles` (opcional).
- Importación de scripts personales desde `personal-scripts` (opcional).
- Detección de hardware y entorno de escritorio existente.
- Forzar XFCE (desinstala Plasma/GNOME/Hyprland/i3 con doble confirmación).
- Plymouth por defecto tras importarlo.
- Tolerancia a fallos (`--tolerant`): errores se registran y continúa.
- Checkpoint (reanudación): guarda fases completadas y las salta al reejecutar.
- Reporte de diagnóstico final con cambios y sugerencias.
- Logs detallados en `/var/log/arch-reconstructor/`.

---

## Requisitos

- Arch Linux (o derivado con `pacman`).
- `git`, `curl`, `flatpak` instalados.
- Acceso a internet.
- Permisos de `sudo` para instalar paquetes y escribir en `/usr/share/plymouth`.

---

## Estructura del proyecto

```text
arch-environment/
├── bootstrap.sh          # Punto de entrada principal
├── lib/
│   ├── log.sh            # Logging
│   ├── detect.sh         # Detección de hardware/DE
│   ├── install.sh        # Instalación de paquetes/Flatpaks
│   ├── themes.sh         # Importación de temas
│   ├── dotfiles.sh       # Importación de dotfiles/scripts
│   ├── state.sh          # Checkpoint (reanudación)
│   └── report.sh         # Reporte de diagnóstico final
├── manifest/
│   ├── packages.txt      # Paquetes a instalar
│   └── flatpaks.txt      # Flatpaks a instalar
├── docs/
│   ├── REPORT.md         # Explicación del reporte final
│   └── RESUME.md         # Explicación de checkpoint/tolerancia
└── README.md             # Este archivo
```

---

## Ejecutar

### Línea principal (recomendada para primera prueba)

```bash
./bootstrap.sh --dry-run --tolerant
```

Esta línea hace:
- `--dry-run`: no instala nada, solo simula.
- `--tolerant`: si algo falla, lo registra y continúa.

### Ejecución real (instala de verdad)

```bash
./bootstrap.sh --tolerant
```

### Flags disponibles

| Flag | Descripción |
|---|---|
| `--dry-run` | Simula la instalación sin hacer cambios reales. |
| `--tolerant` | Errores se registran como `WARN` y el script continúa. |
| (sin flags) | Comportamiento estricto: cualquier error aborta. |

---

## Flujo de ejecución

1. Detecta hardware y entorno de escritorio existente.
2. Pregunta si forzar XFCE (si hay otro DE).
3. Instala paquetes del manifiesto.
4. Instala Flatpaks del manifiesto.
5. Deduplica paquetes redundantes.
6. (Solo si no es dry-run) Fuerza XFCE si se confirmó.
7. Sincroniza e importa temas desde `zynith-themes`.
8. Configura Plymouth como predeterminado.
9. Pregunta si importar dotfiles personales.
10. Pregunta si importar scripts personales.
11. Genera reporte de diagnóstico final.

---

## Logs y reportes

Todo se registra en `/var/log/arch-reconstructor/`:

- `install-<fecha>.log` — log general.
- `installed-packages.log` — paquetes instalados.
- `failed-packages.log` — paquetes que fallaron (solo con `--tolerant`).
- `failed-flatpaks.log` — Flatpaks que fallaron (solo con `--tolerant`).
- `themes-imported.log` — temas importados.
- `dotfiles-imported.log` — dotfiles importados.
- `scripts-imported.log` — scripts importados.
- `state.json` — checkpoint (fases completadas).
- `report-<fecha>.txt` — reporte de diagnóstico final.

---

## Seguridad

- El programa **no modifica `systemctl` ni init systems** por seguridad.
- Las sugerencias del reporte son solo informativas; el usuario decide si actúa.
- Forzar XFCE requiere doble confirmación explícita.

---

## FAQ

**¿Puedo usarlo en Debian/Ubuntu/Fedora?**
No por ahora. El soporte multi-distro está descartado para el plazo inmediato/mediano.

**¿Qué pasa si un paquete no existe?**
Con `--tolerant`, se registra como `WARN` y continúa. Sin `--tolerant`, aborta.

**¿Puedo reanudar una instalación interrumpida?**
Sí. El checkpoint guarda fases completadas y las salta al reejecutar.

**¿Dónde veo qué falló?**
En el reporte final (`report-<fecha>.txt`) y en los logs `failed-*.log`.

---

## Créditos

- Zynith Reconstructor: diseño e implementación (Lyak).
- zynith-themes: temas GTK, iconos, cursores, xfwm4, Plymouth (Lyak).
- arch-dotfiles: dotfiles personales (Lyak).
- personal-scripts: scripts personales (Lyak).
