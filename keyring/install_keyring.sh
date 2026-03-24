#!/bin/bash

# Script de instalación de GNOME Keyring (Secret Service API)
# Este script instala y configura el sistema de llavero de contraseñas estándar de Linux

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

KEEPASSXC_DIR="$HOME/.config/keepassxc"
KEEPASSXC_BACKUP_DIR="$HOME/.local/share/keyrings/keepassxc-backup"
HYPR_CONFIG="$HOME/.config/hypr"

# Detectar ruta de configs - puede ser ~/.config/hypr/ o ~/.config/hypr/configs/
if [ -f "$HYPR_CONFIG/environment.conf" ]; then
    ENV_FILE="$HYPR_CONFIG/environment.conf"
    AUTOSTART_FILE="$HYPR_CONFIG/autostart.conf"
elif [ -f "$HYPR_CONFIG/configs/environment.conf" ]; then
    ENV_FILE="$HYPR_CONFIG/configs/environment.conf"
    AUTOSTART_FILE="$HYPR_CONFIG/configs/autostart.conf"
else
    ENV_FILE=""
    AUTOSTART_FILE=""
fi

print_info() {
    echo -e "${GREEN}[KEYRING]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

require_arch() {
    command -v pacman >/dev/null 2>&1 || die "No es Arch Linux"
}

backup_keepassxc_data() {
    if [ ! -d "$KEEPASSXC_DIR" ]; then
        print_info "No se encontró configuración de KeePassXC para respaldar"
        return
    fi

    mkdir -p "$KEEPASSXC_BACKUP_DIR"
    cp -an "$KEEPASSXC_DIR" "$KEEPASSXC_BACKUP_DIR/"
    print_info "Backup de KeePassXC guardado en $KEEPASSXC_BACKUP_DIR"
}

uninstall_keepassxc() {
    if pacman -Q keepassxc >/dev/null 2>&1; then
        print_info "Removiendo keepassxc por conflicto con GNOME Keyring..."
        sudo pacman -Rns --noconfirm keepassxc >/dev/null || die "No se pudo desinstalar keepassxc"
    else
        print_info "keepassxc no está instalado"
    fi
}

install_gnome_keyring_stack() {
    print_info "Instalando GNOME Keyring y componentes relacionados..."

    print_info "Instalando gnome-keyring, libsecret y seahorse..."
    sudo pacman -S --needed --noconfirm gnome-keyring libsecret seahorse >/dev/null || die "No se pudo instalar gnome-keyring"

    print_info "Instalando gcr-4 para soporte de SSH..."
    sudo pacman -S --needed --noconfirm gcr-4 >/dev/null || die "No se pudo instalar gcr-4"
}

configure_hyprland_keyring() {
    if [ -z "$ENV_FILE" ] || [ ! -f "$ENV_FILE" ]; then
        print_info "Hyprland no detectado, saltando configuración de entorno"
        return
    fi

    print_info "Configurando GNOME Keyring en Hyprland..."

    # Configurar environment.conf si existe
    if [ -f "$ENV_FILE" ]; then
        if ! grep -q 'GNOME_KEYRING_CONTROL' "$ENV_FILE"; then
            print_info "Agregando variables de entorno de GNOME Keyring..."
            cat >> "$ENV_FILE" <<'EOF'

# GNOME Keyring
env = GNOME_KEYRING_CONTROL,/run/user/1000/keyring
EOF
        fi
    fi

    # Configurar autostart.conf si existe
    if [ -f "$AUTOSTART_FILE" ]; then
        if ! grep -q 'gnome-keyring-daemon --start' "$AUTOSTART_FILE"; then
            print_info "Agregando gnome-keyring-daemon al autostart..."
            cat >> "$AUTOSTART_FILE" <<'EOF'

# GNOME Keyring Daemon
exec-once = dbus-update-activation-environment --all
exec-once = gnome-keyring-daemon --start --components=secrets
EOF
        fi
    fi

    print_info "Entorno de GNOME Keyring configurado para Hyprland"
}

enable_ssh_agent() {
    print_info "Habilitando SSH Agent de GNOME Keyring..."

    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user enable --now gcr-ssh-agent.socket 2>/dev/null || print_warning "No se pudo habilitar gcr-ssh-agent.socket"
        print_info "SSH Agent habilitado"
    else
        print_warning "systemctl no disponible,SSH Agent deberá iniciarse manualmente"
    fi
}

print_restore_summary() {
    echo ""
    echo "=========================================="
    echo "MIGRACIÓN COMPLETA"
    echo "=========================================="
    echo "Backup de KeePassXC: $KEEPASSXC_BACKUP_DIR"
    echo "Para importar manualmente en GNOME Keyring:"
    echo "  1. Abrir Seahorse"
    echo "  2. Crear o desbloquear el keyring deseado"
    echo "  3. Importar o recrear las contraseñas desde el backup de KeePassXC"
    echo "=========================================="
}

main() {
    require_arch
    backup_keepassxc_data
    uninstall_keepassxc
    install_gnome_keyring_stack
    configure_hyprland_keyring
    enable_ssh_agent

    print_info ""
    print_info "=========================================="
    print_info "INSTALACIÓN COMPLETA"
    print_info "=========================================="
    print_info ""
    print_info "Componentes instalados:"
    print_info "  • gnome-keyring: Servicio de llavero de contraseñas"
    print_info "  • libsecret: API Secret Service (org.freedesktop.secrets)"
    print_info "  • seahorse: Interfaz gráfica para gestionar contraseñas"
    print_info "  • gcr-4: Soporte para SSH agent"
    print_info ""
    print_info "Configuración realizada:"
    print_info "  • Variables de entorno en Hyprland (si estaba instalado)"
    print_info "  • Autostart del daemon de GNOME Keyring"
    print_info "  • SSH Agent habilitado"
    print_info ""
    print_warning "Si tenías contraseñas en KeePassXC, importalas manualmente desde el backup"
    print_restore_summary
}

main "$@"
