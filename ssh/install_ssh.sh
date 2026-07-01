#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

command -v sudo >/dev/null 2>&1 || die "Falta sudo"
command -v pacman >/dev/null 2>&1 || die "Falta pacman"

print_info "Instalando OpenSSH..."
sudo pacman -S --needed --noconfirm openssh

print_success "OpenSSH instalado"
