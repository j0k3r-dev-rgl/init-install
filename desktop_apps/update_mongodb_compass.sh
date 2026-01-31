#!/bin/bash

# Script de actualización de MongoDB Compass
# Autocontenido - descarga e instala directamente sin depender del instalador

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[COMPASS UPDATE]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

die() {
    print_error "$*"
    exit 1
}

INSTALL_DIR="/opt/mongo/mongoDBCompass"
VERSION_FILE="/opt/mongo/mongoDBCompass/.version"
DESKTOP_FILE="$HOME/.local/share/applications/mongodb-compass.desktop"

# Verificar dependencias
command -v jq >/dev/null 2>&1 || die "jq no está instalado. Instala con: sudo pacman -S jq"
command -v wget >/dev/null 2>&1 || die "wget no está instalado. Instala con: sudo pacman -S wget"

print_info "Verificando versión instalada de MongoDB Compass..."

# Obtener versión actual
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    print_info "Versión actual: v$CURRENT_VERSION"
else
    print_warning "MongoDB Compass no está instalado"
    CURRENT_VERSION=""
fi

# Obtener última versión disponible
print_info "Consultando última versión disponible en GitHub..."

LATEST_VERSION=$(curl -sL https://api.github.com/repos/mongodb-js/compass/releases/latest | \
    jq -r '.tag_name' | sed 's/^v//')

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
    die "No se pudo obtener la última versión. Verifica tu conexión a internet."
fi

print_info "Última versión disponible: v$LATEST_VERSION"

# Comparar versiones
if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    print_success "Ya tienes la última versión instalada (v$LATEST_VERSION)"
    echo ""
    print_info "No hay actualizaciones disponibles"
    exit 0
fi

# Hay actualización disponible
if [ -n "$CURRENT_VERSION" ]; then
    echo ""
    print_info "═══════════════════════════════════════════════════"
    print_info "  Nueva versión disponible!"
    print_info "  Actual:     v$CURRENT_VERSION"
    print_info "  Disponible: v$LATEST_VERSION"
    print_info "═══════════════════════════════════════════════════"
else
    echo ""
    print_info "═══════════════════════════════════════════════════"
    print_info "  MongoDB Compass no está instalado"
    print_info "  Versión a instalar: v$LATEST_VERSION"
    print_info "═══════════════════════════════════════════════════"
fi

echo ""

# Preguntar al usuario
if [ -t 0 ] && [ -t 1 ]; then
    read -p "¿Deseas continuar con la instalación/actualización? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        print_info "Actualización cancelada por el usuario"
        exit 0
    fi
fi

# Iniciar instalación/actualización
print_info "Iniciando instalación/actualización..."
echo ""

# Obtener URL de descarga
print_info "Buscando URL de descarga..."
URL=$(curl -sL https://api.github.com/repos/mongodb-js/compass/releases/latest | \
    jq -r '.assets[].browser_download_url' | \
    grep -E 'mongodb-compass-[0-9]+\.[0-9]+\.[0-9]+-linux-x64\.tar\.gz$' | \
    grep -v 'isolated' | grep -v 'readonly' | head -n1)

if [ -z "$URL" ]; then
    die "No se pudo obtener la URL de descarga"
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_info "Descargando MongoDB Compass v$LATEST_VERSION..."
print_info "URL: $URL"

cd "$TEMP_DIR"
wget -q --show-progress -O compass.tar.gz "$URL" || die "Error al descargar MongoDB Compass"

print_info "Extrayendo archivo..."
tar -xzf compass.tar.gz || die "Error al extraer el archivo"

# Encontrar el directorio extraído
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "*Compass*" | head -n 1)
if [ -z "$EXTRACTED_DIR" ]; then
    die "No se encontró el directorio extraído"
fi

# Eliminar instalación anterior si existe
if [ -d "$INSTALL_DIR" ]; then
    print_info "Eliminando versión anterior..."
    sudo rm -rf "$INSTALL_DIR"
fi

# Crear directorio padre
sudo mkdir -p "/opt/mongo"

# Mover a /opt/mongo/mongoDBCompass
sudo mv "$EXTRACTED_DIR" "$INSTALL_DIR" || die "Error al mover archivos a /opt"

# Guardar versión instalada
echo "$LATEST_VERSION" | sudo tee "$VERSION_FILE" > /dev/null

# Crear/actualizar lanzador .desktop
print_info "Actualizando lanzador de aplicación..."

mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=MongoDB Compass
Comment=The GUI for MongoDB
Exec="$INSTALL_DIR/MongoDB Compass"
Icon=$INSTALL_DIR/resources/app/node_modules/@mongodb-js/compass/dist/main.png
Terminal=false
Type=Application
Categories=Development;Database;
Keywords=mongodb;database;compass;
StartupWMClass=MongoDB Compass
EOF

chmod +x "$DESKTOP_FILE"

# Actualizar caché de aplicaciones
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo ""
print_success "MongoDB Compass v$LATEST_VERSION instalado correctamente"
print_info ""
print_info "Ubicación: $INSTALL_DIR"
print_info "Lanzador: $DESKTOP_FILE"
print_info ""
print_info "Para ejecutar:"
print_info "  • Desde Rofi: Busca 'MongoDB Compass'"
print_info "  • Desde terminal: '$INSTALL_DIR/MongoDB Compass'"
