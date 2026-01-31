#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

trap 'die "El script falló en la línea $LINENO"' ERR

require_cmd sudo
require_cmd bash

if ! command -v pacman >/dev/null 2>&1; then
    die "Este script está pensado para Arch/derivados (pacman no encontrado)."
fi

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Iniciando instalación y configuración del sistema    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"

# ==============================================================================
# PASO 0: LIMPIEZA PREVIA (OPCIONAL)
# ==============================================================================
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas limpiar configuraciones anteriores de ZSH/Oh My Zsh/Powerlevel10k? (s/n, por defecto: n): "
    read -r clean_response
    case "$clean_response" in
        [sS]|[sS][iI])
            echo -e "${GREEN}Realizando limpieza previa...${NC}"
            rm -rf "$HOME/.oh-my-zsh" "$HOME/.p10k.zsh" "$HOME/.zshrc"
            echo -e "${GREEN}Limpieza completada.${NC}"
            ;;
        *)
            echo -e "${GREEN}Omitiendo limpieza previa.${NC}"
            ;;
    esac
fi

# ==============================================================================
# PASO 1: ACTUALIZACIÓN DEL SISTEMA Y DEPENDENCIAS BASE
# ==============================================================================
echo -e "\n${GREEN}[PASO 1/12] Actualizando sistema e instalando dependencias base...${NC}"
sudo -v
sudo pacman -Syu --noconfirm
pacman_install git curl base-devel grim slurp wl-clipboard pciutils

require_cmd git
require_cmd curl

# ==============================================================================
# PASO 2: INSTALACIÓN DE SERVICIOS DEL SISTEMA (DRIVERS Y UTILIDADES)
# ==============================================================================
echo -e "\n${GREEN}[PASO 2/12] Instalando drivers y utilidades del sistema...${NC}"

# 2.1. NetworkManager
NETWORK_INSTALLER="$SCRIPT_DIR/drivers_utilities/network_install.sh"
if [ -f "$NETWORK_INSTALLER" ]; then
    chmod +x "$NETWORK_INSTALLER" 2>/dev/null || true
    bash "$NETWORK_INSTALLER"
else
    print_info "Instalador de NetworkManager no encontrado, saltando..."
fi

# 2.2. Sistema de audio PipeWire
AUDIO_INSTALLER="$SCRIPT_DIR/drivers_utilities/audio_install.sh"
if [ -f "$AUDIO_INSTALLER" ]; then
    chmod +x "$AUDIO_INSTALLER" 2>/dev/null || true
    bash "$AUDIO_INSTALLER"
else
    print_info "Instalador de PipeWire no encontrado, saltando..."
fi

# 2.3. Códecs de video y multimedia
CODECS_INSTALLER="$SCRIPT_DIR/drivers_utilities/codecs_install.sh"
if [ -f "$CODECS_INSTALLER" ]; then
    chmod +x "$CODECS_INSTALLER" 2>/dev/null || true
    bash "$CODECS_INSTALLER"
else
    print_info "Instalador de códecs no encontrado, saltando..."
fi

# ==============================================================================
# PASO 3: DETECCIÓN Y CONFIGURACIÓN DE HARDWARE
# ==============================================================================
echo -e "\n${GREEN}[PASO 3/12] Detectando hardware e instalando drivers...${NC}"

# 3.1. Instalación de microcódigo de CPU (AMD/Intel)
CPU_INSTALLER="$SCRIPT_DIR/drivers_utilities/cpu_microcode_install.sh"
if [ -f "$CPU_INSTALLER" ]; then
    chmod +x "$CPU_INSTALLER" 2>/dev/null || true
    bash "$CPU_INSTALLER"
else
    print_info "Instalador de microcódigo de CPU no encontrado, saltando..."
fi

# 3.2. Instalación de drivers de GPU (NVIDIA/AMD/Intel)
GPU_INSTALLER="$SCRIPT_DIR/drivers_utilities/gpu_drivers_install.sh"
if [ -f "$GPU_INSTALLER" ]; then
    chmod +x "$GPU_INSTALLER" 2>/dev/null || true
    bash "$GPU_INSTALLER"
else
    print_info "Instalador de drivers de GPU no encontrado, saltando..."
fi

# ==============================================================================
# PASO 4: INSTALACIÓN DE YAY (AUR HELPER)
# ==============================================================================
echo -e "\n${GREEN}[PASO 4/12] Instalando Yay (AUR Helper)...${NC}"

