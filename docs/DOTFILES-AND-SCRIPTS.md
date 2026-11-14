# Dotfiles y scripts personales

## Dotfiles

- Pregunta al final: "¿Deseas importar dotfiles desde un repositorio? (s/N)"
- Por defecto: no.
- Si acepta, pide URL del repo (público o privado).
- Clona en temporal y copia solo rutas seguras:
  - ~/.config/xfce4, Thunar, kitty, fastfetch, htop, mpv, gtk-3.0, gtk-2.0
  - ~/.config/starship.toml, mimeapps.list, user-dirs.dirs
  - ~/.bashrc, ~/.bash_profile, ~/.gitconfig
- Nunca copia: BraveSoftware, obs-studio, PCSX2, Riff, itch, systemd, .ssh, .gnupg, tokens.
- Limpia el temporal al salir.

## Scripts personales

- Pregunta al final: "¿Deseas importar scripts y programas personalizados? (s/N)"
- Por defecto: no.
- Si acepta, pide URL del repo privado (ej. personal-scripts).
- Clona en temporal y copia a ~/.local/bin/.
- Limpia el temporal al salir.

## Forzar XFCE

- Si el usuario elige xfce y ya tiene otro DE/WM (plasma, gnome, hyprland, i3), se pregunta:
  "¿Deseas forzar XFCE y retirar X? (s/N)"
- Requiere doble confirmación.
- Solo con doble confirmación se procede.
