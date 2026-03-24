#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="/opt/intellij"
VERSION_FILE="$INSTALL_DIR/.version"
DESKTOP_FILE="$HOME/.local/share/applications/intellij-idea.desktop"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT_SRC="$SCRIPT_DIR/update_intellij.sh"
BIN_DIR="$HOME/.local/bin"

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

require_arch() {
    command -v pacman >/dev/null 2>&1 || die "No es Arch Linux o pacman no está disponible"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

ensure_pkg() {
    local pkg="$1"
    local cmd="$2"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        require_arch
        print_info "Instalando dependencia faltante: $pkg"
        sudo pacman -S --needed --noconfirm "$pkg" >/dev/null || die "No se pudo instalar $pkg"
    fi
}

main() {
    local json_data=""
    local version=""
    local download_url=""
    local temp_dir=""
    local tarball=""
    local current_version=""
    local idea_bin=""
    local icon_path=""

    print_info "Buscando la última versión de IntelliJ IDEA..."

    require_arch
    ensure_pkg jq jq
    ensure_pkg curl curl
    require_cmd tar

    json_data="$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release")"
    version="$(printf '%s' "$json_data" | jq -r '.IIU[0].version')"
    download_url="$(printf '%s' "$json_data" | jq -r '.IIU[0].downloads.linux.link')"

    [ -n "$download_url" ] && [ "$download_url" != "null" ] || die "No se pudo encontrar la URL de descarga para Linux"

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        version="unknown"
        print_warning "No se pudo detectar la versión exacta; se usará '$version'"
    fi

    print_info "Versión detectada: $version"

    if sudo test -f "$VERSION_FILE"; then
        current_version="$(sudo cat "$VERSION_FILE")"
        if [ "$current_version" = "$version" ]; then
            print_info "IntelliJ IDEA $version ya está instalado; no se realizarán cambios"
            exit 0
        fi
        print_info "Actualizando IntelliJ IDEA de $current_version a $version"
    fi

    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT
    tarball="$temp_dir/intellij.tar.gz"

    print_info "Descargando IntelliJ IDEA..."
    curl -fL "$download_url" -o "$tarball"

    print_info "Instalando en $INSTALL_DIR..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo rm -rf "$INSTALL_DIR"/*
    sudo tar -xzf "$tarball" -C "$INSTALL_DIR" --strip-components=1
    printf '%s\n' "$version" | sudo tee "$VERSION_FILE" >/dev/null

    idea_bin="$INSTALL_DIR/bin/idea.sh"
    if [ ! -f "$idea_bin" ]; then
        idea_bin="$INSTALL_DIR/bin/idea"
    fi
    [ -f "$idea_bin" ] || die "No se encontró el ejecutable de IntelliJ IDEA"

    if sudo ln -sf "$idea_bin" /usr/local/bin/idea; then
        print_info "Comando global 'idea' actualizado"
    else
        print_warning "No se pudo crear el enlace simbólico en /usr/local/bin/idea"
    fi

    icon_path="$(find "$INSTALL_DIR" -type f \( -iname 'idea.png' -o -iname 'idea.svg' -o -iname '*idea*.png' -o -iname '*idea*.svg' \) 2>/dev/null | head -n 1 || true)"
    if [ -z "$icon_path" ]; then
        icon_path="intellij-idea"
        print_warning "No se encontró un ícono local; se usará '$icon_path'"
    fi

    mkdir -p "$HOME/.local/share/applications"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=IntelliJ IDEA
Comment=JetBrains IntelliJ IDEA
Exec=$idea_bin
Icon=$icon_path
Terminal=false
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=jetbrains-idea
EOF

    chmod +x "$DESKTOP_FILE"

    # Instalar script de actualización
    mkdir -p "$BIN_DIR"
    if [ -f "$UPDATE_SCRIPT_SRC" ]; then
        cp -an "$UPDATE_SCRIPT_SRC" "$BIN_DIR/intellij-update"
        chmod +x "$BIN_DIR/intellij-update"
        print_info "Script de actualización instalado: intellij-update"
    fi

    print_success "¡IntelliJ IDEA $version instalado con éxito!"
    print_info "Comando: idea"
    print_info "Desktop: $DESKTOP_FILE"
    print_info "Actualizador: intellij-update (en ~/.local/bin/)"
}

main "$@"
