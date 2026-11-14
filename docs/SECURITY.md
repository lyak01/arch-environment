# Reglas de seguridad

## Datos que nunca se copian ni restauran

- Secretos: `.ssh`, `.gnupg`, tokens, contraseñas, `.env`.
- Sistema base crítico: kernel, initramfs, GRUB, usuarios, `/etc/shadow`, `/etc/fstab`.
- Configuración de red con IPs fijas.
- Drivers propietarios sin confirmación explícita.
- Cachés, logs, binarios compilados.

## Drivers y hardware específico

- NVIDIA, CUDA, Oxyglow y otros drivers propietarios quedan fuera de los manifiestos comunes.
- Se instalan solo si el usuario los confirma explícitamente.
- Los respaldos personales (OBS, CUDA, Oxyglow) permanecen en repositorios privados separados.

## Prioridad de fuentes

1. Repos oficiales (pacman).
2. AUR binario preferido (`*-bin`).
3. AUR fuente.
4. Omitir con mensaje de seguridad.

## Mensaje de omisión

```text
xxxxx paquete no se encuentra disponible en los mirrors oficiales
ni en un binario disponible del AUR, se ha omitido por seguridad,
lamentamos este inconveniente y se sugiere modificar/montar el
paquete manualmente.
```

## Limpieza automática

- El script `install.sh` clona el repo en un directorio temporal.
- Al terminar (o si falla), elimina el directorio temporal con `trap EXIT`.
- El sistema queda limpio después de usar el reconstructor.
