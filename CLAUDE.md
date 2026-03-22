# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

Scripts modulares de bash para automatizar la instalación de un entorno de desarrollo completo en Arch Linux (y derivados con `pacman`). El objetivo es pasar de una instalación limpia a un sistema listo para desarrollo.

## Comandos Principales

### Instalación completa
```bash
chmod +x install.sh
./install.sh
```

### Instalación modular (scripts individuales)
```bash
bash drivers_utilities/gpu_drivers_install.sh
bash zsh/install_zsh.sh && bash zsh/change_shell.sh
bash hyprland/install_hyprland.sh && bash hyprland/configure_hyprland.sh
bash devtools/install_nvm_jdk_maven.sh
bash docker/install_docker.sh
bash bun/install_bun.sh
```

### Actualización del sistema (post-instalación)
```bash
update    # Alias que actualiza pacman + yay + MongoDB Compass
```

## Arquitectura del Proyecto

Todos los módulos son independientes y ejecutables por separado. El `install.sh` raíz los orquesta en un orden específico crítico:

```
1. Sistema base (pacman -Syu)
2. Drivers/utilidades (NetworkManager, PipeWire, códecs, microcódigo CPU, GPU, TRIM)
3. Yay (AUR helper)
4. Paquetes AUR (Chrome, OnlyOffice)
5. Fuentes (Nerd Fonts)
6. GNOME Keyring
7. Entorno gráfico (Hyprland, Rofi, mpv, imv, MongoDB Compass)
8. ZSH + Oh My Zsh + Powerlevel10k          ← ZSH ANTES que Neovim
9. Configuración Hyprland + MIME
10. Opcional: Kitty, Bun, DevTools (NVM/JDK/Maven), Docker, SSH
11. opencode.ai
```

> El orden importa: ZSH debe configurarse antes que el resto de herramientas opcionales.

## Convenciones de los Scripts

- Todos los scripts usan `set -euo pipefail`
- Funciones comunes: `print_info()`, `print_success()`, `die()`, `require_cmd()`
- Scripts interactivos detectan si están en un TTY (`[ -t 0 ] && [ -t 1 ]`) antes de pedir input
- GPU drivers se detectan automáticamente (`lspci | grep -i "nvidia\|amd\|intel"`)
- CPU microcode se detecta con `lscpu | grep -i "amd\|intel"`

## Rutas Importantes Post-Instalación

| Componente | Ruta |
|---|---|
| MongoDB Compass | `/opt/mongo/mongoDBCompass` |
| Hyprland config | `~/.config/hypr/hyprland.conf` |
| Kitty config | `~/.config/kitty/kitty.conf` |
| ZSH config | `~/.zshrc` |
| Guía de comandos | `~/COMANDOS.md` (también accesible con `h`) |

## Variables de Entorno (`.zshrc`)

- `PATH` incluye `~/.local/bin`
- `BUN_INSTALL=~/.bun`
- `NVM_DIR=~/.nvm`
- `JAVA_HOME=/usr/lib/jvm/default`
- `M2_HOME` y `MAVEN_HOME=~/.local/share/maven`
