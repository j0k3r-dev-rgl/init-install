#!/bin/bash

# Script para instalar Rofi y los temas de adi1090x
# https://github.com/adi1090x/rofi

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

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

print_info "==== Instalación de Rofi con temas de adi1090x ===="

# 1. Instalar Rofi y dependencias
print_info "Instalando Rofi y dependencias..."
pacman_install rofi

print_success "Rofi instalado"

# 2. Clonar repositorio de temas adi1090x
ROFI_THEMES_DIR="$HOME/.config/rofi"
TEMP_DIR="$(mktemp -d)"

print_info "Descargando temas de adi1090x..."
git clone --depth=1 https://github.com/adi1090x/rofi.git "$TEMP_DIR/rofi-themes"

# 3. Instalar temas
print_info "Instalando temas..."
cd "$TEMP_DIR/rofi-themes"
chmod +x setup.sh
./setup.sh

print_success "Temas de Rofi instalados"

# 4. Limpiar
rm -rf "$TEMP_DIR"

# 5. Fijar launcher: type-7 / style-1
print_info "Configurando launcher type-7 style-1..."

LAUNCHER="$HOME/.config/rofi/launchers/type-7/launcher.sh"
if [ -f "$LAUNCHER" ]; then
    sed -i "s/^theme=.*/theme='style-1'/" "$LAUNCHER"
    chmod +x "$LAUNCHER"
    print_success "Launcher configurado: type-7 / style-1"
else
    print_info "launcher.sh no encontrado, omitiendo configuración de tema"
fi

print_success "==== Rofi instalado y configurado correctamente ===="
print_info "Tema activo: Type-7 Style-1"
print_info "Ejecuta: Super + D"
