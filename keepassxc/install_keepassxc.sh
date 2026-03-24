#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="$HOME/.config/keepassxc/gnome-keyring-backup"
KEYRING_DIR="$HOME/.local/share/keyrings"
KEEPASSXC_DIR="$HOME/.config/keepassxc"
KEEPASSXC_DB="$KEEPASSXC_DIR/passwords.kdbx"
HAS_PASSWORDS=0

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
    command -v pacman >/dev/null 2>&1 || die "No es Arch Linux"
}

ensure_keepassxc_config_dir() {
    if [ -d "$KEEPASSXC_DIR" ]; then
        print_info "Configuración existente de KeePassXC preservada"
    else
        mkdir -p "$KEEPASSXC_DIR"
        print_info "Directorio de configuración de KeePassXC creado"
    fi
}

backup_gnome_keyring() {
    mkdir -p "$BACKUP_DIR"

    if [ -d "$KEYRING_DIR" ]; then
        cp -an "$KEYRING_DIR" "$BACKUP_DIR/"
        print_info "Backup guardado en $BACKUP_DIR"
    else
        print_info "No se encontró directorio de GNOME Keyring para respaldar"
    fi
}

detect_saved_passwords() {
    if [ -f "$KEYRING_DIR/login.keyring" ] || [ -f "$KEYRING_DIR/user.keystore" ]; then
        print_info "Detectadas contraseñas guardadas"
        HAS_PASSWORDS=1
    else
        HAS_PASSWORDS=0
        print_info "No se detectaron contraseñas guardadas en GNOME Keyring"
    fi
}

uninstall_gnome_keyring_stack() {
    if ! pacman -Qq gnome-keyring seahorse gcr-4 2>/dev/null | grep -q .; then
        print_info "No hay paquetes de GNOME Keyring instalados"
        return
    fi

    print_info "Desinstalando GNOME Keyring stack..."
    sudo sh -c 'pacman --nodeps --noconfirm -Rdd  gcr-4 seahorse gnome-keyring' || true
}

install_keepassxc_stack() {
    print_info "Instalando KeePassXC, libsecret y qt5-wayland..."
    sudo pacman -S --needed --noconfirm keepassxc libsecret qt5-wayland >/dev/null || die "No se pudo instalar KeePassXC"
}

migrate_passwords_to_keepassxc() {
    local source_file=""

    if [ "$HAS_PASSWORDS" != "1" ]; then
        return
    fi

    echo "Intentando migrar contraseñas a KeePassXC..."

    if [ -f "$BACKUP_DIR/keyrings/login.keyring" ]; then
        source_file="$BACKUP_DIR/keyrings/login.keyring"
    elif [ -f "$KEYRING_DIR/login.keyring" ]; then
        source_file="$KEYRING_DIR/login.keyring"
    fi

    if ! command -v keepassxc-cli >/dev/null 2>&1; then
        print_warning "keepassxc-cli no está disponible; la migración deberá hacerse manualmente"
        return
    fi

    if [ -z "$source_file" ]; then
        print_warning "No se encontró login.keyring para intentar la migración automática"
        return
    fi

    if keepassxc-cli import "$source_file" "$KEEPASSXC_DB" 2>/dev/null; then
        print_success "Migración exitosa"
    else
        print_warning "Migración falló, backup disponible"
    fi
}

print_migration_summary() {
    echo ""
    echo "=========================================="
    echo "MIGRACIÓN COMPLETA"
    echo "=========================================="
    echo "Backup de GNOME Keyring: $BACKUP_DIR"
    echo "Para importar manualmente:"
    echo "  1. Abrir KeePassXC"
    echo "  2. File > Import > GNOME Keyring"
    echo "  3. Seleccionar archivo de backup"
    echo "=========================================="
}

main() {
    require_arch
    ensure_keepassxc_config_dir
    backup_gnome_keyring
    detect_saved_passwords
    uninstall_gnome_keyring_stack
    install_keepassxc_stack
    migrate_passwords_to_keepassxc

    print_success "KeePassXC instalado"
    print_info "Ejecuta KeePassXC para configurar SSH Agent:"
    print_info "  Config > SSH Agent > Enable SSH Agent"
    print_migration_summary
}

main "$@"
