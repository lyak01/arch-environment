# Flujo del asistente bootstrap

1. Verificar privilegios (sudo/root)
2. Detectar sistema (distro, kernel, gestor de paquetes)
3. Detectar hardware (GPU, audio)
4. Preguntar perfil base
5. Preguntar entorno gráfico
6. Preguntar servidor de audio
7. Preguntar navegador principal
8. Recorrer suites opcionales
9. Resumen y confirmación final
10. Instalación con logs y manejo de errores
11. Verificación final

## Prioridad de fuentes

1. Repos oficiales (pacman)
2. AUR binario preferido
3. AUR fuente
4. Omitir con mensaje de seguridad

## Logs

Cada ejecución crea un log en `/var/log/arch-reconstructor/` con niveles OK, WARN y ERROR.
