#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/configs"
DST_DIR="$HOME/.config/swaync"

sudo pacman -S --needed --noconfirm swaync python-gobject

mkdir -p "$DST_DIR"
cp -an "$SRC_DIR/." "$DST_DIR/"
