#!/bin/bash
set -euo pipefail

print_info() { echo -e "\033[1;34m==>\033[0m $*"; }
die() { echo -e "\033[1;31mERROR:\033[0m $*" >&2; exit 1; }

command -v pacman >/dev/null 2>&1 || die "Falta pacman"

if ! command -v yay >/dev/null 2>&1; then
    die "Noctalia Shell requiere yay instalado. Ejecuta primero Install base o yay_install."
fi

print_info "Instalando Noctalia Shell desde AUR..."
yay -S --needed --noconfirm noctalia-shell

print_info "Noctalia instalado. Usa Import configs para copiar la configuración."