if ! command -v yay &> /dev/null; then
    print_info "Instalando yay..."
    tmp_dir="$(mktemp -d)"
    cleanup() { rm -rf "$tmp_dir"; }
    trap cleanup EXIT
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    trap - EXIT
    cleanup
    print_success "Yay instalado correctamente"
else
    print_success "Yay ya está instalado, saltando..."
fi

# ==============================================================================
# PASO 5: INSTALACIÓN DE PAQUETES DESDE AUR
# ==============================================================================
echo -e "\n${GREEN}[PASO 5/12] Instalando paquetes desde AUR...${NC}"

YAY_INSTALLER="$SCRIPT_DIR/yay_install/install_yay_packages.sh"
if [ -f "$YAY_INSTALLER" ]; then
    chmod +x "$YAY_INSTALLER" 2>/dev/null || true
    bash "$YAY_INSTALLER"
else
    print_info "No se encontró el instalador de paquetes AUR, saltando..."
fi

# ==============================================================================
# PASO 6: INSTALACIÓN DE FUENTES
# ==============================================================================
echo -e "\n${GREEN}[PASO 6/12] Instalando fuentes (TTF e iconos)...${NC}"
pacman_install ttf-font-awesome ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-liberation ttf-dejavu

# ==============================================================================
# PASO 6.5: INSTALACIÓN Y CONFIGURACIÓN DEL LLAVERO DE CONTRASEÑAS
# ==============================================================================
echo -e "\n${GREEN}[PASO 6.5/13] Configurando llavero de contraseñas (GNOME Keyring)...${NC}"

# 6.5.1. Instalación de GNOME Keyring
KEYRING_INSTALLER="$SCRIPT_DIR/keyring/install_keyring.sh"
if [ -f "$KEYRING_INSTALLER" ]; then
    chmod +x "$KEYRING_INSTALLER" 2>/dev/null || true
    bash "$KEYRING_INSTALLER"
else
    print_info "Instalador de GNOME Keyring no encontrado, saltando..."
fi

# 6.5.2. Configuración de PAM y autostart
KEYRING_CONFIGURATOR="$SCRIPT_DIR/keyring/configure_keyring.sh"
if [ -f "$KEYRING_CONFIGURATOR" ]; then
    chmod +x "$KEYRING_CONFIGURATOR" 2>/dev/null || true
    bash "$KEYRING_CONFIGURATOR"
else
    print_info "Configurador de GNOME Keyring no encontrado, saltando..."
fi

# ==============================================================================
# PASO 7: INSTALACIÓN DE ENTORNO GRÁFICO Y APLICACIONES
# ==============================================================================
echo -e "\n${GREEN}[PASO 7/13] Instalando entorno gráfico y aplicaciones...${NC}"

# 7.1. Hyprland
HYPRLAND_INSTALLER="$SCRIPT_DIR/hyprland/install_hyprland.sh"
if [ -f "$HYPRLAND_INSTALLER" ]; then
    chmod +x "$HYPRLAND_INSTALLER" 2>/dev/null || true
    bash "$HYPRLAND_INSTALLER"
else
    print_info "Instalador de Hyprland no encontrado, saltando..."
fi

# 7.2. Aplicaciones de escritorio (gestor de archivos, visor de imágenes, reproductor de video)
DESKTOP_APPS_INSTALLER="$SCRIPT_DIR/desktop_apps/install_desktop_apps.sh"
if [ -f "$DESKTOP_APPS_INSTALLER" ]; then
    chmod +x "$DESKTOP_APPS_INSTALLER" 2>/dev/null || true
    bash "$DESKTOP_APPS_INSTALLER"
else
    print_info "Instalador de aplicaciones de escritorio no encontrado, saltando..."
fi

# 7.3. Rofi (lanzador de aplicaciones)
ROFI_INSTALLER="$SCRIPT_DIR/rofi/install_rofi.sh"
if [ -f "$ROFI_INSTALLER" ]; then
    chmod +x "$ROFI_INSTALLER" 2>/dev/null || true
    bash "$ROFI_INSTALLER"
else
    print_info "Instalador de Rofi no encontrado, saltando..."
fi

# ==============================================================================
# PASO 8: INSTALACIÓN Y CONFIGURACIÓN DE ZSH
# ==============================================================================
echo -e "\n${GREEN}[PASO 8/13] Configurando ZSH como shell por defecto...${NC}"

# 8.1. Instalación de ZSH, Oh My Zsh, plugins y Powerlevel10k
ZSH_INSTALLER="$SCRIPT_DIR/zsh/install_zsh.sh"
if [ -f "$ZSH_INSTALLER" ]; then
    chmod +x "$ZSH_INSTALLER" 2>/dev/null || true
    bash "$ZSH_INSTALLER"
