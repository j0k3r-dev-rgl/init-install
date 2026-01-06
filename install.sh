#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# --- Colores para la salida ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
pacman_install git curl base-devel

require_cmd git
require_cmd curl

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

if [ -t 0 ] && [ -t 1 ]; then
    P10K_CONFIG="$HOME/.p10k.zsh"
    if [ -f "$P10K_CONFIG" ]; then
        echo -e "${GREEN}Se encontró una configuración existente de Powerlevel10k en $P10K_CONFIG${NC}"
        echo -n "¿Deseas cargar esta configuración? (s/n, por defecto: s): "
        read -r response
        case "$response" in
            [nN]|[nN][oO])
                echo -e "${GREEN}Creando nueva configuración de Powerlevel10k...${NC}"
                echo -n "¿Deseas hacer un backup de la configuración actual? (s/n, por defecto: s): "
                read -r backup_response
                case "$backup_response" in
                    [nN]|[nN][oO])
                        ;;
                    *)
                        backup_file="$HOME/.p10k.zsh.backup.$(date +%Y%m%d%H%M%S)"
                        cp "$P10K_CONFIG" "$backup_file"
                        echo -e "${GREEN}Backup guardado en $backup_file${NC}"
                        ;;
                esac
                zsh -ic 'source ~/.zshrc >/dev/null 2>&1; p10k configure'
                ;;
            *)
                echo -e "${GREEN}Usando configuración existente de Powerlevel10k.${NC}"
                echo "Para reconfigurar más tarde, ejecuta: zsh -ic 'p10k configure'"
                ;;
        esac
    else
        echo -e "${GREEN}Iniciando configuración interactiva de Powerlevel10k...${NC}"
        if zsh -ic 'source ~/.zshrc >/dev/null 2>&1; p10k configure'; then
            :
        else
            echo "Powerlevel10k no pudo iniciarse automáticamente. Ejecuta: zsh -ic 'p10k configure'"
        fi
    fi
else
    echo "Para configurar Powerlevel10k luego, ejecuta: zsh -ic 'p10k configure'"
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas iniciar Hyprland automáticamente al iniciar sesión (TTY1)? (s/n, por defecto: n): "
    read -r hypr_autostart
    case "$hypr_autostart" in
        [sS]|[sS][iI])
            ZPROFILE="$HOME/.zprofile"
            if ! grep -q 'exec Hyprland' "$ZPROFILE" 2>/dev/null; then
                printf '\nif [ -z "${DISPLAY-}" ] && [ "${XDG_VTNR-}" = "1" ]; then\n  exec Hyprland\nfi\n' >> "$ZPROFILE"
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

echo -e "${GREEN}Instalación finalizada.${NC}"
echo "Cierra y vuelve a abrir tu terminal (o reinicia tu sesión) para ver todos los cambios."
