#!/bin/bash

# ============================================================================
# Script de instalación de Neovim Nightly
# Instala Neovim en /opt/nvim usando binarios pre-compilados
# Y copia configuración a ~/.config/nvim
# ============================================================================

set -euo pipefail

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

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

require_cmd sudo
require_cmd curl
require_cmd tar

echo "============================================"
echo "Instalador de Neovim Nightly"
echo "============================================"
echo ""

# URL del binario pre-compilado (nightly)
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
INSTALL_DIR="/opt/nvim"
SHELL_RC="${HOME}/.bashrc"

# Detectar si está usando zsh
if [ -n "${ZSH_VERSION:-}" ] || [ -f "${HOME}/.zshrc" ]; then
    SHELL_RC="${HOME}/.zshrc"
fi

print_info "Descargando Neovim Nightly..."
echo ""

# Descargar el binario
curl -LO "$NVIM_URL"

echo ""
print_info "Eliminando instalación anterior (si existe)..."
sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64

echo ""
print_info "Extrayendo archivos en /opt..."
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

echo ""
print_info "Renombrando directorio..."
sudo mv /opt/nvim-linux-x86_64 /opt/nvim

echo ""
print_info "Limpiando archivo temporal..."
rm nvim-linux-x86_64.tar.gz

echo ""
print_info "Configurando PATH..."

# Verificar si ya existe la línea en el archivo de configuración
if grep -q 'export PATH="$PATH:/opt/nvim/bin"' "$SHELL_RC"; then
    print_success "PATH ya configurado en $SHELL_RC"
else
    echo "" >> "$SHELL_RC"
    echo "# Neovim" >> "$SHELL_RC"
    echo 'export PATH="$PATH:/opt/nvim/bin"' >> "$SHELL_RC"
    print_success "PATH agregado a $SHELL_RC"
fi

echo ""
print_info "Instalando dependencias necesarias para Neovim y plugins..."

# Instalar dependencias del sistema
sudo pacman -S --needed --noconfirm \
    git \
    gcc \
    make \
    unzip \
    ripgrep \
    fd \
    nodejs \
    npm \
    python \
    python-pip \
    python-pynvim \
    tree-sitter \
    tree-sitter-cli \
    xclip \
    wl-clipboard

echo ""
print_info "Copiando configuración de Neovim a ~/.config/nvim..."

# Crear directorio de configuración si no existe
mkdir -p "${HOME}/.config/nvim"

# Copiar toda la configuración desde el directorio del script
if [ -d "$SCRIPT_DIR" ]; then
    # Excluir install.sh y lombok.jar al copiar
    for item in "$SCRIPT_DIR"/*; do
        item_name="$(basename "$item")"
        if [ "$item_name" != "install.sh" ] && [ "$item_name" != "lombok.jar" ]; then
            if [ -e "${HOME}/.config/nvim/$item_name" ]; then
                print_info "Ya existe ${HOME}/.config/nvim/$item_name, sobreescribiendo..."
                rm -rf "${HOME}/.config/nvim/$item_name"
            fi
            cp -r "$item" "${HOME}/.config/nvim/"
            print_success "Copiado: $item_name"
        fi
    done
else
    die "No se encontró el directorio de configuración: $SCRIPT_DIR"
fi

echo ""
print_info "Instalando Lombok para Java..."

# Crear directorio para lombok si no existe
sudo mkdir -p /usr/share/java/lombok

# Copiar lombok.jar
if [ -f "$SCRIPT_DIR/lombok.jar" ]; then
    sudo cp "$SCRIPT_DIR/lombok.jar" /usr/share/java/lombok/lombok.jar
    print_success "Lombok instalado en /usr/share/java/lombok/lombok.jar"
else
    print_info "Advertencia: No se encontró lombok.jar en $SCRIPT_DIR, saltando..."
fi

echo ""
print_info "Instalando neovim package manager para Node..."
sudo npm install -g neovim

echo ""
echo "============================================"
print_success "Instalación completada exitosamente!"
echo "============================================"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Recarga tu shell para aplicar los cambios:"
echo "   source $SHELL_RC"
echo ""
echo "2. Verifica la instalación:"
echo "   nvim --version"
echo ""
echo "3. Inicia Neovim (los plugins se instalarán automáticamente en el primer inicio):"
echo "   nvim"
echo ""
echo "4. Dentro de Neovim, verifica que todo funcione:"
echo "   :checkhealth"
echo ""
echo "============================================"
