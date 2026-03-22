#!/bin/bash

# ============================================================================
# Script de instalación de Yazi (última versión desde GitHub releases)
# Instala el binario más reciente y copia la configuración personal
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die()           { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
YAZI_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
INSTALL_DIR="/usr/local/bin"

echo "============================================"
echo "Instalador de Yazi (latest)"
echo "============================================"
echo ""

# ── 1. Dependencias ───────────────────────────────────────────────────────────

print_info "Instalando dependencias..."
sudo pacman -S --needed --noconfirm \
    ffmpeg \
    7zip \
    fd \
    ripgrep \
    fzf \
    zoxide \
    poppler \
    imagemagick \
    unzip

print_success "Dependencias instaladas"

# ── 2. Descargar binario ──────────────────────────────────────────────────────

print_info "Descargando Yazi (latest release)..."
TMP_DIR="$(mktemp -d)"
curl -Lo "$TMP_DIR/yazi.zip" "$YAZI_URL"

print_info "Extrayendo..."
unzip -q "$TMP_DIR/yazi.zip" -d "$TMP_DIR"

# El zip contiene un directorio con los binarios
YAZI_BIN="$(find "$TMP_DIR" -name "yazi" -type f | head -1)"
YA_BIN="$(find "$TMP_DIR" -name "ya" -type f | head -1)"

[ -z "$YAZI_BIN" ] && die "No se encontró el binario yazi en el zip"

sudo install -m 755 "$YAZI_BIN" "$INSTALL_DIR/yazi"
[ -n "$YA_BIN" ] && sudo install -m 755 "$YA_BIN" "$INSTALL_DIR/ya"

rm -rf "$TMP_DIR"
print_success "Yazi instalado en $INSTALL_DIR/yazi"

# ── 3. Copiar configuración ───────────────────────────────────────────────────

print_info "Copiando configuración de yazi..."
mkdir -p "${HOME}/.config/yazi"
cp "$SCRIPT_DIR/conf/yazi/yazi.toml" "${HOME}/.config/yazi/yazi.toml"
print_success "Configuración instalada en ~/.config/yazi/"

# ── 4. Resumen ────────────────────────────────────────────────────────────────

echo ""
echo "============================================"
print_success "Yazi instalado correctamente"
echo "============================================"
echo ""
yazi --version
echo ""
echo "Uso: ejecuta 'yazi' en la terminal"
echo "Keybind Hyprland: SUPER + E"
echo ""
