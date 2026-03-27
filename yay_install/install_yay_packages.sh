#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

if ! command -v yay >/dev/null 2>&1; then
    print_info "Instalando yay..."
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    trap - EXIT
    rm -rf "$tmp_dir"
fi

print_info "Instalando paquetes AUR requeridos..."
yay -S --needed --noconfirm google-chrome wlogout
