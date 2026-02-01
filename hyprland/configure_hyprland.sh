#!/bin/bash

# Script para configurar Hyprland (copiar configs y configurar autostart)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# --- Colores para la salida ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

print_info "==== Configuración de Hyprland ===="

copy_config_dir() {
    src="$1"
    dst="$2"
    if [ ! -d "$src" ]; then
        return 0
    fi
    mkdir -p "$dst"
    if [ -t 0 ] && [ -t 1 ] && [ -e "$dst" ] && [ "$(ls -A "$dst" 2>/dev/null || true)" != "" ]; then
        echo -n "Se detectó configuración existente en $dst. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
        read -r overwrite
        case "$overwrite" in
            [sS]|[sS][iI])
                rm -rf "$dst"
                mkdir -p "$dst"
                ;;
            *)
                echo "Omitiendo copia de configuración para $dst"
                return 0
                ;;
        esac
    fi
    cp -a "$src/." "$dst/"
}

# Copiar configuraciones de Hyprland
HYPR_SOURCE="$SCRIPT_DIR/conf"
if [ -d "$HYPR_SOURCE" ]; then
    copy_config_dir "$HYPR_SOURCE" "$HOME/.config/hypr"
    print_success "Configuración de Hyprland copiada"
else
    print_info "No se encontró directorio de configuración conf/, saltando..."
fi

# Configurar inicio automático de Hyprland
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas iniciar Hyprland automáticamente al iniciar sesión (TTY1)? (s/n, por defecto: n): "
    read -r hypr_autostart
    case "$hypr_autostart" in
        [sS]|[sS][iI])
            ZPROFILE="$HOME/.zprofile"
            if ! grep -q 'exec start-hyprland' "$ZPROFILE" 2>/dev/null; then
                printf '\nif [ -z "${DISPLAY-}" ] && [ "${XDG_VTNR-}" = "1" ]; then\n  exec start-hyprland\nfi\n' >> "$ZPROFILE"
                print_success "Hyprland se iniciará automáticamente en TTY1"
            fi
            ;;
        *)
            ;;
    esac
fi
