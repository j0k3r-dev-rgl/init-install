#!/bin/bash

# Script para instalar aplicaciones de escritorio y configurar soporte USB/multimedia

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

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

print_info "==== Instalación de Aplicaciones de Escritorio ===="

# 1. Gestor de archivos y soporte USB
print_info "Instalando Dolphin (gestor de archivos) y soporte USB..."
pacman_install dolphin udisks2 udiskie gvfs gvfs-mtp gvfs-gphoto2 gvfs-afc

# Habilitar udisks2 para montaje automático de USB
print_info "Habilitando servicio udisks2..."
sudo systemctl enable udisks2.service

print_success "Dolphin y soporte USB instalados"

# 2. Reproductor de video (mpv - el mejor para Wayland)
print_info "Instalando mpv (reproductor de video)..."
pacman_install mpv

print_success "mpv instalado"

# 3. Visor de imágenes (imv - nativo Wayland, ligero y rápido)
print_info "Instalando imv (visor de imágenes)..."
pacman_install imv

print_success "imv instalado"

print_success "==== Aplicaciones de escritorio instaladas correctamente ===="
