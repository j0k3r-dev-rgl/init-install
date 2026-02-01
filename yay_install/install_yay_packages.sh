#!/bin/bash

# Script para instalar paquetes desde AUR usando yay
# Este script debe ejecutarse DESPUÉS de que yay esté instalado

set -euo pipefail

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

# Verificar que yay esté instalado
if ! command -v yay &> /dev/null; then
    die "yay no está instalado. Ejecuta primero la instalación de yay desde el script principal."
fi

print_info "==== Instalación de paquetes desde AUR con yay ===="

# 1. Google Chrome
if ! command -v google-chrome &> /dev/null; then
    print_info "Instalando Google Chrome..."
    yay -S --needed --noconfirm google-chrome
    print_success "Google Chrome instalado"
else
    print_info "Google Chrome ya está instalado, saltando..."
fi

# 2. OnlyOffice Desktop Editors
if ! command -v onlyoffice-desktopeditors &> /dev/null; then
    print_info "Instalando OnlyOffice Desktop Editors..."
    yay -S --needed --noconfirm onlyoffice-bin
    print_success "OnlyOffice Desktop Editors instalado"
else
    print_info "OnlyOffice ya está instalado, saltando..."
fi

print_success "==== Instalación de paquetes AUR completada ===="
