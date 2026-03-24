#!/bin/bash

set -euo pipefail

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

INSTALL_DIR="/opt/intellij"
VERSION_FILE="$INSTALL_DIR/.version"
BIN_DIR="$HOME/.local/bin"
UPDATE_SCRIPT="$BIN_DIR/intellij-update"
CONFIG_DIR="$HOME/.config/JetBrains/IntelliJIdea2024.2"
BACKUP_DIR="$HOME/.local/share/intellij-backup"

ASSUME_YES=false
USER_UID="$(id -u)"
USER_GID="$(id -g)"

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

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -y|--yes)
                ASSUME_YES=true
                ;;
            -h|--help)
                cat <<EOF
Uso: ${0##*/} [--yes|-y]

Opciones:
  -y, --yes    Actualiza sin pedir confirmación
  -h, --help   Muestra esta ayuda
EOF
                exit 0
                ;;
            *)
                die "Opción desconocida: $1"
                ;;
        esac
        shift
    done
}

install_update_script() {
    local script_source=""
    local source_path="${BASH_SOURCE[0]}"

    if command -v readlink >/dev/null 2>&1; then
        script_source="$(readlink -f "$source_path" 2>/dev/null || printf '%s' "$source_path")"
    else
        script_source="$source_path"
    fi

    mkdir -p "$BIN_DIR"

    if [ ! -f "$UPDATE_SCRIPT" ] || [ "$script_source" != "$UPDATE_SCRIPT" ]; then
        cp -f "$script_source" "$UPDATE_SCRIPT"
        chmod +x "$UPDATE_SCRIPT"
        print_info "Script de actualización instalado en $UPDATE_SCRIPT"
    fi
}

confirm_update() {
    if [ "$ASSUME_YES" = true ]; then
        return 0
    fi

    echo "¿Deseas actualizar? [s/N]"

    local response=""
    read -r response
    if [ "$response" != "s" ] && [ "$response" != "S" ]; then
        print_info "Actualización cancelada"
        exit 0
    fi
}

main() {
    local current_version=""
    local json_data=""
    local latest_version=""
    local download_url=""
    local temp_dir=""
    local tarball=""
    local newest_version=""
    local sorted_versions=()

    parse_args "$@"
    install_update_script

    require_arch
    ensure_pkg jq jq
    ensure_pkg curl curl
    require_cmd sort
    require_cmd tar
    require_cmd mktemp

    if [ ! -d "$INSTALL_DIR" ]; then
        die "IntelliJ IDEA no está instalado en $INSTALL_DIR"
    fi

    if [ ! -f "$VERSION_FILE" ]; then
        die "No se encontró archivo de versión. IntelliJ puede no estar correctamente instalado."
    fi

    IFS= read -r current_version < "$VERSION_FILE"
    [ -n "$current_version" ] || die "No se pudo leer la versión actual de IntelliJ IDEA"

    print_info "Versión actual de IntelliJ IDEA: $current_version"

    json_data="$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release")"
    latest_version="$(printf '%s' "$json_data" | jq -r '.IIU[0].version')"
    download_url="$(printf '%s' "$json_data" | jq -r '.IIU[0].downloads.linux.link')"

    if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
        die "No se pudo obtener la última versión desde JetBrains"
    fi

    if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
        die "No se pudo obtener la URL de descarga desde JetBrains"
    fi

    print_info "Última versión disponible: $latest_version"

    mapfile -t sorted_versions < <(printf '%s\n%s\n' "$current_version" "$latest_version" | sort -V)
    newest_version="${sorted_versions[${#sorted_versions[@]}-1]}"

    if [ "$current_version" = "$latest_version" ] || [ "$newest_version" = "$current_version" ]; then
        print_info "IntelliJ IDEA ya está en la última versión ($current_version)"
        exit 0
    fi

    print_warning "Hay una nueva versión disponible: $latest_version (actual: $current_version)"
    confirm_update

    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT
    tarball="$temp_dir/intellij.tar.gz"

    print_info "Descargando IntelliJ IDEA $latest_version..."
    curl -fL "$download_url" -o "$tarball"

    if [ -d "$CONFIG_DIR" ]; then
        print_info "Respaldando configuración..."
        rm -rf "$BACKUP_DIR"
        mkdir -p "$(dirname "$BACKUP_DIR")"
        cp -an "$CONFIG_DIR" "$BACKUP_DIR/"
    fi

    print_info "Instalando nueva versión..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo rm -rf "$INSTALL_DIR"/*
    sudo tar -xzf "$tarball" -C "$INSTALL_DIR" --strip-components=1
    printf '%s\n' "$latest_version" | sudo tee "$VERSION_FILE" >/dev/null
    sudo chown -R "$USER_UID:$USER_GID" "$INSTALL_DIR"

    if [ -d "$BACKUP_DIR" ]; then
        print_info "Restaurando configuración..."
        mkdir -p "$CONFIG_DIR"
        cp -an "$BACKUP_DIR/." "$CONFIG_DIR/"
    fi

    print_info "¡IntelliJ IDEA actualizado a $latest_version!"
}

main "$@"
