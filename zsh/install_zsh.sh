#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
print_warning() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

command -v sudo >/dev/null 2>&1 || die "Falta sudo"
command -v pacman >/dev/null 2>&1 || die "Falta pacman"
command -v git >/dev/null 2>&1 || true

clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    local label="$3"

    if [ -d "$target_dir/.git" ]; then
        print_info "Actualizando $label..."
        git -C "$target_dir" pull --ff-only
    elif [ -e "$target_dir" ]; then
        print_warning "$target_dir existe pero no es un repo git. Se omite $label."
    else
        print_info "Instalando $label..."
        git clone --depth=1 "$repo_url" "$target_dir"
    fi
}

configure_zshrc() {
    local zshrc="${HOME}/.zshrc"
    local managed_block
    local current_block=""
    local temp_file

    managed_block="$(cat <<'EOF'
# >>> init-install zsh
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source "$ZSH/oh-my-zsh.sh"

alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -aH --icons --group-directories-first'
alias h='cat ~/COMANDOS.md | less'
# <<< init-install zsh
EOF
)"

    if [ -f "$zshrc" ]; then
        current_block="$(awk '
            $0 == "# >>> init-install zsh" { capture = 1 }
            capture { print }
            $0 == "# <<< init-install zsh" { capture = 0 }
        ' "$zshrc")"
    fi

    if [ "$current_block" = "$managed_block" ]; then
        print_success "Bloque Zsh ya está actualizado en ~/.zshrc"
        return
    fi

    temp_file="$(mktemp)"

    if [ -f "$zshrc" ]; then
        local backup_file="${zshrc}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$zshrc" "$backup_file"
        print_info "Backup de .zshrc guardado en $backup_file"

        awk '
            $0 == "# >>> init-install zsh" { skip = 1; next }
            $0 == "# <<< init-install zsh" { skip = 0; next }
            !skip { print }
        ' "$zshrc" > "$temp_file"
    else
        : > "$temp_file"
    fi

    if grep -q "oh-my-zsh.sh" "$temp_file"; then
        print_warning "Tu .zshrc ya carga Oh My Zsh fuera del bloque gestionado. Si ves duplicados, revisalo manualmente."
    fi

    printf '\n%s\n' "$managed_block" >> "$temp_file"

    mv "$temp_file" "$zshrc"
    chmod 600 "$zshrc"
    print_success "Plugins de Zsh activados en ~/.zshrc"
}

print_info "Instalando Zsh, Git y Eza..."
sudo pacman -S --needed --noconfirm zsh git eza

OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${OH_MY_ZSH_DIR}/custom}"
PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"

clone_or_update "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_DIR" "Oh My Zsh"
mkdir -p "$PLUGINS_DIR"

clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "${PLUGINS_DIR}/zsh-autosuggestions" "zsh-autosuggestions"
clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${PLUGINS_DIR}/zsh-syntax-highlighting" "zsh-syntax-highlighting"
clone_or_update "https://github.com/zsh-users/zsh-completions.git" "${PLUGINS_DIR}/zsh-completions" "zsh-completions"

configure_zshrc

print_success "Zsh, Oh My Zsh y plugins instalados y activados"
