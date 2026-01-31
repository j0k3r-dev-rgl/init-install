#!/bin/bash

# Script para configurar Cloudflare WARP
# Nota: El paquete cloudflare-warp-bin debe estar instalado previamente desde AUR

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

print_info "==== Configuración de Cloudflare WARP ===="

if ! pacman -Qs cloudflare-warp-bin > /dev/null 2>&1; then
    print_info "Cloudflare WARP no está instalado, saltando configuración..."
    exit 0
fi

print_info "Habilitando servicio warp-svc..."
sudo systemctl enable --now warp-svc

print_info "Esperando a que el servicio inicie correctamente..."
sleep 5

if command -v warp-cli >/dev/null 2>&1; then
    if ! warp-cli settings > /dev/null 2>&1; then
        print_info "Registrando nuevo cliente WARP (Aceptando TOS)..."
        echo "y" | warp-cli registration new
        sleep 2
    fi

    # Preguntar si desea habilitar WARP ahora o después
    ENABLE_NOW=false
    if [ -t 0 ] && [ -t 1 ]; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║         Configuración de Cloudflare WARP              ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "¿Deseas habilitar y conectar WARP ahora?"
        echo ""
        echo "Opciones:"
        echo "  1) Sí - Habilitar y conectar WARP ahora"
        echo "  2) No - Configurar pero no conectar (puedes hacerlo después)"
        echo ""
        echo -n "Selecciona una opción (1/2, por defecto: 1): "
        read -r warp_choice
        case "$warp_choice" in
            2|[nN]|[nN][oO])
                ENABLE_NOW=false
                print_info "WARP se configurará pero no se conectará automáticamente."
                ;;
            *)
                ENABLE_NOW=true
                ;;
        esac
    else
        # En modo no interactivo, configurar pero no conectar
        ENABLE_NOW=false
    fi

    # Configurar modo WARP
    print_info "Configurando modo WARP..."
    warp-cli mode warp

    # Conectar si el usuario lo solicitó
    if [ "$ENABLE_NOW" = true ]; then
        print_info "Conectando a WARP..."
        warp-cli connect
        print_success "WARP conectado y activo."
    else
        print_info "WARP configurado pero no conectado."
    fi

    # Configurar autostart en Hyprland
    HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
    mkdir -p "$(dirname "$HYPR_CONF")"
    touch "$HYPR_CONF"

    if ! grep -q "warp-cli connect" "$HYPR_CONF"; then
        if [ -t 0 ] && [ -t 1 ] && [ "$ENABLE_NOW" = true ]; then
            echo ""
            echo -n "¿Deseas que WARP se inicie automáticamente con Hyprland? (s/n, por defecto: s): "
            read -r autostart_choice
            case "$autostart_choice" in
                [nN]|[nN][oO])
                    print_info "No se agregará autostart de WARP a Hyprland."
                    ;;
                *)
                    print_info "Agregando inicio automático a Hyprland..."
                    echo "" >> "$HYPR_CONF"
                    echo "# Cloudflare WARP Auto-Connect" >> "$HYPR_CONF"
                    echo "exec-once = warp-cli connect" >> "$HYPR_CONF"
                    print_success "Autostart de WARP agregado a Hyprland."
                    ;;
            esac
        fi
    else
        print_info "La configuración de Hyprland ya incluye WARP."
    fi

    print_success "Configuración de Cloudflare WARP completada."
else
    die "Se instaló cloudflare-warp-bin pero no se encontró warp-cli en PATH."
fi