else
    print_info "Instalador de ZSH no encontrado, saltando..."
fi

# 8.2. Cambiar shell por defecto a ZSH
ZSH_CHANGER="$SCRIPT_DIR/zsh/change_shell.sh"
if [ -f "$ZSH_CHANGER" ]; then
    chmod +x "$ZSH_CHANGER" 2>/dev/null || true
    bash "$ZSH_CHANGER"
else
    print_info "Script de cambio de shell no encontrado, saltando..."
fi

# ==============================================================================
# PASO 9: CONFIGURACIÓN DE HYPRLAND Y ASOCIACIONES MIME
# ==============================================================================
echo -e "\n${GREEN}[PASO 9/13] Configurando Hyprland y asociaciones de archivos...${NC}"

# 9.1. Configuración de Hyprland
HYPRLAND_CONFIGURATOR="$SCRIPT_DIR/hyprland/configure_hyprland.sh"
if [ -f "$HYPRLAND_CONFIGURATOR" ]; then
    chmod +x "$HYPRLAND_CONFIGURATOR" 2>/dev/null || true
    bash "$HYPRLAND_CONFIGURATOR"
else
    print_info "Configurador de Hyprland no encontrado, saltando..."
fi

# 9.2. Configuración de asociaciones MIME (aplicaciones por defecto)
MIME_CONFIGURATOR="$SCRIPT_DIR/desktop_apps/configure_mime.sh"
if [ -f "$MIME_CONFIGURATOR" ]; then
    chmod +x "$MIME_CONFIGURATOR" 2>/dev/null || true
    bash "$MIME_CONFIGURATOR"
else
    print_info "Configurador de MIME no encontrado, saltando..."
fi

# ==============================================================================
# PASO 10: CONFIGURACIÓN DE CLOUDFLARE WARP
# ==============================================================================
echo -e "\n${GREEN}[PASO 10/13] Configurando Cloudflare WARP...${NC}"

WARP_CONFIGURATOR="$SCRIPT_DIR/cloudflare_warp/configure_warp.sh"
if [ -f "$WARP_CONFIGURATOR" ]; then
    chmod +x "$WARP_CONFIGURATOR" 2>/dev/null || true
    bash "$WARP_CONFIGURATOR"
else
    print_info "Configurador de Cloudflare WARP no encontrado, saltando..."
fi

# ==============================================================================
# PASO 11: INSTALADORES OPCIONALES
# ==============================================================================
echo -e "\n${GREEN}[PASO 11/13] Instaladores opcionales...${NC}"

# 11.1. Configuración de Kitty
if [ -t 0 ] && [ -t 1 ]; then
    KITTY_INSTALLER="$SCRIPT_DIR/kitty/install_kitty.sh"
    if [ -f "$KITTY_INSTALLER" ]; then
        chmod +x "$KITTY_INSTALLER" 2>/dev/null || true
        bash "$KITTY_INSTALLER"
    fi
fi


# 11.3. Instalación de Bun
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar Bun (JavaScript runtime) ahora? (s/n, por defecto: n): "
    read -r install_bun
    case "$install_bun" in
        [sS]|[sS][iI])
            BUN_INSTALLER="$SCRIPT_DIR/bun/install_bun.sh"
            if [ -f "$BUN_INSTALLER" ]; then
                chmod +x "$BUN_INSTALLER" 2>/dev/null || true
                bash "$BUN_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de Bun en $BUN_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

# 11.4. Instalación de DevTools
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar DevTools (NVM + JDK25 + Maven) ahora? (s/n, por defecto: n): "
    read -r install_devtools
    case "$install_devtools" in
        [sS]|[sS][iI])
            DEVTOOLS_INSTALLER="$SCRIPT_DIR/devtools/install_nvm_jdk_maven.sh"
            if [ -f "$DEVTOOLS_INSTALLER" ]; then
                chmod +x "$DEVTOOLS_INSTALLER" 2>/dev/null || true
                # Ejecutar en zsh si está disponible y es el shell por defecto
                ZSH_BIN="$(command -v zsh 2>/dev/null || true)"
                if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" = "$ZSH_BIN" ]; then
                    zsh "$DEVTOOLS_INSTALLER"
                else
                    bash "$DEVTOOLS_INSTALLER"
                fi
            else
                echo -e "${RED}No se encontró el instalador de DevTools en $DEVTOOLS_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

