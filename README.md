# Zynith Reconstructor

Reconstructor interactivo, selectivo y seguro de un entorno Arch Linux personalizado (Zynith).

- Detecta distro, kernel, GPU, audio y entorno existente.
- Permite elegir u omitir suites y variantes de escritorio.
- Selección múltiple de paquetes core/recomendados/opcionales y sugerencias personalizadas.
- No instala nada por defecto: todo requiere confirmación explícita.
- Instalación en dos fases: repos oficiales (pacman/sudo) y AUR (yay como usuario real, sin sudo interno).
- Dry-run, tolerancia a fallos, checkpoints y reporte final.
- Importación de temas Zynith, GRUB, hostname y Plymouth (opcional, con confirmación).
- Importación de dotfiles y scripts personales (opcional).
- Ajustes posteriores: panel XFCE automático y Fastfetch mostrando “Zynith”.
- No manipula servicios/init (`systemctl`/`runit`) por seguridad.

## Requisitos

- Arch Linux (o derivada compatible con pacman).
- `git` y `sudo`.
- Conexión a internet.
- Para AUR: `yay` (se instala automáticamente en la Fase 1 si falta).

## Instalación rápida

```bash
git clone https://github.com/lyak01/arch-environment.git
cd arch-environment
```

## Ejecución (dry-run)

```bash
sudo bash bootstrap.sh --dry-run --tolerant --fresh
```

- `--dry-run`: simula todo sin instalar ni modificar nada.
- `--tolerant`: si un paquete falla, lo registra y continúa.
- `--fresh`: limpia estado y logs previos para una corrida limpia.

## Ejecución real

```bash
sudo bash bootstrap.sh --tolerant --fresh
```

Durante la ejecución se te pedirá:

1. Seleccionar suites (`a` = todas, `n` = ninguna, o números separados por espacio/coma).
2. Elegir variante de escritorio (xfce/kde/gnome/hyprland/i3/none).
3. Confirmar reemplazo del entorno existente (si aplica) escribiendo `SI`.
4. Elegir paquetes core (`s`/`N`) y recomendados/opcionales (multiselección, `a` = todos, `n` = ninguno).
5. Confirmar la instalación final escribiendo `SI`.
6. Decidir si importas temas Zynith + GRUB + hostname + Plymouth.
7. Decidir si importas dotfiles y scripts personales.

## Fases de instalación

### Fase 1 — Repos oficiales (pacman)

- Clasifica automáticamente los paquetes seleccionados usando una caché de paquetes y grupos (`pacman -Slq` + `pacman -Sgq`).
- Instala con `sudo pacman -S --needed --noconfirm`.
- Garantiza que `yay` esté instalado (lo instala desde repos si falta).
-行行行行 Checkpoint: `packages-repos`.

### Fase 2 — AUR (yay, sin sudo)

- Instala los paquetes que solo existen en AUR usando `yay` como el usuario real (`SUDO_USER`), sin sudo interno.
- Evita el error `Running makepkg as root is not allowed`.
- Checkpoint: `packages-aur`.

## Normalización automática

Antes de instalar, el programa normaliza paquetes problemáticos:

- `ffmpeg7.1` → `ffmpeg` (repos).
- `pulseeffects` → `easyeffects` (repos).
- `gwe` → se descarta si la GPU no es NVIDIA.

## Temas, GRUB, hostname y Plymouth

Si aceptas la fase de temas, el programa:

1. Clona/actualiza `lyak01/zynith-themes` en `~/.local/share/zynith-themes` (como tu usuario).
2. Copia temas GTK, iconos y cursores a `~/.themes` y `~/.icons`.
3. Copia el tema GRUB a `/boot/grub/themes/zynith`, configura `GRUB_THEME` y regenera `grub.cfg`.
4. Cambia el hostname a `Zynith`.
5. Instala Plymouth si falta, copia el tema y lo establece como predeterminado.
6. Asegura que el hook `plymouth` esté en `HOOKS` de `/etc/mkinitcpio.conf` y regenera el initramfs.

## Dotfiles y ajustes finales

Si aceptas importar dotfiles:

1. Clona/actualiza `lyak01/arch-dotfiles` en `~/.local/share/arch-dotfiles` (como tu usuario).
2. Copia `.config/`, `.bashrc`, `.bash_profile` y `.gitconfig` a tu home.
3. Ajusta el panel XFCE a modo automático (elimina salida fija tipo `DP-1`).
4. Configura Fastfetch para mostrar “Zynith” como OS (si la config lo permite).

## Logs y reporte

- Logs en `/var/log/arch-reconstructor/`:
  - `install-<fecha>.log` — log completo de la corrida.
  - `installed-packages.log` / `failed-packages.log` — repos oficiales.
  - `installed-aur.log` / `failed-aur.log` — AUR.
  - `themes-imported.log`, `dotfiles-imported.log`, `scripts-imported.log`.
  - `report-<fecha>.txt` — reporte final.
- Con `--fresh`, los logs de corridas anteriores se eliminan para que el reporte refleje solo la corrida actual.

## Mensaje final

Al terminar, el programa muestra:

- La ruta del reporte generado.
- Un resumen de paquetes que no se pudieron construir/montar (si aplica), con posibles causas (mirrors, repos, actualizaciones, dependencias, compatibilidad) y recomendación de instalación manual.
- El mensaje: **“Disfruta Zynith Distro :) -lyak01”**.

## Solución de problemas

- **`pacman db.lck`**: asegúrate de que no haya otra transacción de pacman/yay en curso antes de eliminar el lock.
- **AUR falla con “makepkg as root”**: el programa ya ejecuta AUR como usuario real; si ves ese error, reporta el log.
- **Plymouth no aparece en mkinitcpio**: el programa ahora inserta el hook `plymouth` en `HOOKS` y regenera el initramfs.
- **Panel no aparece**: el programa resetea la salida fija del panel para que sea automática.

## Seguridad

- No se manipulan servicios ni sistemas de init (`systemctl`/`runit`).
- Toda acción destructiva (desinstalar entorno previo, instalar paquetes, cambiar GRUB/hostname/Plymouth) requiere confirmación explícita.
- El dry-run no modifica nada.

## Créditos

Diseño y desarrollo: **lyak01** — Zynith Distro.
