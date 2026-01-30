#!/bin/bash

# Script para configurar asociaciones MIME (aplicaciones por defecto)

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

print_info "==== Configuración de Asociaciones MIME ===="

# Crear directorio de configuración si no existe
mkdir -p "$HOME/.config"

# Configurar aplicaciones por defecto usando xdg-mime
print_info "Configurando aplicaciones por defecto..."

# Imágenes -> imv
for mime in image/jpeg image/png image/gif image/bmp image/webp image/svg+xml; do
    xdg-mime default imv.desktop "$mime" 2>/dev/null || true
done

# Videos -> mpv
for mime in video/mp4 video/x-matroska video/webm video/mpeg video/x-msvideo video/quicktime; do
    xdg-mime default mpv.desktop "$mime" 2>/dev/null || true
done

# Audio -> mpv
for mime in audio/mpeg audio/mp4 audio/x-wav audio/flac audio/ogg audio/x-vorbis+ogg; do
    xdg-mime default mpv.desktop "$mime" 2>/dev/null || true
done

# PDF -> OnlyOffice (por defecto)
print_info "Configurando PDF con OnlyOffice como predeterminado..."
xdg-mime default onlyoffice-desktopeditors.desktop application/pdf 2>/dev/null || true

# Crear archivo de aplicaciones adicionales para PDF
mkdir -p "$HOME/.local/share/applications"

# Crear entrada para Chrome como visor de PDF alternativo
cat > "$HOME/.local/share/applications/chrome-pdf.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome (Visor PDF)
Comment=Abrir PDF con Google Chrome
Exec=google-chrome-stable %U
Icon=google-chrome
Terminal=false
MimeType=application/pdf;
Categories=Office;Viewer;
EOF

print_success "Configuradas opciones para PDF: OnlyOffice (predeterminado) + Chrome (alternativa)"

# Documentos de oficina -> OnlyOffice
# Word
for mime in application/vnd.openxmlformats-officedocument.wordprocessingml.document \
            application/msword \
            application/vnd.oasis.opendocument.text; do
    xdg-mime default onlyoffice-desktopeditors.desktop "$mime" 2>/dev/null || true
done

# Excel
for mime in application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
            application/vnd.ms-excel \
            application/vnd.oasis.opendocument.spreadsheet; do
    xdg-mime default onlyoffice-desktopeditors.desktop "$mime" 2>/dev/null || true
done

# PowerPoint
for mime in application/vnd.openxmlformats-officedocument.presentationml.presentation \
            application/vnd.ms-powerpoint \
            application/vnd.oasis.opendocument.presentation; do
    xdg-mime default onlyoffice-desktopeditors.desktop "$mime" 2>/dev/null || true
done

# Archivos de texto -> Neovim (si está disponible) o editor por defecto
if command -v nvim &> /dev/null; then
    xdg-mime default nvim.desktop text/plain 2>/dev/null || true
fi

print_success "Asociaciones MIME configuradas correctamente"

print_info "Aplicaciones configuradas:"
echo "  • Imágenes (jpg, png, gif, etc.) -> imv"
echo "  • Videos (mp4, mkv, webm, etc.) -> mpv"
echo "  • Audio (mp3, flac, ogg, etc.) -> mpv"
echo "  • PDF -> OnlyOffice (predeterminado)"
echo "       -> Chrome (clic derecho -> Abrir con -> Google Chrome)"
echo "  • Documentos Word/Excel/PowerPoint -> OnlyOffice"
echo "  • Archivos de texto -> Neovim"
