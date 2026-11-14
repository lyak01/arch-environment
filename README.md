# arch-environment

Reconstructor modular de entorno Arch Linux con suites, perfiles y asistente CLI.

## Objetivo

Permitir reconstruir un entorno Arch Linux completo desde una instalación base, mediante:

- Detección de hardware, escritorio, audio y gestor de paquetes.
- Asistente CLI con preguntas y confirmaciones.
- Suites modulares por categoría (base, escritorio, navegadores, gaming, desarrollo, etc.).
- Perfiles adaptables por máquina.
- Exclusión de sistema base crítico y secretos.
- Respaldo de paquetes huérfanos mediante repositorios personales.
- Logs detallados y tolerancia a fallos.

## Estructura prevista

```text
arch-environment/
├── bootstrap.sh
├── suites.yaml
├── manifests/
├── config/
├── themes/
├── scripts/
└── docs/
```

## Estado

Proyecto en fase de diseño. La estructura base se está inicializando.
