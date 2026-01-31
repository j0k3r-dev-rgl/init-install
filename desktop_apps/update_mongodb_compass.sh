#!/bin/bash

# Script de actualización de MongoDB Compass
# Detecta la versión actual e instala la última si hay una más reciente

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

VERSION_FILE="/opt/mongo/mongoDBCompass/.version"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/install_mongodb_compass.sh"

# Verificar dependencias
command -v jq >/dev/null 2>&1 || die "jq no está instalado. Instala con: sudo pacman -S jq"

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

# Ejecutar instalador
print_info "Iniciando instalación/actualización..."
echo ""

if [ -f "$INSTALLER" ]; then
    bash "$INSTALLER"
else
    die "No se encontró el instalador en: $INSTALLER"
fi

echo ""
print_success "Actualización completada exitosamente"
