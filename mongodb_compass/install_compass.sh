#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "Falta jq"
command -v wget >/dev/null 2>&1 || die "Falta wget"

INSTALL_DIR="/opt/mongo/mongoDBCompass"
VERSION_FILE="$INSTALL_DIR/.version"
DESKTOP_FILE="$HOME/.local/share/applications/mongodb-compass.desktop"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

URL="$(curl -sL https://api.github.com/repos/mongodb-js/compass/releases/latest | jq -r '.assets[].browser_download_url' | grep -E 'mongodb-compass-[0-9]+\.[0-9]+\.[0-9]+-linux-x64\.tar\.gz$' | grep -v 'isolated' | grep -v 'readonly' | head -n1)"
[ -n "$URL" ] || die "No se pudo obtener la descarga de Compass"

VERSION="$(printf '%s' "$URL" | grep -oP 'mongodb-compass-\K[0-9]+\.[0-9]+\.[0-9]+')"
if [ -f "$VERSION_FILE" ] && [ "$(cat "$VERSION_FILE")" = "$VERSION" ]; then
    print_info "MongoDB Compass v$VERSION ya está instalado"
    exit 0
fi

wget -q -O "$TMP_DIR/compass.tar.gz" "$URL"
tar -xzf "$TMP_DIR/compass.tar.gz" -C "$TMP_DIR"
EXTRACTED_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name '*Compass*' | head -n1)"
[ -n "$EXTRACTED_DIR" ] || die "No se encontró el directorio extraído"

sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p /opt/mongo
sudo mv "$EXTRACTED_DIR" "$INSTALL_DIR"
printf '%s\n' "$VERSION" | sudo tee "$VERSION_FILE" >/dev/null

mkdir -p "$HOME/.local/share/applications"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=MongoDB Compass
Comment=The GUI for MongoDB
Exec=$INSTALL_DIR/MongoDB Compass
Icon=$INSTALL_DIR/resources/app/node_modules/@mongodb-js/compass/dist/main.png
Terminal=false
Type=Application
Categories=Development;Database;
Keywords=mongodb;database;compass;
StartupWMClass=MongoDB Compass
EOF

chmod +x "$DESKTOP_FILE"
