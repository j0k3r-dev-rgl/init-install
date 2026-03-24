#!/bin/bash

# Genera dinámicamente el comando global 'update' según lo que esté instalado en el sistema.
# Cada vez que se ejecuta: elimina el script anterior y genera uno nuevo desde cero.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
print_skip()    { echo -e "${YELLOW}[SKIP]${NC} $*"; }
print_section() { echo -e "${BLUE}[....] $*${NC}"; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
UPDATE_SCRIPT="$BIN_DIR/update"

# ─── helpers de detección ────────────────────────────────────────────────────

has_cmd()  { command -v "$1" >/dev/null 2>&1; }
has_file() { [ -f "$1" ]; }
has_dir()  { [ -d "$1" ]; }

# ─── detección de componentes ────────────────────────────────────────────────

detect_pacman()  { has_cmd pacman; }
detect_yay()     { has_cmd yay; }
detect_brew()    { has_cmd brew \
                   || has_file "$HOME/.linuxbrew/bin/brew" \
                   || has_file "/home/linuxbrew/.linuxbrew/bin/brew"; }
detect_opencode(){ has_cmd opencode \
                   || has_file "$HOME/.opencode/bin/opencode"; }
detect_compass() { has_file "/opt/mongo/mongoDBCompass/.version"; }
detect_intellij(){ has_dir "/opt/intellij" && has_file "/opt/intellij/.version"; }
detect_codex()   {
    if has_cmd codex; then return 0; fi
    # codex vive en el PATH de Homebrew — intentar cargar brew y verificar
    local brew_bin=""
    if has_file "$HOME/.linuxbrew/bin/brew"; then
        brew_bin="$HOME/.linuxbrew/bin/brew"
    elif has_file "/home/linuxbrew/.linuxbrew/bin/brew"; then
        brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
    elif has_cmd brew; then
        brew_bin="$(command -v brew)"
    fi
    [ -n "$brew_bin" ] && eval "$("$brew_bin" shellenv 2>/dev/null)" && has_cmd codex
}

# ─── preparar destino ────────────────────────────────────────────────────────

mkdir -p "$BIN_DIR"

if has_file "$UPDATE_SCRIPT"; then
    print_info "Script anterior encontrado → eliminando $UPDATE_SCRIPT"
    rm -f "$UPDATE_SCRIPT"
fi

print_info "Detectando componentes instalados..."
echo ""

# ─── inicio del script generado ──────────────────────────────────────────────

cat > "$UPDATE_SCRIPT" <<'HEADER'
#!/bin/bash

set -euo pipefail

# Resolve the real path even when called via symlink
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    SOURCE="$(readlink -f "$SOURCE")"
done
BIN_DIR="$HOME/.local/bin"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $*${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════╝\n"
}
print_info()    { echo -e "${GREEN}[UPDATE]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
print_warning() { echo -e "${YELLOW}[AVISO]${NC} $*"; }

HEADER

STEP=1

# ─── bloque: pacman ──────────────────────────────────────────────────────────

print_section "pacman (repositorios oficiales)"
if detect_pacman; then
    print_info "  pacman → incluido"
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. PACMAN
print_header "${STEP}. REPOSITORIOS OFICIALES"
sudo pacman -Syu --noconfirm
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  pacman → no encontrado"
fi

# ─── bloque: yay ─────────────────────────────────────────────────────────────

print_section "yay (AUR)"
if detect_yay; then
    print_info "  yay → incluido"
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. AUR
print_header "${STEP}. PAQUETES AUR (YAY)"
yay -Sua --noconfirm
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  yay → no encontrado"
fi

# ─── bloque: homebrew ────────────────────────────────────────────────────────

print_section "Homebrew"
if detect_brew; then
    print_info "  brew → incluido"
    if has_cmd brew; then
        BREW_BIN="$(command -v brew)"
    elif has_file "$HOME/.linuxbrew/bin/brew"; then
        BREW_BIN="$HOME/.linuxbrew/bin/brew"
    else
        BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
    fi
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. HOMEBREW
print_header "${STEP}. HOMEBREW"
print_info "Cargando entorno de Homebrew..."
eval "\$(${BREW_BIN} shellenv)"
print_info "Actualizando Homebrew..."
brew update
brew upgrade
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  brew → no encontrado"
fi

# ─── bloque: codex ───────────────────────────────────────────────────────────

print_section "Codex"
if detect_codex; then
    print_info "  codex → incluido"
    if has_file "$HOME/.linuxbrew/bin/brew"; then
        BREW_BIN_CODEX="$HOME/.linuxbrew/bin/brew"
    elif has_file "/home/linuxbrew/.linuxbrew/bin/brew"; then
        BREW_BIN_CODEX="/home/linuxbrew/.linuxbrew/bin/brew"
    else
        BREW_BIN_CODEX="$(command -v brew 2>/dev/null || true)"
    fi
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. CODEX
print_header "${STEP}. CODEX"
print_info "Actualizando Codex via Homebrew..."
eval "\$(${BREW_BIN_CODEX} shellenv)"
brew upgrade codex || print_info "Codex ya está en la última versión"
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  codex → no encontrado"
fi

# ─── bloque: opencode ────────────────────────────────────────────────────────

print_section "Opencode"
if detect_opencode; then
    print_info "  opencode → incluido"
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. OPENCODE
print_header "${STEP}. OPENCODE"
print_info "Actualizando Opencode..."
curl -fsSL https://opencode.ai/install | bash
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  opencode → no encontrado"
fi

# ─── bloque: mongodb compass ─────────────────────────────────────────────────

print_section "MongoDB Compass"
if detect_compass; then
    print_info "  mongodb compass → incluido"
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. MONGODB COMPASS
print_header "${STEP}. MONGODB COMPASS"
print_info "Verificando MongoDB Compass..."
bash "\$BIN_DIR/update_compass.sh"
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  mongodb compass → no encontrado"
fi

# ─── bloque: intellij ────────────────────────────────────────────────────────

print_section "IntelliJ IDEA"
if detect_intellij; then
    print_info "  intellij → incluido"
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. INTELLIJ IDEA
print_header "${STEP}. INTELLIJ IDEA"
bash "\$BIN_DIR/intellij-update" --yes
BLOCK
    STEP=$((STEP + 1))
else
    print_skip "  intellij → no encontrado"
fi

# ─── bloque: limpieza (solo si hay pacman) ───────────────────────────────────

if detect_pacman; then
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. LIMPIEZA DEL SISTEMA
print_header "${STEP}. LIMPIEZA DEL SISTEMA"

ORPHANS=\$(pacman -Qdtq) || true
if [ -n "\$ORPHANS" ]; then
    sudo pacman -Rns \$ORPHANS --noconfirm
else
    print_success "No hay huérfanos"
fi

CURRENT_CACHE=\$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "0B")
print_info "Espacio actual en caché: \$CURRENT_CACHE"

read -p "¿Deseas realizar una limpieza PROFUNDA de la caché? (s/n): " -n 1 -r
echo ""

if [[ \$REPLY =~ ^[SsYy]\$ ]]; then
    print_info "Iniciando limpieza PROFUNDA..."
    sudo pacman -Scc
BLOCK

    if detect_yay; then
        cat >> "$UPDATE_SCRIPT" <<BLOCK
    yay -Scc
BLOCK
    fi

    cat >> "$UPDATE_SCRIPT" <<BLOCK
    print_success "Limpieza total completada."
fi
BLOCK
    STEP=$((STEP + 1))

    # ─── bloque: kernel ──────────────────────────────────────────────────────
    cat >> "$UPDATE_SCRIPT" <<BLOCK

# ${STEP}. ESTADO DEL KERNEL
print_header "${STEP}. ESTADO DEL KERNEL"

KERNEL_PKG=\$(pacman -Q linux 2>/dev/null | cut -d' ' -f2 | cut -d'-' -f1 \
    || pacman -Q linux-lts 2>/dev/null | cut -d' ' -f2 | cut -d'-' -f1) || KERNEL_PKG=""
KERNEL_RUNNING=\$(uname -r | cut -d'-' -f1)

if [ -n "\$KERNEL_PKG" ] && [ "\$KERNEL_PKG" != "\$KERNEL_RUNNING" ]; then
    print_warning "Kernel actualizado (Instalado: \$KERNEL_PKG | En uso: \$KERNEL_RUNNING)"
    print_warning "--> SE RECOMIENDA REINICIAR <--"
else
    print_success "El Kernel está actualizado y en uso (\$KERNEL_RUNNING)"
fi
BLOCK
    STEP=$((STEP + 1))
fi

# ─── footer del script generado ──────────────────────────────────────────────

cat >> "$UPDATE_SCRIPT" <<'FOOTER'

print_header "PROCESO FINALIZADO"
FOOTER

chmod +x "$UPDATE_SCRIPT"

# ─── copiar updaters auxiliares si existen ───────────────────────────────────

if has_file "$SCRIPT_DIR/../mongodb_compass/update_compass.sh"; then
    cp "$SCRIPT_DIR/../mongodb_compass/update_compass.sh" "$BIN_DIR/update_compass.sh"
    chmod +x "$BIN_DIR/update_compass.sh"
fi

if has_file "$SCRIPT_DIR/../intellij/update_intellij.sh"; then
    cp "$SCRIPT_DIR/../intellij/update_intellij.sh" "$BIN_DIR/intellij-update"
    chmod +x "$BIN_DIR/intellij-update"
fi

# ─── PATH en zshrc ───────────────────────────────────────────────────────────

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
        print_info "Añadiendo $BIN_DIR al PATH en .zshrc..."
        echo "" >> "$HOME/.zshrc"
        echo "# Local bin directory" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
fi

# ─── resumen ─────────────────────────────────────────────────────────────────

echo ""
print_info "Script 'update' generado en $UPDATE_SCRIPT"
print_info "Contiene $((STEP - 1)) secciones según lo instalado en este sistema"
print_info "Ejecutá 'update' para actualizar el sistema"
