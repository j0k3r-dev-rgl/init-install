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

echo -e "${GREEN}Consultando última versión de Windsurf...${NC}"

ensure_pkg jq jq
ensure_pkg curl curl
require_cmd tar

VERSION_INFO="$(curl -fsSL "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest")"
DOWNLOAD_URL="$(echo "$VERSION_INFO" | jq -r '.url')"
LATEST_VERSION="$(echo "$VERSION_INFO" | jq -r '.windsurfVersion')"

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    die "No se pudo obtener la URL de descarga."
fi

echo -e "${GREEN}Versión encontrada: $LATEST_VERSION${NC}"

TEMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

echo -e "${GREEN}Descargando en $TEMP_DIR...${NC}"
curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/windsurf.tar.gz"

sudo mkdir -p /opt/windsurf
sudo tar -xzf "$TEMP_DIR/windsurf.tar.gz" -C /opt/windsurf --strip-components=1

BIN_PATH=""
if [ -x /opt/windsurf/windsurf ]; then
    BIN_PATH="/opt/windsurf/windsurf"
elif [ -x /opt/windsurf/Windsurf ]; then
    BIN_PATH="/opt/windsurf/Windsurf"
else
    BIN_PATH="$(sudo find /opt/windsurf -maxdepth 2 -type f -iname 'windsurf*' -perm -111 2>/dev/null | head -n 1 || true)"
fi

if [ -z "$BIN_PATH" ]; then
    echo "Aviso: no pude detectar el binario principal de Windsurf automáticamente."
    BIN_PATH="/opt/windsurf/windsurf"
fi

ICON_PATH=""
ICON_PATH="$(sudo find /opt/windsurf -type f \( -iname '*windsurf*.png' -o -iname '*windsurf*.svg' -o -iname '*codeium*.png' \) 2>/dev/null | head -n 1 || true)"

mkdir -p "$HOME/.local/share/applications"
DESKTOP_FILE="$HOME/.local/share/applications/windsurf.desktop"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Windsurf
Comment=Windsurf Editor
Exec=$BIN_PATH
Icon=${ICON_PATH:-windsurf}
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF

sudo ln -sf "$BIN_PATH" /usr/local/bin/windsurf || true

echo -e "${GREEN}¡Instalación de Windsurf $LATEST_VERSION completada!${NC}"
echo "Desktop: $DESKTOP_FILE"
echo "Si no aparece en el menú, ejecuta: update-desktop-database ~/.local/share/applications (si tenés desktop-file-utils)"
