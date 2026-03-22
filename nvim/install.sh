#!/bin/bash

# ============================================================================
# Script de instalación de Neovim Nightly
# Descarga el binario pre-compilado más reciente desde GitHub
# Clona la configuración personal desde el repositorio
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die()           { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

require_cmd sudo
require_cmd curl
require_cmd tar
require_cmd git

NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
NVIM_CONFIG_REPO="git@github.com:j0k3r-dev-rgl/nvim-configs.git"
INSTALL_DIR="/opt/nvim"

echo "============================================"
echo "Instalador de Neovim Nightly"
echo "============================================"
echo ""

# ── 1. Instalar dependencias del sistema ──────────────────────────────────────

print_info "Instalando dependencias..."
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
    wl-clipboard

sudo npm install -g neovim
print_success "Dependencias instaladas"

# ── 2. Descargar binario nightly ──────────────────────────────────────────────

print_info "Descargando Neovim Nightly..."
curl -LO "$NVIM_URL"

print_info "Eliminando instalación anterior (si existe)..."
sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64

print_info "Extrayendo en /opt..."
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo mv /opt/nvim-linux-x86_64 /opt/nvim
rm nvim-linux-x86_64.tar.gz
print_success "Neovim instalado en $INSTALL_DIR"

# ── 3. Configurar PATH ────────────────────────────────────────────────────────

SHELL_RC="${HOME}/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="${HOME}/.bashrc"

if ! grep -q 'export PATH="$PATH:/opt/nvim/bin"' "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# Neovim" >> "$SHELL_RC"
    echo 'export PATH="$PATH:/opt/nvim/bin"' >> "$SHELL_RC"
    print_success "PATH agregado a $SHELL_RC"
else
    print_success "PATH ya configurado"
fi

# ── 4. Clonar configuración personal ─────────────────────────────────────────

print_info "Configurando nvim config..."

if [ -d "${HOME}/.config/nvim" ] && [ "$(ls -A "${HOME}/.config/nvim" 2>/dev/null)" ]; then
    print_info "~/.config/nvim ya existe, haciendo backup..."
    mv "${HOME}/.config/nvim" "${HOME}/.config/nvim.bak.$(date +%s)"
fi

mkdir -p "${HOME}/.config"
git clone "$NVIM_CONFIG_REPO" "${HOME}/.config/nvim"
print_success "Configuración clonada desde $NVIM_CONFIG_REPO"

# ── 5. Resumen ────────────────────────────────────────────────────────────────

echo ""
echo "============================================"
print_success "Neovim Nightly instalado correctamente"
echo "============================================"
echo ""
echo "Próximos pasos:"
echo "  1. Recarga tu shell:  source $SHELL_RC"
echo "  2. Verifica versión:  nvim --version"
echo "  3. Abre nvim — los plugins se instalan automáticamente en el primer inicio"
echo "  4. Dentro de nvim:    :checkhealth"
echo ""
