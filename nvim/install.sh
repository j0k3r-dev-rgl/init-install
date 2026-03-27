#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
print_step() { echo -e "${BLUE}[....] $*${NC}"; }
print_ok()   { echo -e "${GREEN}[ OK ] $*${NC}"; }
print_skip() { echo -e "${YELLOW}[SKIP] $*${NC}"; }
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
LOCAL_CONFIG_DIR="$SCRIPT_DIR/configs"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
INSTALL_DIR="/opt/nvim-linux-x86_64"
NVIM_BIN="$INSTALL_DIR/bin/nvim"
SHELL_RC="$HOME/.zshrc"
[ -f "$SHELL_RC" ] || SHELL_RC="$HOME/.bashrc"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Instalación de Neovim               ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

[ -d "$LOCAL_CONFIG_DIR" ] || die "No se encontró la configuración local en $LOCAL_CONFIG_DIR"

# ─── Detectar versión instalada ───────────────────────────────────────────────
INSTALLED_TAG=""
INSTALLED_LABEL=""
if [ -f "$NVIM_BIN" ]; then
    INSTALLED_VER="$("$NVIM_BIN" --version 2>/dev/null | head -1 || echo '')"
    if echo "$INSTALLED_VER" | grep -q "\-dev"; then
        INSTALLED_TAG="nightly"
        INSTALLED_LABEL="$INSTALLED_VER"
    else
        # Extraer vX.Y.Z del output: "NVIM v0.11.6"
        INSTALLED_TAG="$(echo "$INSTALLED_VER" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'  || echo '')"
        INSTALLED_LABEL="$INSTALLED_TAG"
    fi
fi

# ─── 1. Dependencias ──────────────────────────────────────────────────────────
print_step "Instalando dependencias del sistema..."
if sudo pacman -S --needed --noconfirm \
    git gcc make unzip ripgrep fd \
    nodejs npm python python-pip python-pynvim \
    tree-sitter tree-sitter-cli wl-clipboard; then
    print_ok "Dependencias instaladas"
else
    die "Falló la instalación de dependencias con pacman"
fi

print_step "Instalando paquete neovim de npm..."
if sudo npm install -g neovim; then
    print_ok "neovim npm instalado"
else
    die "Falló: sudo npm install -g neovim"
fi

# ─── 2. Selector de versión ───────────────────────────────────────────────────
echo ""
print_step "Obteniendo versiones disponibles de Neovim..."

VERSIONS_RAW="$(python3 - <<'PYEOF'
import urllib.request, json, sys
url = 'https://api.github.com/repos/neovim/neovim/releases?per_page=100'
try:
    req = urllib.request.Request(url, headers={'User-Agent': 'nvim-installer'})
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
except Exception as e:
    print(f'ERROR:{e}', file=sys.stderr)
    sys.exit(1)
for r in data:
    tag = r['tag_name']
    if tag == 'stable':
        continue
    if tag != 'nightly':
        try:
            parts = tag.lstrip('v').split('.')
            major, minor = int(parts[0]), int(parts[1])
            if (major, minor) < (0, 10):
                continue
        except (ValueError, IndexError):
            continue
    date = r['published_at'][:10]
    kind = 'dev' if r['prerelease'] else 'stable'
    print(f'{tag}|{date}|{kind}')
PYEOF
)" || die "No se pudo obtener versiones de GitHub. Verifica tu conexión."

echo ""
echo -e "${BOLD}  Versiones disponibles:${NC}"
echo ""

# Mostrar menú numerado
i=1
declare -a TAGS
declare -a DATES
declare -a KINDS

while IFS='|' read -r tag date kind; do
    TAGS+=("$tag")
    DATES+=("$date")
    KINDS+=("$kind")

    # Etiqueta de tipo coloreada
    if [[ "$kind" == "dev" ]]; then
        kind_label="${YELLOW}(dev)${NC}   "
    else
        kind_label="${GREEN}(stable)${NC}"
    fi

    # Marcar versión instalada
    installed_marker=""
    if [[ -n "$INSTALLED_TAG" && "$tag" == "$INSTALLED_TAG" ]]; then
        installed_marker="${CYAN} ← instalada${NC}"
    fi

    printf "  ${BOLD}%3d)${NC}  %-12s  %b  %s  %b\n" \
        "$i" "$tag" "$kind_label" "$date" "$installed_marker"
    (( i++ ))
done <<< "$VERSIONS_RAW"

echo ""

# Mostrar versión instalada si no aparece en la lista (ej: nightly actualizado)
if [[ -n "$INSTALLED_TAG" ]]; then
    echo -e "  ${CYAN}Instalada actualmente:${NC} $INSTALLED_LABEL"
    echo ""
