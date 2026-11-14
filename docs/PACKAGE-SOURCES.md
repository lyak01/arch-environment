# Reglas de fuentes de paquetes

## Prioridad

1. Buscar en repositorios oficiales (pacman).
2. Si no está, buscar en AUR preferentemente binario (*-bin).
3. Si no hay binario, buscar paquete fuente en AUR.
4. Si no existe en ninguno, omitir con mensaje:

```text
xxxxx paquete no se encuentra disponible en los mirrors oficiales
ni en un binario disponible del AUR, se ha omitido por seguridad,
lamentamos este inconveniente y se sugiere modificar/montar el
paquete manualmente.
```

## Notas

- Los paquetes de hardware específico (NVIDIA, CUDA, Oxyglow) quedan fuera de los manifiestos comunes.
- Los paquetes AUR se instalan solo si el usuario lo confirma.
- Si un paquete falla, se registra en el log y se continúa con el resto.
