#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

DISCORD_FLAGS="--enable-features=WebRTCPipeWireCapturer --ozone-platform-hint=auto"
DISCORD_EXEC="/usr/bin/discord ${DISCORD_FLAGS} %U"
SYSTEM_DESKTOP="/usr/share/applications/discord.desktop"
USER_DESKTOP="$HOME/.local/share/applications/discord.desktop"
USER_APPLICATIONS_DIR="$(dirname "$USER_DESKTOP")"

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

install_packages() {
    print_info "Instalando Discord y dependencias para compartir pantalla en Wayland..."
    sudo pacman -S --needed --noconfirm \
        discord \
        pipewire \
        pipewire-alsa \
        pipewire-pulse \
        wireplumber \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk \
        xdg-desktop-portal-wlr

    if command -v Hyprland >/dev/null 2>&1 || command -v hyprctl >/dev/null 2>&1 || pacman -Q hyprland >/dev/null 2>&1; then
        print_info "Hyprland detectado; instalando portal específico..."
        sudo pacman -S --needed --noconfirm xdg-desktop-portal-hyprland
    fi
}

create_minimal_launcher() {
    cat > "$USER_DESKTOP" <<EOF
[Desktop Entry]
Name=Discord
Comment=All-in-one voice and text chat
Exec=$DISCORD_EXEC
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=discord
EOF
}

set_launcher_exec() {
    local tmp_file
    tmp_file="$(mktemp)"

    awk -v exec_line="Exec=$DISCORD_EXEC" '
        BEGIN { in_desktop_entry = 0; replaced = 0 }
        /^\[Desktop Entry\]$/ { in_desktop_entry = 1 }
        /^\[/ && $0 != "[Desktop Entry]" { in_desktop_entry = 0 }
        in_desktop_entry && /^Exec=/ && replaced == 0 { print exec_line; replaced = 1; next }
        { print }
        END { if (replaced == 0) print exec_line }
    ' "$USER_DESKTOP" > "$tmp_file"

    mv "$tmp_file" "$USER_DESKTOP"
}

ensure_startup_wm_class() {
    if ! grep -q '^StartupWMClass=' "$USER_DESKTOP"; then
        printf '\nStartupWMClass=discord\n' >> "$USER_DESKTOP"
    fi
}

configure_launcher() {
    print_info "Configurando launcher de Discord con soporte PipeWire..."
    mkdir -p "$USER_APPLICATIONS_DIR"

    if [ -f "$SYSTEM_DESKTOP" ]; then
        cp "$SYSTEM_DESKTOP" "$USER_DESKTOP"
        set_launcher_exec
        ensure_startup_wm_class
    else
        create_minimal_launcher
    fi

    chmod 644 "$USER_DESKTOP"

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$USER_APPLICATIONS_DIR" >/dev/null 2>&1 || true
    fi

    print_success "Launcher creado en $USER_DESKTOP"
}

require_cmd sudo
require_cmd pacman
require_cmd awk
require_cmd mktemp

install_packages
configure_launcher

print_success "Discord listo para compartir pantalla con PipeWire"
