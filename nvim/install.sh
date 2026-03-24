#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
INSTALL_DIR="/opt/nvim-linux-x86_64"
TMP_DIR="$(mktemp -d)"
LOCAL_CONFIG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/configs"

trap 'rm -rf "$TMP_DIR"' EXIT

sudo pacman -S --needed --noconfirm git gcc make unzip ripgrep fd nodejs npm python python-pip python-pynvim tree-sitter tree-sitter-cli wl-clipboard
sudo npm install -g neovim

curl -L "$NVIM_URL" -o "$TMP_DIR/nvim-linux-x86_64.tar.gz"
sudo rm -rf "$INSTALL_DIR"
sudo tar -C /opt -xzf "$TMP_DIR/nvim-linux-x86_64.tar.gz"

SHELL_RC="$HOME/.zshrc"
[ -f "$SHELL_RC" ] || SHELL_RC="$HOME/.bashrc"

if ! grep -q '/opt/nvim-linux-x86_64/bin' "$SHELL_RC" 2>/dev/null; then
    printf '\n# Neovim\nexport PATH="$PATH:/opt/nvim-linux-x86_64/bin"\n' >> "$SHELL_RC"
fi

if [ -d "$HOME/.config/nvim" ] && [ -n "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi

[ -d "$LOCAL_CONFIG_DIR" ] || die "No se encontró la configuración local de Neovim en $LOCAL_CONFIG_DIR"

mkdir -p "$HOME/.config/nvim"
cp -an "$LOCAL_CONFIG_DIR/." "$HOME/.config/nvim/"