fi

# Pedir selección
while true; do
    echo -en "${YELLOW}[????]${NC} Selecciona el número de versión a instalar (o 0 para cancelar): "
    read -r selection
    if [[ "$selection" == "0" ]]; then
        print_skip "Instalación de binario cancelada"
        break
    fi
    if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection < i )); then
        SELECTED_TAG="${TAGS[$((selection-1))]}"
        SELECTED_DATE="${DATES[$((selection-1))]}"
        SELECTED_KIND="${KINDS[$((selection-1))]}"
        break
    fi
    echo "  Número inválido. Ingresa un valor entre 1 y $((i-1)), o 0 para cancelar."
done

# ─── 3. Instalación del binario ───────────────────────────────────────────────
if [[ -n "${SELECTED_TAG:-}" ]]; then
    echo ""
    if [[ "$SELECTED_KIND" == "dev" ]]; then
        TYPE_LABEL="nightly (dev)"
    else
        TYPE_LABEL="stable"
    fi
    print_info "Versión seleccionada: $SELECTED_TAG ($TYPE_LABEL) — $SELECTED_DATE"

    # Confirmar si ya está instalada la misma
    if [[ -n "$INSTALLED_TAG" && "$SELECTED_TAG" == "$INSTALLED_TAG" ]]; then
        print_warn "Ya tienes $SELECTED_TAG instalado"
        if ! ask_yes_no "¿Deseas reinstalarlo de todas formas?" "n"; then
            print_skip "Reinstalación cancelada"
            SELECTED_TAG=""
        fi
    fi
fi

if [[ -n "${SELECTED_TAG:-}" ]]; then
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${SELECTED_TAG}/nvim-linux-x86_64.tar.gz"
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    print_step "Descargando Neovim $SELECTED_TAG..."
    if curl -L "$NVIM_URL" -o "$TMP_DIR/nvim-linux-x86_64.tar.gz"; then
        print_ok "Descarga completada"
    else
        die "Falló la descarga desde $NVIM_URL"
    fi

    print_step "Eliminando versión anterior en $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR"

    print_step "Instalando en $INSTALL_DIR..."
    if sudo tar -C /opt -xzf "$TMP_DIR/nvim-linux-x86_64.tar.gz"; then
        INSTALLED_VER="$("$NVIM_BIN" --version 2>/dev/null | head -1 || echo '')"
        print_ok "Neovim instalado: $INSTALLED_VER"
    else
        die "Falló la extracción del archivo"
    fi
fi

# ─── 4. PATH en shell rc ──────────────────────────────────────────────────────
if grep -q '/opt/nvim-linux-x86_64/bin' "$SHELL_RC" 2>/dev/null; then
    print_skip "PATH de Neovim ya está en $SHELL_RC"
else
    printf '\n# Neovim\nexport PATH="$PATH:/opt/nvim-linux-x86_64/bin"\n' >> "$SHELL_RC"
    print_ok "PATH agregado a $SHELL_RC"
fi

# ─── 5. Configuración ─────────────────────────────────────────────────────────
echo ""
if [ -d "$NVIM_CONFIG_DIR" ] && [ -n "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]; then
    print_warn "Ya existe configuración en $NVIM_CONFIG_DIR"
    echo ""
    echo "  Opciones:"
    echo "    1) Reemplazar — mueve la actual a backup y aplica la del repo"
    echo "    2) Mantener   — no toca nada"
    echo ""
    echo -en "${YELLOW}[????]${NC} ¿Qué deseas hacer? (1/2, default: 2): "
    read -r config_choice
    config_choice="${config_choice:-2}"

    case "$config_choice" in
        1)
            BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
            print_step "Moviendo config actual a $BACKUP_DIR..."
            mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
            print_ok "Backup creado en $BACKUP_DIR"

            print_step "Aplicando configuración del repositorio..."
            mkdir -p "$NVIM_CONFIG_DIR"
            cp -a "$LOCAL_CONFIG_DIR/." "$NVIM_CONFIG_DIR/"
            print_ok "Configuración aplicada"
            ;;
        2)
            print_skip "Configuración existente conservada sin cambios"
            ;;
        *)
            print_warn "Opción no reconocida. Configuración conservada sin cambios."
            ;;
    esac
else
    print_step "Aplicando configuración de Neovim..."
    mkdir -p "$NVIM_CONFIG_DIR"
    cp -a "$LOCAL_CONFIG_DIR/." "$NVIM_CONFIG_DIR/"
    print_ok "Configuración aplicada en $NVIM_CONFIG_DIR"
fi

echo ""
print_ok "Instalación de Neovim completada."
echo ""
