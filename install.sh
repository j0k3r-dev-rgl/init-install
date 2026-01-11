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

yay_install() {
    yay -S --needed --noconfirm "$@"
}

trap 'die "El script falló en la línea $LINENO"' ERR

require_cmd sudo
require_cmd bash

if ! command -v pacman >/dev/null 2>&1; then
    die "Este script está pensado para Arch/derivados (pacman no encontrado)."
fi

echo -e "${GREEN}Iniciando la instalación de componentes...${NC}"

# 0. Limpieza previa (opcional)
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

# 1. Actualización del sistema y dependencias base
echo -e "${GREEN}Actualizando sistema e instalando dependencias base (git, base-devel)...${NC}"
sudo -v
sudo pacman -Syu --noconfirm
pacman_install git curl base-devel grim slurp wl-clipboard pciutils

require_cmd git
require_cmd curl

CPU_VENDOR_ID="$(grep -m1 -E '^vendor_id\s*:' /proc/cpuinfo 2>/dev/null | awk -F: '{gsub(/^[ \t]+/,"",$2); print $2}')"
CPU_MODEL_NAME="$(grep -m1 -E '^model name\s*:' /proc/cpuinfo 2>/dev/null | awk -F: '{gsub(/^[ \t]+/,"",$2); print $2}')"
MOBO_NAME="$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null || true)"
MOBO_VENDOR="$(cat /sys/devices/virtual/dmi/id/board_vendor 2>/dev/null || true)"
GPU_LINES="$(lspci 2>/dev/null | grep -Ei 'VGA|3D|Display' || true)"

IS_AMD_CPU=false
IS_INTEL_CPU=false
IS_NVIDIA_GPU=false
IS_AMD_GPU=false
IS_INTEL_GPU=false

if echo "${CPU_VENDOR_ID} ${CPU_MODEL_NAME}" | grep -qiE 'AuthenticAMD|Ryzen|EPYC|Threadripper'; then
    IS_AMD_CPU=true
fi
if echo "${CPU_VENDOR_ID} ${CPU_MODEL_NAME}" | grep -qiE 'GenuineIntel|Intel\(R\)'; then
    IS_INTEL_CPU=true
fi

if echo "$GPU_LINES" | grep -qiE 'NVIDIA'; then
    IS_NVIDIA_GPU=true
fi
if echo "$GPU_LINES" | grep -qiE 'AMD|ATI|Radeon'; then
    IS_AMD_GPU=true
fi
if echo "$GPU_LINES" | grep -qiE 'Intel\(R\)|Intel Corporation'; then
    IS_INTEL_GPU=true
fi

echo -e "${GREEN}Hardware detectado:${NC}"
echo "   CPU: ${CPU_MODEL_NAME:-desconocido}"
echo "   Placa: ${MOBO_VENDOR:-desconocido} - ${MOBO_NAME:-desconocida}"
echo "   GPU: ${GPU_LINES:-desconocida}"

if [ -t 0 ] && [ -t 1 ]; then
    if [ "$IS_AMD_CPU" = true ]; then
        echo -n "Se detectó CPU AMD. ¿Instalar microcódigo amd-ucode? (s/n, por defecto: s): "
        read -r resp_ucode
        case "$resp_ucode" in
            [nN]|[nN][oO])
                ;;
            *)
                pacman_install amd-ucode
                ;;
        esac
    elif [ "$IS_INTEL_CPU" = true ]; then
        echo -n "Se detectó CPU Intel. ¿Instalar microcódigo intel-ucode? (s/n, por defecto: s): "
        read -r resp_ucode
        case "$resp_ucode" in
            [nN]|[nN][oO])
                ;;
            *)
                pacman_install intel-ucode
                ;;
        esac
    fi

    if [ "$IS_NVIDIA_GPU" = true ]; then
        echo -n "Se detectó GPU NVIDIA. ¿Instalar drivers NVIDIA (nvidia/nvidia-utils)? (s/n, por defecto: s): "
        read -r resp_gpu
        case "$resp_gpu" in
            [nN]|[nN][oO])
                ;;
            *)
                pacman_install nvidia nvidia-utils nvidia-settings
                ;;
        esac
    elif [ "$IS_AMD_GPU" = true ]; then
        echo -n "Se detectó GPU AMD. ¿Instalar Mesa + Vulkan Radeon? (s/n, por defecto: s): "
        read -r resp_gpu
        case "$resp_gpu" in
            [nN]|[nN][oO])
                ;;
            *)
                pacman_install mesa vulkan-radeon libva-mesa-driver mesa-vdpau
                ;;
        esac
    elif [ "$IS_INTEL_GPU" = true ]; then
        echo -n "Se detectó GPU Intel. ¿Instalar Mesa + Vulkan Intel + VA-API? (s/n, por defecto: s): "
        read -r resp_gpu
        case "$resp_gpu" in
            [nN]|[nN][oO])
                ;;
            *)
                pacman_install mesa vulkan-intel intel-media-driver libva-mesa-driver
                ;;
        esac
    fi
