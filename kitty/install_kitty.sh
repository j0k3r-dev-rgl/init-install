#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

copy_kitty_config() {
    mode="$1" # full | conf_only
    src_dir="$SCRIPT_DIR"
    dst_dir="$HOME/.config/kitty"

    if [ ! -d "$src_dir" ]; then
        return 0
    fi

    mkdir -p "$dst_dir"

    if [ -t 0 ] && [ -t 1 ] && [ -e "$dst_dir" ] && [ "$(ls -A "$dst_dir" 2>/dev/null || true)" != "" ]; then
        echo -n "Se detectó configuración existente en $dst_dir. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
        read -r overwrite
        case "$overwrite" in
            [sS]|[sS][iI])
                rm -rf "$dst_dir"
                mkdir -p "$dst_dir"
                ;;
            *)
                echo "Omitiendo copia de configuración para $dst_dir"
                return 0
                ;;
        esac
    fi

    [ -f "$src_dir/kitty.conf" ] || die "No se encontró $src_dir/kitty.conf"
    cp -a "$src_dir/kitty.conf" "$dst_dir/kitty.conf"

    if [ "$mode" = "full" ] && [ -f "$src_dir/current-theme.conf" ]; then
        cp -a "$src_dir/current-theme.conf" "$dst_dir/current-theme.conf"
    fi
}

if [ -t 0 ] && [ -t 1 ] && command -v kitty >/dev/null 2>&1; then
    echo -n "¿Deseas seleccionar un tema para Kitty ahora? (s/n, por defecto: n): "
    read -r kitty_theme
    case "$kitty_theme" in
        [sS]|[sS][iI])
            copy_kitty_config conf_only
            echo -e "${GREEN}Abriendo selector de temas de Kitty...${NC}"
            kitty +kitten themes
            ;;
        *)
            copy_kitty_config full
            ;;
    esac
else
    copy_kitty_config full
fi
