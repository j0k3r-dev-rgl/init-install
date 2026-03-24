#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
YAZI_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
TMP_DIR="$(mktemp -d)"
SRC_DIR="$SCRIPT_DIR/configs"
DST_DIR="$HOME/.config/yazi"

trap 'rm -rf "$TMP_DIR"' EXIT

sudo pacman -S --needed --noconfirm ffmpeg 7zip fd ripgrep fzf zoxide poppler unzip

curl -L "$YAZI_URL" -o "$TMP_DIR/yazi.zip"
unzip -q "$TMP_DIR/yazi.zip" -d "$TMP_DIR"

YAZI_BIN="$(find "$TMP_DIR" -type f -name yazi | head -n 1)"
YA_BIN="$(find "$TMP_DIR" -type f -name ya | head -n 1)"

[ -n "$YAZI_BIN" ] || die "No se encontró el binario de yazi"

sudo install -m 755 "$YAZI_BIN" /usr/local/bin/yazi
if [ -n "$YA_BIN" ]; then
    sudo install -m 755 "$YA_BIN" /usr/local/bin/ya
fi

mkdir -p "$DST_DIR"
cp -an "$SRC_DIR/." "$DST_DIR/"