else
    if [ "$IS_AMD_CPU" = true ]; then
        pacman_install amd-ucode
    elif [ "$IS_INTEL_CPU" = true ]; then
        pacman_install intel-ucode
    fi

    if [ "$IS_NVIDIA_GPU" = true ]; then
        pacman_install nvidia nvidia-utils
    elif [ "$IS_AMD_GPU" = true ]; then
        pacman_install mesa vulkan-radeon libva-mesa-driver mesa-vdpau
    elif [ "$IS_INTEL_GPU" = true ]; then
        pacman_install mesa vulkan-intel intel-media-driver libva-mesa-driver
    fi
fi

# 2. Instalación de Yay (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo -e "${GREEN}Instalando yay...${NC}"
    tmp_dir="$(mktemp -d)"
    cleanup() { rm -rf "$tmp_dir"; }
    trap cleanup EXIT
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    trap - EXIT
    cleanup
else
    echo -e "${GREEN}Yay ya está instalado, saltando...${NC}"
fi

# 3. Instalación de Hyprland, Kitty y Wofi
echo -e "${GREEN}Instalando entorno (Hyprland, Kitty, Wofi)...${NC}"
pacman_install hyprland kitty wofi

# 3.1. Instalación de Dolphin (gestor de archivos)
echo -e "${GREEN}Instalando Dolphin...${NC}"
pacman_install dolphin

# 4. Instalación de Fuentes
# Instalamos fuentes comunes y Nerd Fonts para iconos en la terminal
echo -e "${GREEN}Instalando fuentes (TTF e iconos)...${NC}"
pacman_install ttf-font-awesome ttf-jetbrains-mono-nerd noto-fonts-emoji

# 5. Instalación de ZSH y Oh My Zsh
echo -e "${GREEN}Configurando ZSH...${NC}"
pacman_install zsh

# 5.1. Instalación de fzf (fuzzy finder)
echo -e "${GREEN}Instalando fzf...${NC}"
pacman_install fzf

# 5.2. Instalación de eza (reemplazo moderno de ls)
echo -e "${GREEN}Instalando eza...${NC}"
pacman_install eza

# Instalación de Oh My Zsh (vía script oficial)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 6. Plugins de ZSH y Powerlevel10k
echo -e "${GREEN}Instalando plugins de ZSH y Powerlevel10k...${NC}"

# Zsh Autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Zsh Syntax Highlighting (Probablemente el "sfs" que mencionaste)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if grep -q '^ZSH_THEME=' "$ZSHRC"; then
        sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
    else
        printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$ZSHRC"
    fi

    if grep -q '^plugins=(' "$ZSHRC"; then
        if ! grep -q 'zsh-autosuggestions' "$ZSHRC"; then
            sed -i 's/^plugins=(/plugins=(zsh-autosuggestions /' "$ZSHRC"
        fi
        if ! grep -q 'zsh-syntax-highlighting' "$ZSHRC"; then
            sed -i 's/^plugins=(/plugins=(zsh-syntax-highlighting /' "$ZSHRC"
        fi
        if ! grep -q 'fzf' "$ZSHRC"; then
            sed -i 's/^plugins=(/plugins=(fzf /' "$ZSHRC"
        fi
    fi

    # Asegurar que Powerlevel10k se cargue
    if ! grep -q '\.p10k\.zsh' "$ZSHRC"; then
        printf '\n# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n' >> "$ZSHRC"
    fi

    if ! grep -q '\.p10k\.configure-once' "$ZSHRC"; then
        printf '\nautoload -Uz add-zsh-hook\n_p10k_configure_once() {\n  if [[ -o interactive ]] && [[ -f ~/.p10k.configure-once ]]; then\n    rm -f ~/.p10k.configure-once\n    p10k configure\n    add-zsh-hook -d precmd _p10k_configure_once\n    unset -f _p10k_configure_once\n  fi\n}\nadd-zsh-hook precmd _p10k_configure_once\n' >> "$ZSHRC"
    fi

    if ! grep -q "alias ls='eza" "$ZSHRC"; then
        printf "\n# Alias para eza (el nuevo ls)\nalias ls='eza --icons --group-directories-first'\nalias ll='eza -lh --icons --group-directories-first'\nalias la='eza -aH --icons --group-directories-first'\n" >> "$ZSHRC"
    fi
