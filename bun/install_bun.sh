#!/bin/bash

# Script para instalar Bun (JavaScript runtime y toolkit)

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

print_info "==== Instalación de Bun ===="

# Verificar si Bun ya está instalado
if command -v bun >/dev/null 2>&1; then
    CURRENT_VERSION=$(bun --version)
    print_success "Bun ya está instalado (versión $CURRENT_VERSION)"
    
    if [ -t 0 ] && [ -t 1 ]; then
        echo -n "¿Deseas reinstalar/actualizar Bun? (s/n, por defecto: n): "
        read -r response
        case "$response" in
            [sS]|[sS][iI])
                print_info "Reinstalando Bun..."
                ;;
            *)
                print_info "Saltando instalación de Bun"
                exit 0
                ;;
        esac
    else
        print_info "Saltando instalación de Bun"
        exit 0
    fi
fi

# Instalar Bun mediante el script oficial
print_info "Descargando e instalando Bun..."
curl -fsSL https://bun.sh/install | bash

# Verificar la instalación
if [ -f "$HOME/.bun/bin/bun" ]; then
    print_success "Bun instalado correctamente en $HOME/.bun"
    
    # Mostrar versión instalada
    BUN_VERSION=$("$HOME/.bun/bin/bun" --version)
    print_info "Versión instalada: $BUN_VERSION"
    
    print_info "Bun se ha agregado a tu PATH en ~/.zshrc"
    print_info "Reinicia tu terminal o ejecuta 'source ~/.zshrc' para usar Bun"
else
    die "Error durante la instalación de Bun"
fi

print_success "Instalación de Bun completada"
