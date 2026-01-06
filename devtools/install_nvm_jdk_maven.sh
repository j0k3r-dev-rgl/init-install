#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

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

have_pkg() {
    pacman -Si "$1" >/dev/null 2>&1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

require_cmd sudo
require_cmd pacman

sudo -v

pacman_install git curl

echo -e "${GREEN}Instalando JDK 21 y Maven...${NC}"
if have_pkg jdk21-openjdk; then
    pacman_install jdk21-openjdk
else
    die "No se encontró el paquete 'jdk21-openjdk' en pacman."
fi

if have_pkg maven; then
    pacman_install maven
else
    die "No se encontró el paquete 'maven' en pacman."
fi

echo -e "${GREEN}Instalando NVM...${NC}"
if have_pkg nvm; then
    pacman_install nvm
else
    if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm nvm
    else
        die "No se encontró 'nvm' en pacman y 'yay' no está instalado."
    fi
fi

ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -q 'NVM_DIR=' "$ZSHRC"; then
        printf '\nexport NVM_DIR="$HOME/.nvm"\n' >> "$ZSHRC"
    fi
    if ! grep -q 'init-nvm\.sh' "$ZSHRC"; then
        printf '[[ -s /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh\n' >> "$ZSHRC"
    fi
    if ! grep -q '/usr/share/nvm/nvm\.sh' "$ZSHRC"; then
        printf '[[ -s /usr/share/nvm/nvm.sh ]] && source /usr/share/nvm/nvm.sh\n' >> "$ZSHRC"
    fi
fi

if [ -t 0 ] && [ -t 1 ]; then
    echo -n "¿Deseas instalar Node.js LTS vía nvm ahora? (s/n, por defecto: s): "
    read -r install_node
    case "$install_node" in
        [nN]|[nN][oO])
            ;;
        *)
            if command -v zsh >/dev/null 2>&1; then
                zsh -ic 'source ~/.zshrc >/dev/null 2>&1; nvm install --lts; nvm alias default "lts/*"'
            else
                bash -lc 'source ~/.zshrc >/dev/null 2>&1; nvm install --lts; nvm alias default "lts/*"'
            fi
            ;;
    esac
fi

echo -e "${GREEN}Devtools instalados: JDK 21 + Maven + NVM.${NC}"
