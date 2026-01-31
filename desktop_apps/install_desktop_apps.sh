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

# 0. Dependencias necesarias
print_info "Instalando dependencias necesarias (jq, wget)..."
pacman_install jq wget

# 1. Gestor de archivos y soporte USB
print_info "Instalando Dolphin (gestor de archivos) y soporte USB..."
pacman_install dolphin udisks2 udiskie gvfs gvfs-mtp gvfs-gphoto2 gvfs-afc htop btop

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

# 4. MongoDB Compass (opcional)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPASS_INSTALLER="$SCRIPT_DIR/install_mongodb_compass.sh"

if [ -t 0 ] && [ -t 1 ]; then
    echo ""
    echo -n "¿Deseas instalar MongoDB Compass (GUI para MongoDB)? (s/n, por defecto: n): "
    read -r install_compass
    case "$install_compass" in
        [sS]|[sS][iI])
            if [ -f "$COMPASS_INSTALLER" ]; then
                print_info "Instalando MongoDB Compass..."
                bash "$COMPASS_INSTALLER"
                
                # Configurar comando global
                COMPASS_SETUP="$SCRIPT_DIR/setup_compass_command.sh"
                if [ -f "$COMPASS_SETUP" ]; then
                    bash "$COMPASS_SETUP"
                fi
                
                print_success "MongoDB Compass instalado"
            else
                print_info "Instalador de MongoDB Compass no encontrado, saltando..."
            fi
            ;;
        *)
            print_info "Saltando instalación de MongoDB Compass"
            ;;
    esac
else
    print_info "Modo no interactivo: Saltando MongoDB Compass"
fi

print_success "==== Aplicaciones de escritorio instaladas correctamente ===="
