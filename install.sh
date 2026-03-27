#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Validate Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "Error: Este script está pensado para Arch Linux."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "Error: pacman no encontrado. ¿Estás en Arch Linux?"
    exit 1
fi

# Check Python3
if ! command -v python3 >/dev/null 2>&1; then
    echo "Python3 no encontrado. Instalando..."
    sudo pacman -S --needed --noconfirm python
fi

# Check curses module
if ! python3 -c "import curses" >/dev/null 2>&1; then
    echo "Módulo curses no disponible. Instalando python-curses..."
    sudo pacman -S --needed --noconfirm python-curses
fi

# Check interactive terminal
if [ ! -t 0 ]; then
    echo "Error: Este script requiere una terminal interactiva."
    exit 1
fi

# Verificar que zsh esté instalado y sea el shell activo
if ! command -v zsh >/dev/null 2>&1 || [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    echo ""
    echo "  AVISO: Zsh no está configurado como shell por defecto."
    echo "  El instalador principal requiere que zsh esté activo."
    echo ""
    echo -n "  ¿Ejecutar pre_install.sh para configurarlo ahora? (S/n): "
    read -r resp
    resp="${resp:-s}"
    case "${resp,,}" in
        s|si|yes|y)
            exec bash "$SCRIPT_DIR/pre_install.sh"
            ;;
        *)
            echo ""
            echo "  Puedes ejecutarlo manualmente cuando quieras:"
            echo "    bash $SCRIPT_DIR/pre_install.sh"
            echo ""
            exit 0
            ;;
    esac
fi

exec python3 "$SCRIPT_DIR/install.py" "$@"
