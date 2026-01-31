#!/bin/bash

# Script para instalar y configurar ZSH con Oh My Zsh y Powerlevel10k

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

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

print_info "==== Instalación y Configuración de ZSH ===="

# 1. Instalación de ZSH y herramientas
print_info "Instalando ZSH, fzf y eza..."
pacman_install zsh fzf eza

# 2. Instalación de Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh instalado"
else
    print_success "Oh My Zsh ya está instalado"
fi

# 3. Instalación de plugins de ZSH
print_info "Instalando plugins de ZSH..."

# Zsh Autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Zsh Syntax Highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# 4. Configuración de .zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    # Configurar tema Powerlevel10k
    if grep -q '^ZSH_THEME=' "$ZSHRC"; then
        sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
    else
        printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$ZSHRC"
    fi

    # Configurar plugins
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

    # Configuración automática de Powerlevel10k en primera ejecución
    if ! grep -q '\.p10k\.configure-once' "$ZSHRC"; then
        printf '\nautoload -Uz add-zsh-hook\n_p10k_configure_once() {\n  if [[ -o interactive ]] && [[ -f ~/.p10k.configure-once ]]; then\n    rm -f ~/.p10k.configure-once\n    p10k configure\n    add-zsh-hook -d precmd _p10k_configure_once\n    unset -f _p10k_configure_once\n  fi\n}\nadd-zsh-hook precmd _p10k_configure_once\n' >> "$ZSHRC"
    fi

    # Añadir alias para eza
    if ! grep -q "alias ls='eza" "$ZSHRC"; then
        printf "\n# Alias para eza (el nuevo ls)\nalias ls='eza --icons --group-directories-first'\nalias ll='eza -lh --icons --group-directories-first'\nalias la='eza -aH --icons --group-directories-first'\n" >> "$ZSHRC"
    fi

    # Configurar variables de entorno del PATH
    if ! grep -q '# Path configuration' "$ZSHRC"; then
        printf '\n# Path configuration\n' >> "$ZSHRC"
        printf '# User local binaries\n' >> "$ZSHRC"
        printf 'export PATH="$HOME/.local/bin:$PATH"\n' >> "$ZSHRC"
        printf '\n# Bun\n' >> "$ZSHRC"
        printf 'export BUN_INSTALL="$HOME/.bun"\n' >> "$ZSHRC"
        printf 'export PATH="$BUN_INSTALL/bin:$PATH"\n' >> "$ZSHRC"
        printf '\n# NVM (Node Version Manager)\n' >> "$ZSHRC"
        printf 'export NVM_DIR="$HOME/.nvm"\n' >> "$ZSHRC"
        printf '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n' >> "$ZSHRC"
        printf '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"\n' >> "$ZSHRC"
        printf '\n# Java (JDK)\n' >> "$ZSHRC"
        printf 'if [ -d "/usr/lib/jvm/default" ]; then\n' >> "$ZSHRC"
        printf '  export JAVA_HOME="/usr/lib/jvm/default"\n' >> "$ZSHRC"
        printf '  export PATH="$JAVA_HOME/bin:$PATH"\n' >> "$ZSHRC"
        printf 'fi\n' >> "$ZSHRC"
        printf '\n# Maven\n' >> "$ZSHRC"
        printf 'if [ -d "$HOME/.local/share/maven" ]; then\n' >> "$ZSHRC"
        printf '  export M2_HOME="$HOME/.local/share/maven"\n' >> "$ZSHRC"
        printf '  export MAVEN_HOME="$M2_HOME"\n' >> "$ZSHRC"
        printf '  export PATH="$M2_HOME/bin:$PATH"\n' >> "$ZSHRC"
        printf 'fi\n' >> "$ZSHRC"
    fi
fi

# 5. Configurar Powerlevel10k para primera ejecución
P10K_CONFIG="$HOME/.p10k.zsh"
if [ -t 0 ] && [ -t 1 ]; then
    if [ -f "$P10K_CONFIG" ]; then
        echo -e "${GREEN}Se encontró una configuración existente de Powerlevel10k en $P10K_CONFIG${NC}"
        echo -n "¿Deseas mantener esta configuración? (s/n, por defecto: s): "
        read -r response
        case "$response" in
            [nN]|[nN][oO])
                print_info "La configuración de Powerlevel10k se iniciará en la próxima terminal."
                : > "$HOME/.p10k.configure-once"
                ;;
            *)
                ;;
        esac
    else
        print_info "La configuración inicial de Powerlevel10k se iniciará en la próxima terminal."
        : > "$HOME/.p10k.configure-once"
    fi
else
    if [ ! -f "$P10K_CONFIG" ]; then
        : > "$HOME/.p10k.configure-once"
    fi
fi

print_success "ZSH instalado y configurado correctamente"
