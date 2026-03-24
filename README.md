# init-install

Scripts bash modulares para replicar el sistema real del usuario sobre Arch Linux.

## Uso

```bash
./install.sh
```

`install.sh` abre un menú interactivo con `whiptail` para seleccionar qué categorías instalar.

## Menú interactivo

- Checklist principal con categorías instalables
- Botón **Instalar** para ejecutar la selección actual
- Botón **Opciones** con acciones extra:
  - **Install all**
  - **Select all**
  - **Deselect all**
  - **Ver paquetes** por categoría
- Botón **Salir** para cerrar sin instalar

Las selecciones se guardan en:

```bash
~/.init-install.conf
```

## Categorías incluidas

1. system_base
2. homebrew
3. yay + AUR
4. drivers_utilities
5. hyprland
6. waybar
7. swaync
8. wlogout
9. rofi
10. kitty
11. nvim
12. yazi
13. docker
14. system_essentials
15. zsh
16. keyring
17. mongodb_compass
18. opencode
19. post_install

## Notas

- Si `whiptail` no está disponible, el instalador intenta instalarlo automáticamente con `pacman` (`libnewt` en Arch)
- El progreso de la instalación se muestra con una barra `gauge`
- Las configuraciones del repo viven en `configs/`
- Las copias al `$HOME` se hacen en modo no destructivo
- MongoDB Compass se instala desde el binario oficial
- El proyecto replica el setup actual del usuario sin herramientas de MongoDB por CLI
