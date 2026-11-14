# arch-environment

Reconstructor modular de entorno Arch Linux con suites, perfiles y asistente CLI.

## Qué hace

Permite reconstruir un entorno Arch Linux completo desde una instalación base, mediante:

- Detección de hardware, escritorio, audio y gestor de paquetes.
- Asistente CLI con preguntas y confirmaciones.
- Suites modulares por categoría (base, escritorio, navegadores, gaming, desarrollo, etc.).
- Perfiles adaptables por máquina.
- Exclusión de sistema base crítico y secretos.
- Respaldo de paquetes huérfanos mediante repositorios personales.
- Logs detallados y tolerancia a fallos.

## Requisitos mínimos

- Arch Linux (o derivado compatible).
- Conexión a internet.
- Privilegios de sudo o root.
- `git` (el script lo instala si falta).

## Uso rápido

### Opción 1: una sola línea (recomendada)

```bash
curl -fsSL https://raw.githubusercontent.com/lyak01/arch-environment/main/install.sh | sudo bash
```

Esto clona el repo en un directorio temporal, ejecuta el asistente y limpia el temporal al salir.

### Opción 2: clonar y revisar antes

```bash
git clone https://github.com/lyak01/arch-environment.git
cd arch-environment
sudo ./bootstrap.sh
```

En ambos casos, el temporal se limpia automáticamente al terminar.

## Cómo funciona

1. Verifica privilegios (sudo/root).
2. Verifica e instala `git` si falta.
3. Detecta sistema (distro, kernel, gestor de paquetes).
4. Detecta hardware (GPU, audio).
5. Pregunta perfil base, entorno gráfico, audio, navegador.
6. Recorre suites opcionales una por una.
7. Muestra resumen y pide confirmación final.
8. Instala con logs y tolerancia a fallos.
9. Muestra resumen final.

## Suites disponibles

- base
- desktop (xfce | kde | gnome | hyprland | i3 | none)
- terminal
- network
- browsers
- audio-production
- music-playback
- video-editing
- design-art
- office
- development
- android
- security-networking
- virtualization
- gaming
- misc-system

## Reglas de seguridad

- Nunca se copian ni restauran secretos (`.ssh`, `.gnupg`, tokens, contraseñas).
- Nunca se copia el kernel, initramfs, GRUB, usuarios o configuración de red.
- Los drivers propietarios (NVIDIA, CUDA, Oxyglow) quedan fuera de los manifiestos comunes y se instalan solo con confirmación explícita.
- Los respaldos personales (OBS, CUDA, Oxyglow) permanecen en repositorios privados separados.
- Si un paquete no está en repos oficiales ni en AUR binario, se omite con un mensaje claro.

## Prioridad de fuentes

1. Repos oficiales (pacman).
2. AUR binario preferido (`*-bin`).
3. AUR fuente.
4. Omitir con mensaje de seguridad.

## Logs

Cada ejecución crea un log en `/var/log/arch-reconstructor/` con niveles OK, WARN y ERROR.

## Licencia

MIT. Ver `LICENSE`.
