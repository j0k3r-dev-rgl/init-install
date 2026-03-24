#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
USER_BREW_PREFIX="$HOME/.linuxbrew"
SYSTEM_BREW_PREFIX="/home/linuxbrew/.linuxbrew"

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

append_if_missing() {
    local file="$1"
    local line="$2"

    touch "$file"

    if ! grep -Fqx "$line" "$file"; then
        printf '\n%s\n' "$line" >> "$file"
        print_info "Agregada configuración Homebrew en $file"
    fi
}

install_dependencies() {
    print_info "Instalando dependencias de Homebrew en Arch Linux..."
    sudo pacman -S --needed --noconfirm base-devel procps-ng curl file git
}

install_system_brew() {
    if [ -x "$SYSTEM_BREW_PREFIX/bin/brew" ]; then
        print_info "Homebrew global ya está instalado en $SYSTEM_BREW_PREFIX"
        return 0
    fi

    print_info "Instalando Homebrew global en $SYSTEM_BREW_PREFIX..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL \"$BREW_INSTALL_URL\")"
    print_success "Homebrew global instalado"
}

install_user_brew() {
    if [ -x "$USER_BREW_PREFIX/bin/brew" ]; then
        print_info "Homebrew de usuario ya está instalado en $USER_BREW_PREFIX"
        return 0
    fi

    print_info "Instalando Homebrew de usuario en $USER_BREW_PREFIX..."
    mkdir -p "$USER_BREW_PREFIX"
    curl -fsSL https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C "$USER_BREW_PREFIX"
    eval "$("$USER_BREW_PREFIX/bin/brew" shellenv)"
    "$USER_BREW_PREFIX/bin/brew" update --force --quiet

    if [ -d "$USER_BREW_PREFIX/share/zsh" ]; then
        chmod -R go-w "$USER_BREW_PREFIX/share/zsh"
    fi

    print_success "Homebrew de usuario instalado"
}

configure_shell() {
    local shell_file

    for shell_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        append_if_missing "$shell_file" 'eval "$(~/.linuxbrew/bin/brew shellenv)"'
        append_if_missing "$shell_file" 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    done
}

load_current_shellenv() {
    if [ -x "$USER_BREW_PREFIX/bin/brew" ]; then
        eval "$("$USER_BREW_PREFIX/bin/brew" shellenv)"
    fi

    if [ -x "$SYSTEM_BREW_PREFIX/bin/brew" ]; then
        eval "$("$SYSTEM_BREW_PREFIX/bin/brew" shellenv)"
    fi
}

require_cmd sudo
require_cmd pacman
require_cmd curl
require_cmd tar

install_dependencies
install_system_brew
install_user_brew
configure_shell
load_current_shellenv

print_success "Homebrew listo para usar"
