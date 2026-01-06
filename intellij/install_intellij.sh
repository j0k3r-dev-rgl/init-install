#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

ensure_pkg() {
    pkg="$1"
    cmd="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            die "No se encontró '$cmd' y no puedo instalarlo automáticamente (pacman no encontrado)."
        fi
    fi
}

echo -e "${GREEN}Buscando la última versión de IntelliJ IDEA...${NC}"

ensure_pkg jq jq
ensure_pkg curl curl
require_cmd tar

JSON_DATA="$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release")"

VERSION="$(echo "$JSON_DATA" | jq -r '.IIU[0].version')"
DOWNLOAD_URL="$(echo "$JSON_DATA" | jq -r '.IIU[0].downloads.linux.link')"

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    die "No se pudo encontrar la URL de descarga para Linux."
fi

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    VERSION="unknown"
fi

echo -e "${GREEN}Versión detectada: $VERSION${NC}"

TEMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

TARBALL="$TEMP_DIR/intellij.tar.gz"

echo -e "${GREEN}Descargando...${NC}"
curl -L "$DOWNLOAD_URL" -o "$TARBALL"

sudo mkdir -p /opt/intellij

echo -e "${GREEN}Extrayendo en /opt/intellij...${NC}"
sudo tar -xzf "$TARBALL" -C /opt/intellij --strip-components=1

IDEA_BIN="/opt/intellij/bin/idea.sh"
if [ ! -f "$IDEA_BIN" ]; then
    IDEA_BIN="/opt/intellij/bin/idea"
fi

sudo ln -sf "$IDEA_BIN" /usr/local/bin/idea || true

ICON_PATH=""
ICON_PATH="$(sudo find /opt/intellij -type f \( -iname 'idea.png' -o -iname 'idea.svg' -o -iname '*idea*.png' -o -iname '*idea*.svg' \) 2>/dev/null | head -n 1 || true)"

mkdir -p "$HOME/.local/share/applications"
DESKTOP_FILE="$HOME/.local/share/applications/intellij-idea.desktop"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=IntelliJ IDEA
Comment=JetBrains IntelliJ IDEA
Exec=$IDEA_BIN
Icon=${ICON_PATH:-intellij-idea}
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF

mkdir -p "$HOME/.local/share/kio/servicemenus"
SERVICE_MENU="$HOME/.local/share/kio/servicemenus/intellij.desktop"

cat > "$SERVICE_MENU" <<EOF
[Desktop Entry]
Type=Service
ServiceTypes=KonqPopupMenu/Plugin
MimeType=all/all;inode/directory;
Actions=openInIntelliJ
X-KDE-Priority=TopLevel

[Desktop Action openInIntelliJ]
Name=Abrir con IntelliJ IDEA
Icon=/opt/intellij/bin/idea.svg
Exec=/opt/intellij/bin/idea.sh %u
EOF

chmod +x "$SERVICE_MENU" || true

echo -e "${GREEN}¡IntelliJ IDEA $VERSION instalado con éxito!${NC}"
echo "Comando: idea"
echo "Desktop: $DESKTOP_FILE"
