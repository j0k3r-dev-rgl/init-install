# CLAUDE.md

## Descripción del Proyecto

Scripts modulares de bash para dejar un sistema Arch Linux alineado con el setup real del usuario.

## Flujo principal

1. `system_base/install_base.sh`
2. `yay_install/install_yay_packages.sh`
3. `drivers_utilities/*`
4. `hyprland/install_hyprland.sh`
5. `waybar/install_waybar.sh`
6. `swaync/install_swaync.sh`
7. `wlogout/install_wlogout.sh`
8. `rofi/install_rofi.sh`
9. `kitty/install_kitty.sh`
10. `nvim/install.sh`
11. `yazi/install_yazi.sh`
12. `docker/install_docker.sh`
13. `system_essentials/install_essentials.sh`
14. `zsh/install_zsh.sh`
15. `keyring/*`
16. `mongodb_compass/install_compass.sh`
17. `opencode/install_opencode.sh`
18. `codex/install_codex.sh`
19. `intellij/install_intellij.sh`

## Convenciones

- Todos los scripts usan `set -euo pipefail`
- Las configuraciones del repo viven en `configs/`
- Las copias al `$HOME` usan modo no destructivo (`cp -an` o equivalentes)
- La detección automática de CPU/GPU se mantiene
- MongoDB Compass se instala desde el binario oficial
- MongoDB Compass se mantiene como herramienta gráfica de MongoDB
- IntelliJ IDEA se instala desde la API oficial de JetBrains (última versión)
- Codex se instala via Homebrew (`brew install codex`)