fi

copy_config_dir() {
    src="$1"
    dst="$2"
    if [ ! -d "$src" ]; then
        return 0
    fi
    mkdir -p "$dst"
    if [ -t 0 ] && [ -t 1 ] && [ -e "$dst" ] && [ "$(ls -A "$dst" 2>/dev/null || true)" != "" ]; then
        echo -n "Se detectó configuración existente en $dst. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
        read -r overwrite
        case "$overwrite" in
            [sS]|[sS][iI])
                rm -rf "$dst"
                mkdir -p "$dst"
                ;;
            *)
                echo "Omitiendo copia de configuración para $dst"
                return 0
                ;;
        esac
    fi
    cp -a "$src/." "$dst/"
}

copy_config_dir "$SCRIPT_DIR/hypr" "$HOME/.config/hypr"
 
# Cambiar a ZSH si no es el shell actual
ZSH_BIN="$(command -v zsh)"

ensure_zsh_in_etc_shells() {
    if [ -r /etc/shells ] && ! grep -qxF "$ZSH_BIN" /etc/shells; then
        if [ -t 0 ] && [ -t 1 ]; then
            echo "El shell '$ZSH_BIN' no está listado en /etc/shells. chsh puede fallar por esto."
            echo -n "¿Deseas agregarlo a /etc/shells ahora? (s/n, por defecto: s): "
            read -r add_shells
            case "$add_shells" in
                [nN]|[nN][oO])
                    ;;
                *)
                    echo -e "${GREEN}Agregando $ZSH_BIN a /etc/shells...${NC}"
                    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
                    ;;
            esac
        else
            echo "Aviso: '$ZSH_BIN' no está en /etc/shells. Si chsh falla, agrega esta línea a /etc/shells."
        fi
    fi
}

if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
    if [ -t 0 ] && [ -t 1 ]; then
        echo -n "¿Deseas cambiar tu shell por defecto a ZSH ahora? (s/n, por defecto: s): "
        read -r shell_response
        case "$shell_response" in
            [nN]|[nN][oO])
                echo "Shell por defecto mantenido. Para cambiar manualmente: chsh -s $ZSH_BIN"
                ;;
            *)
                ensure_zsh_in_etc_shells
                echo -e "${GREEN}Cambiando shell por defecto a ZSH...${NC}"
                if chsh -s "$ZSH_BIN"; then
                    echo -e "${GREEN}Shell cambiado. Reinicia tu sesión o abre una nueva terminal para usar ZSH.${NC}"
                else
                    echo -e "${RED}No se pudo cambiar el shell por defecto.${NC}"
                    echo "Posibles causas: zsh no está en /etc/shells, contraseña incorrecta, políticas del sistema."
                    echo "Prueba: grep -xF '$ZSH_BIN' /etc/shells || echo '$ZSH_BIN' | sudo tee -a /etc/shells"
                    echo "Luego: chsh -s '$ZSH_BIN'"
                fi
                ;;
        esac
    else
        ensure_zsh_in_etc_shells
        echo -e "${GREEN}Cambiando shell por defecto a ZSH...${NC}"
        if chsh -s "$ZSH_BIN"; then
            echo -e "${GREEN}Shell cambiado. Reinicia tu sesión o abre una nueva terminal para usar ZSH.${NC}"
        else
            echo -e "${RED}No se pudo cambiar el shell por defecto.${NC}"
        fi
    fi
else
    echo -e "${GREEN}Ya estás usando ZSH como shell por defecto.${NC}"
fi

P10K_CONFIG="$HOME/.p10k.zsh"
if [ -t 0 ] && [ -t 1 ]; then
    if [ -f "$P10K_CONFIG" ]; then
        echo -e "${GREEN}Se encontró una configuración existente de Powerlevel10k en $P10K_CONFIG${NC}"
        echo -n "¿Deseas mantener esta configuración? (s/n, por defecto: s): "
        read -r response
        case "$response" in
            [nN]|[nN][oO])
                echo -e "${GREEN}La configuración de Powerlevel10k se iniciará en la próxima terminal.${NC}"
                : > "$HOME/.p10k.configure-once"
                ;;
            *)
                ;;
        esac
    else
        echo -e "${GREEN}La configuración inicial de Powerlevel10k se iniciará en la próxima terminal.${NC}"
        : > "$HOME/.p10k.configure-once"
    fi
