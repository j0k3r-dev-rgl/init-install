#!/bin/bash

# pre_install.sh — Configuración previa de Zsh en TTY1 (bash pura, Arch minimal)
# Debe ejecutarse ANTES del instalador principal.
# Al finalizar cierra la sesión para que el próximo login arranque en zsh.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}[....] $*${NC}"; }
print_ok()   { echo -e "${GREEN}[ OK ] $*${NC}"; }
print_skip() { echo -e "${YELLOW}[SKIP] $*${NC}"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()        { echo -e "${RED}[ERROR] $*${NC}" >&2; exit 1; }

ask_yes_no() {
    local question="$1"
    local default="${2:-s}"
    local prompt
    [[ "$default" == "s" ]] && prompt="(S/n)" || prompt="(s/N)"
    while true; do
        echo -en "${YELLOW}[????]${NC} $question $prompt: "
        read -r resp
        resp="${resp:-$default}"
        case "${resp,,}" in
            s|si|yes|y) return 0 ;;
            n|no)       return 1 ;;
            *) echo "Responde s o n." ;;
        esac
    done
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Pre-instalación — Zsh Setup        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  Este script prepara Zsh antes de la instalación principal."
echo "  Al terminar cerrará la sesión para que el próximo login"
echo "  arranque directamente en Zsh."
echo ""

# ─── 1. Instalar zsh + utilidades base ────────────────────────────────────────
print_step "Instalando zsh, fzf, eza..."
if sudo pacman -S --needed --noconfirm zsh fzf eza; then
    print_ok "Paquetes instalados"
else
    die "Falló la instalación de paquetes con pacman"
fi

# ─── 2. Plugins y tema ────────────────────────────────────────────────────────
echo ""
if ask_yes_no "¿Instalar Oh My Zsh + plugins + tema Powerlevel10k?" "s"; then

    # Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_skip "Oh My Zsh ya existe"
    else
        print_step "Instalando Oh My Zsh..."
        if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
            print_ok "Oh My Zsh instalado"
        else
            die "Falló la instalación de Oh My Zsh. Verifica tu conexión."
        fi
    fi

    # zsh-autosuggestions
    if [ -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
        print_skip "zsh-autosuggestions ya existe"
    else
        print_step "Clonando zsh-autosuggestions..."
        if git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"; then
            print_ok "zsh-autosuggestions instalado"
        else
            die "Falló el clone de zsh-autosuggestions"
        fi
    fi

    # zsh-syntax-highlighting
    if [ -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
        print_skip "zsh-syntax-highlighting ya existe"
    else
        print_step "Clonando zsh-syntax-highlighting..."
        if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"; then
            print_ok "zsh-syntax-highlighting instalado"
        else
            die "Falló el clone de zsh-syntax-highlighting"
        fi
    fi

    # Powerlevel10k
    if [ -d "$ZSH_CUSTOM_DIR/themes/powerlevel10k" ]; then
        print_skip "Powerlevel10k ya existe"
    else
        print_step "Clonando Powerlevel10k..."
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM_DIR/themes/powerlevel10k"; then
            print_ok "Powerlevel10k instalado"
        else
            die "Falló el clone de Powerlevel10k"
        fi
    fi

else
    print_skip "Plugins omitidos"
fi

# ─── 3. Cambiar shell a zsh ───────────────────────────────────────────────────
echo ""
ZSH_BIN="$(command -v zsh)"

if ! grep -qxF "$ZSH_BIN" /etc/shells; then
    print_warn "$ZSH_BIN no está en /etc/shells — agregándolo..."
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null \
        || die "No se pudo agregar $ZSH_BIN a /etc/shells"
fi

if [ "${SHELL:-}" = "$ZSH_BIN" ]; then
    print_skip "El shell ya es zsh"
else
    print_step "Cambiando shell por defecto a zsh..."
    if chsh -s "$ZSH_BIN"; then
        print_ok "Shell cambiado a $ZSH_BIN"
    else
        die "chsh falló. Intenta manualmente: chsh -s $ZSH_BIN"
    fi
fi

# ─── 5. Logout ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Todo listo. Cerrando sesión...         ║${NC}"
echo -e "${GREEN}║   Al iniciar sesión estarás en Zsh.      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""

sleep 2
kill -HUP "$PPID" 2>/dev/null || pkill -SIGHUP -u "$USER" bash 2>/dev/null || logout
