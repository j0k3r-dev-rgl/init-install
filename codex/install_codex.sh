#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BREW_USER_BIN="$HOME/.linuxbrew/bin/brew"
BREW_SYSTEM_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

find_brew() {
    if [ -x "$BREW_USER_BIN" ]; then
        printf '%s\n' "$BREW_USER_BIN"
        return 0
    fi

    if [ -x "$BREW_SYSTEM_BIN" ]; then
        printf '%s\n' "$BREW_SYSTEM_BIN"
        return 0
    fi

    return 1
}

if command -v codex >/dev/null 2>&1; then
    print_info "Codex ya está instalado: $(command -v codex)"
    exit 0
fi

BREW_BIN="$(find_brew || true)"

if [ -z "$BREW_BIN" ]; then
    die "No se encontró Homebrew en ~/.linuxbrew/bin/brew ni en /home/linuxbrew/.linuxbrew/bin/brew. Instalá Homebrew primero y volvé a ejecutar este script."
fi

print_info "Cargando entorno de Homebrew desde $BREW_BIN"
eval "$("$BREW_BIN" shellenv)"

if command -v codex >/dev/null 2>&1; then
    print_info "Codex ya está disponible después de cargar Homebrew: $(command -v codex)"
    exit 0
fi

print_info "Instalando Codex con Homebrew..."
"$BREW_BIN" install codex

if command -v codex >/dev/null 2>&1; then
    print_success "Codex instalado correctamente"
else
    die "La instalación terminó pero el comando 'codex' no quedó disponible en la shell actual"
fi