else
    if [ ! -f "$P10K_CONFIG" ]; then
        : > "$HOME/.p10k.configure-once"
    fi
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas iniciar Hyprland automáticamente al iniciar sesión (TTY1)? (s/n, por defecto: n): "
    read -r hypr_autostart
    case "$hypr_autostart" in
        [sS]|[sS][iI])
            ZPROFILE="$HOME/.zprofile"
            if ! grep -q 'exec Hyprland' "$ZPROFILE" 2>/dev/null; then
                printf '\nif [ -z "${DISPLAY-}" ] && [ "${XDG_VTNR-}" = "1" ]; then\n  exec start-hyprland\nfi\n' >> "$ZPROFILE"
            fi
            ;;
        *)
            ;;
    esac
fi

if [ -t 0 ] && [ -t 1 ]; then
    KITTY_INSTALLER="$SCRIPT_DIR/kitty/install_kitty.sh"
    if [ -f "$KITTY_INSTALLER" ]; then
        chmod +x "$KITTY_INSTALLER" 2>/dev/null || true
        bash "$KITTY_INSTALLER"
    fi
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar Windsurf ahora? (s/n, por defecto: n): "
    read -r install_windsurf
    case "$install_windsurf" in
        [sS]|[sS][iI])
            WINDSURF_INSTALLER="$SCRIPT_DIR/windsurf/install_windsurf.sh"
            if [ -f "$WINDSURF_INSTALLER" ]; then
                chmod +x "$WINDSURF_INSTALLER" 2>/dev/null || true
                bash "$WINDSURF_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de Windsurf en $WINDSURF_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar IntelliJ IDEA ahora? (s/n, por defecto: n): "
    read -r install_intellij
    case "$install_intellij" in
        [sS]|[sS][iI])
            INTELLIJ_INSTALLER="$SCRIPT_DIR/intellij/install_intellij.sh"
            if [ -f "$INTELLIJ_INSTALLER" ]; then
                chmod +x "$INTELLIJ_INSTALLER" 2>/dev/null || true
                bash "$INTELLIJ_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de IntelliJ IDEA en $INTELLIJ_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar DevTools (NVM + JDK21 + Maven) ahora? (s/n, por defecto: n): "
    read -r install_devtools
    case "$install_devtools" in
        [sS]|[sS][iI])
            DEVTOOLS_INSTALLER="$SCRIPT_DIR/devtools/install_nvm_jdk_maven.sh"
            if [ -f "$DEVTOOLS_INSTALLER" ]; then
                chmod +x "$DEVTOOLS_INSTALLER" 2>/dev/null || true
                bash "$DEVTOOLS_INSTALLER"
            else
                echo -e "${RED}No se encontró el instalador de DevTools en $DEVTOOLS_INSTALLER${NC}"
            fi
            ;;
        *)
            ;;
    esac
fi

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

print_info "Iniciando configuración de Cloudflare WARP..."

if command -v yay >/dev/null 2>&1; then
    if ! pacman -Qs cloudflare-warp-bin > /dev/null; then
        print_info "Instalando cloudflare-warp-bin..."
        yay_install cloudflare-warp-bin
    else
        print_info "Cloudflare WARP ya está instalado."
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

        print_info "Configurando modo WARP y conectando..."
        warp-cli mode warp
        warp-cli connect

        HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
        mkdir -p "$(dirname "$HYPR_CONF")"
        touch "$HYPR_CONF"

        if ! grep -q "warp-cli connect" "$HYPR_CONF"; then
            print_info "Agregando inicio automático a Hyprland..."
            echo "" >> "$HYPR_CONF"
            echo "# Cloudflare WARP Auto-Connect" >> "$HYPR_CONF"
            echo "exec-once = warp-cli connect" >> "$HYPR_CONF"
            print_success "Configuración de Hyprland actualizada."
        else
            print_info "La configuración de Hyprland ya incluye WARP."
        fi

        print_success "Cloudflare WARP configurado y activo."
    else
        die "Se instaló cloudflare-warp-bin pero no se encontró warp-cli en PATH."
    fi
else
    die "No se encontró yay, necesario para instalar cloudflare-warp-bin desde AUR."
fi

echo -e "${GREEN}Instalación finalizada.${NC}"
echo "Cierra y vuelve a abrir tu terminal (o reinicia tu sesión) para ver todos los cambios."