# 11.5. Instalación de Neovim (después de DevTools para soporte de Java/Lombok)
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar Neovim ahora? (s/n, por defecto: n): "
    read -r install_nvim
    case "$install_nvim" in
        [sS]|[sS][iI])
            NVIM_INSTALLER="$SCRIPT_DIR/nvim/install.sh"
            if [ -f "$NVIM_INSTALLER" ]; then
                chmod +x "$NVIM_INSTALLER" 2>/dev/null || true
                # Ejecutar en zsh si está disponible y es el shell por defecto
                ZSH_BIN="$(command -v zsh 2>/dev/null || true)"
                if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" = "$ZSH_BIN" ]; then
                    zsh "$NVIM_INSTALLER"
                else
                    bash "$NVIM_INSTALLER"
                fi
            else
                echo -e "${RED}No se encontró el instalador de Neovim en $NVIM_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

# 11.6. Instalación de Docker
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar Docker + Docker Compose ahora? (s/n, por defecto: n): "
    read -r install_docker
    case "$install_docker" in
        [sS]|[sS][iI])
            DOCKER_INSTALLER="$SCRIPT_DIR/docker/install_docker.sh"
            if [ -f "$DOCKER_INSTALLER" ]; then
                chmod +x "$DOCKER_INSTALLER" 2>/dev/null || true
                bash "$DOCKER_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de Docker en $DOCKER_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

# 11.7. Instalación y configuración de SSH
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar y configurar SSH ahora? (s/n, por defecto: s): "
    read -r install_ssh
    case "$install_ssh" in
        [nN]|[nN][oO])
            ;;
        *)
            SSH_INSTALLER="$SCRIPT_DIR/ssh/install_ssh.sh"
            if [ -f "$SSH_INSTALLER" ]; then
                chmod +x "$SSH_INSTALLER" 2>/dev/null || true
                bash "$SSH_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de SSH en $SSH_INSTALLER${NC}"
            fi
            ;;
    esac
fi

# ==============================================================================
# PASO 12: HERRAMIENTAS ADICIONALES
# ==============================================================================
echo -e "\n${GREEN}[PASO 12/13] Herramientas adicionales...${NC}"

# 12.1. Instalación de opencode.ai
if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar opencode.ai (CLI interactiva)? (s/n, por defecto: s): "
    read -r install_opencode
    case "$install_opencode" in
        [nN]|[nN][oO])
            ;;
        *)
            if command -v opencode >/dev/null 2>&1; then
                print_info "opencode ya está instalado, saltando..."
            else
                print_info "Instalando opencode.ai..."
                curl -fsSL https://opencode.ai/install | bash
                print_success "opencode.ai instalado exitosamente"
            fi
            ;;
    esac
fi

# ==============================================================================
# PASO 13: FINALIZACIÓN Y DOCUMENTACIÓN
# ==============================================================================
echo -e "\n${GREEN}[PASO 13/13] Finalizando instalación...${NC}"

# Copiar archivo de ayuda al directorio home
if [ -f "$SCRIPT_DIR/COMANDOS.md" ]; then
    print_info "Copiando guía de comandos al directorio home..."
    cp "$SCRIPT_DIR/COMANDOS.md" "$HOME/COMANDOS.md"
    print_success "Guía de comandos disponible en ~/COMANDOS.md"
fi

echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e   "${GREEN}║          ¡Instalación completada exitosamente!         ║${NC}"
echo -e   "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}PRÓXIMOS PASOS:${NC}"
echo "  1. Cierra la sesión actual y abre una nueva"
echo "  2. ZSH se cargará automáticamente como tu shell por defecto"
echo "  3. Powerlevel10k se configurará en la primera ejecución"
echo ""
echo -e "${GREEN}COMANDOS ÚTILES:${NC}"
echo "  • Para ver la guía completa de comandos: ${GREEN}h${NC}"
echo "  • Para iniciar Hyprland: ${GREEN}start-hyprland${NC}"
echo ""
echo -e "${GREEN}CLOUDFLARE WARP:${NC}"
if command -v warp-cli >/dev/null 2>&1; then
    if warp-cli status | grep -q "Connected"; then
        echo "  • WARP está conectado y activo"
    else
        echo "  • Para conectar WARP: ${GREEN}warp-cli connect${NC}"
        echo "  • Para desconectar WARP: ${GREEN}warp-cli disconnect${NC}"
        echo "  • Para ver estado: ${GREEN}warp-cli status${NC}"
    fi
fi
echo ""
