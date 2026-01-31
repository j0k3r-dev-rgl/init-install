#!/bin/bash

# Instalador de MongoDB Compass
# Descarga, instala en /opt y crea el lanzador .desktop

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[COMPASS]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

die() {
    print_error "$*"
    exit 1
}

# Verificar dependencias
command -v jq >/dev/null 2>&1 || die "jq no está instalado. Instálalo con: sudo pacman -S jq"
command -v wget >/dev/null 2>&1 || die "wget no está instalado. Instálalo con: sudo pacman -S wget"

INSTALL_DIR="/opt/mongo/mongoDBCompass"
VERSION_FILE="/opt/mongo/mongoDBCompass/.version"
DESKTOP_FILE="$HOME/.local/share/applications/mongodb-compass.desktop"

print_info "Buscando última versión de MongoDB Compass en GitHub..."

# Obtener todas las URLs y filtrar el archivo correcto
URL=$(curl -sL https://api.github.com/repos/mongodb-js/compass/releases/latest | \
    jq -r '.assets[].browser_download_url' | \
    grep -E 'mongodb-compass-[0-9]+\.[0-9]+\.[0-9]+-linux-x64\.tar\.gz$' | \
    grep -v 'isolated' | grep -v 'readonly' | head -n1)

if [ -z "$URL" ]; then
    die "No se pudo obtener la URL de descarga. Verifica tu conexión a internet."
fi

# Extraer versión del nombre del archivo
VERSION=$(echo "$URL" | grep -oP 'mongodb-compass-\K[0-9]+\.[0-9]+\.[0-9]+')
print_info "Última versión disponible: v$VERSION"

# Verificar si ya está instalado
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    if [ "$CURRENT_VERSION" = "$VERSION" ]; then
        print_success "MongoDB Compass v$VERSION ya está instalado"
        exit 0
    else
        print_info "Actualizando de v$CURRENT_VERSION a v$VERSION"
    fi
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_info "Descargando MongoDB Compass v$VERSION..."
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
echo "$VERSION" | sudo tee "$VERSION_FILE" > /dev/null

# Crear lanzador .desktop
print_info "Creando lanzador de aplicación..."

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

print_success "MongoDB Compass v$VERSION instalado correctamente"
print_info ""
print_info "Ubicación: $INSTALL_DIR"
print_info "Lanzador: $DESKTOP_FILE"
print_info ""
print_info "Para ejecutar:"
print_info "  • Desde Rofi: Busca 'MongoDB Compass'"
print_info "  • Desde terminal: '$INSTALL_DIR/MongoDB Compass'"
print_info "  • Actualizar: mongodb-compass-update"
