# Importación de temas

## Repositorio de temas

El asistente clona `https://github.com/lyak01/zynith-themes.git` (público) en un directorio temporal.

## Estructura esperada

```text
zynith-themes/
├── gtk/
├── xfwm4/
├── icons/
├── cursors/
└── plymouth/
```

## Destinos de instalación

| Origen | Destino |
|---|---|
| gtk/ | ~/.themes/ |
| xfwm4/ | /usr/share/themes/ |
| icons/ | ~/.icons/ |
| cursors/ | ~/.icons/ |
| plymouth/ | /usr/share/plymouth/themes/ |

## Reglas

- Solo se importan temas si el usuario aceptó "aplicar temas".
- El clon es temporal y se elimina al salir.
- Si falta un directorio, se registra WARN y se continúa.
