# Flujo del asistente bootstrap

1. Verificar privilegios (sudo/root)
2. Verificar e instalar git si falta
3. Detectar sistema (distro, kernel, gestor de paquetes)
4. Detectar hardware (GPU, audio)
5. Preguntar perfil base
6. Preguntar entorno gráfico
7. Preguntar servidor de audio
8. Preguntar navegador principal
9. Recorrer suites opcionales
10. Resumen y confirmación final
11. Instalación con logs y manejo de errores
12. Verificación final

## Modo dry-run

```bash
sudo ./bootstrap.sh --dry-run
```

En modo dry-run:

- Detecta sistema y hardware.
- Muestra las preguntas.
- Muestra qué instalaría (sin ejecutar pacman -S ni yay -S).
- Genera el log normalmente.
- No toca nada del sistema.

## Prioridad de fuentes

1. Repos oficiales (pacman)
2. AUR binario preferido
3. AUR fuente
4. Omitir con mensaje de seguridad

## Logs

Cada ejecución crea un log en `/var/log/arch-reconstructor/` con niveles OK, WARN y ERROR.
