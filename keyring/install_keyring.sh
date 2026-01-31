#!/bin/bash

# Script de instalación de GNOME Keyring (Secret Service API)
# Este script instala y configura el sistema de llavero de contraseñas estándar de Linux

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[KEYRING]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

print_info "Instalando GNOME Keyring y componentes relacionados..."

# Instalar GNOME Keyring y libsecret
print_info "Instalando gnome-keyring, libsecret y seahorse..."
sudo pacman -S --needed --noconfirm gnome-keyring libsecret seahorse

# Instalar gcr-4 para soporte de SSH agent (gcr-ssh-agent)
print_info "Instalando gcr-4 para soporte de SSH..."
sudo pacman -S --needed --noconfirm gcr-4

print_info "GNOME Keyring instalado correctamente"
print_info ""
print_info "Componentes instalados:"
print_info "  • gnome-keyring: Servicio de llavero de contraseñas"
print_info "  • libsecret: API Secret Service (org.freedesktop.secrets)"
print_info "  • seahorse: Interfaz gráfica para gestionar contraseñas"
print_info "  • gcr-4: Soporte para SSH agent"
print_info ""
print_info "La configuración PAM y autostart se realizará en el siguiente paso"
