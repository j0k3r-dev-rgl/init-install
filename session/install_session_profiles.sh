#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
print_warning() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/init-install"
PROFILE_FILE="${CONFIG_DIR}/tty-profiles.conf"
ZPROFILE="${HOME}/.zprofile"

TTY=""
DESKTOP=""
BAR=""

usage() {
    cat <<'EOF'
Uso: install_session_profiles.sh [--tty N --desktop hyprland|mango|none --bar waybar|noctalia|none]

Sin argumentos, pregunta interactivamente qué TTY configurar.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --tty)
            TTY="${2:-}"
            shift 2
            ;;
        --desktop)
            DESKTOP="${2:-}"
            shift 2
            ;;
        --bar)
            BAR="${2:-}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Argumento no reconocido: $1"
            ;;
    esac
done

validate_tty() {
    case "$1" in
        ""|*[!0-9]*) die "TTY inválido: $1" ;;
    esac
    if [ "$1" -lt 1 ] || [ "$1" -gt 12 ]; then
        die "TTY fuera de rango: $1 (usa 1-12)"
    fi
}

validate_desktop() {
    case "$1" in
        hyprland|mango|none) ;;
        *) die "Desktop inválido: $1 (usa hyprland, mango o none)" ;;
    esac
}

validate_bar() {
    case "$1" in
        waybar|noctalia|none) ;;
        *) die "Barra inválida: $1 (usa waybar, noctalia o none)" ;;
    esac
}

backup_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup"
    print_info "Backup: $backup"
}

install_session_scripts() {
    mkdir -p "$BIN_DIR"
    cp "$SCRIPT_DIR/init-install-session" "$BIN_DIR/init-install-session"
    cp "$SCRIPT_DIR/init-install-autostart" "$BIN_DIR/init-install-autostart"
    chmod +x "$BIN_DIR/init-install-session" "$BIN_DIR/init-install-autostart"
    print_success "Scripts instalados en $BIN_DIR"
}

install_zprofile_block() {
    local block_tmp clean_tmp current_tmp had_zprofile
    block_tmp="$(mktemp)"
    clean_tmp="$(mktemp)"
    current_tmp="$(mktemp)"
    had_zprofile=0
    [ -f "$ZPROFILE" ] && had_zprofile=1
    trap 'rm -f "$block_tmp" "$clean_tmp" "$current_tmp"' RETURN

    cat > "$block_tmp" <<'EOF'
# >>> init-install session
if [ -z "${DISPLAY-}" ] && [ -n "${XDG_VTNR-}" ] && [ -x "$HOME/.local/bin/init-install-session" ]; then
  "$HOME/.local/bin/init-install-session" "$XDG_VTNR"
fi
# <<< init-install session
EOF

    touch "$ZPROFILE"
    awk '
        /^# >>> init-install session$/ { capture = 1 }
        capture { print }
        /^# <<< init-install session$/ { capture = 0 }
    ' "$ZPROFILE" > "$current_tmp"

    if cmp -s "$current_tmp" "$block_tmp" && ! grep -q 'exec start-hyprland' "$ZPROFILE"; then
        print_info "~/.zprofile ya tiene el bloque init-install session actualizado"
        return 0
    fi

    if [ "$had_zprofile" -eq 1 ]; then
        backup_file "$ZPROFILE"
    fi
    awk '
        /^# >>> init-install session$/ { skip = 1; next }
        /^# <<< init-install session$/ { skip = 0; next }
        skip { next }
        /^if \[ -z "\$\{DISPLAY-\}" \] && \[ "\$\{XDG_VTNR-\}" = "1" \]; then$/ { legacy = 1; next }
        legacy == 1 && /^  exec start-hyprland$/ { legacy = 2; next }
        legacy == 2 && /^fi$/ { legacy = 0; next }
        legacy { print; legacy = 0; next }
        { print }
    ' "$ZPROFILE" > "$clean_tmp"

    {
        cat "$clean_tmp"
        printf '\n'
        cat "$block_tmp"
    } > "$ZPROFILE"

    print_success "Bloque de sesión actualizado en ~/.zprofile"
}

capture_profile_block() {
    local file="$1"
    [ -f "$file" ] || return 0
    awk '
        /^# >>> init-install tty profiles$/ { capture = 1 }
        capture { print }
        /^# <<< init-install tty profiles$/ { capture = 0 }
    ' "$file"
}

update_tty_profile() {
    local tty="$1"
    local desktop="$2"
    local bar="$3"
    local entries_tmp next_entries_tmp sorted_tmp block_tmp current_tmp clean_tmp

    validate_tty "$tty"
    validate_desktop "$desktop"
    validate_bar "$bar"

    mkdir -p "$CONFIG_DIR"
    entries_tmp="$(mktemp)"
    next_entries_tmp="$(mktemp)"
    sorted_tmp="$(mktemp)"
    block_tmp="$(mktemp)"
    current_tmp="$(mktemp)"
    clean_tmp="$(mktemp)"
    trap 'rm -f "$entries_tmp" "$next_entries_tmp" "$sorted_tmp" "$block_tmp" "$current_tmp" "$clean_tmp"' RETURN

    if [ -f "$PROFILE_FILE" ]; then
        awk '
            /^# >>> init-install tty profiles$/ { capture = 1; next }
            /^# <<< init-install tty profiles$/ { capture = 0; next }
            capture && /^TTY[0-9]+_(DESKTOP|BAR)=/ { print }
        ' "$PROFILE_FILE" > "$entries_tmp"

        if [ ! -s "$entries_tmp" ]; then
            grep -E '^TTY[0-9]+_(DESKTOP|BAR)=' "$PROFILE_FILE" >> "$entries_tmp" || true
        fi
    fi

    grep -v -E "^TTY${tty}_(DESKTOP|BAR)=" "$entries_tmp" > "$next_entries_tmp" || true
    printf 'TTY%s_DESKTOP=%s\n' "$tty" "$desktop" >> "$next_entries_tmp"
    printf 'TTY%s_BAR=%s\n' "$tty" "$bar" >> "$next_entries_tmp"
    awk -F'[=_]' '
        /^TTY[0-9]+_(DESKTOP|BAR)=/ {
            tty = $1
            sub(/^TTY/, "", tty)
            order = ($2 == "DESKTOP") ? 0 : 1
            printf "%012d %d %s\n", tty, order, $0
        }
    ' "$next_entries_tmp" | sort -n -k1,1 -k2,2 | cut -d' ' -f3- > "$sorted_tmp"

    {
        echo '# >>> init-install tty profiles'
        cat "$sorted_tmp"
        echo '# <<< init-install tty profiles'
    } > "$block_tmp"

    capture_profile_block "$PROFILE_FILE" > "$current_tmp"
    if cmp -s "$current_tmp" "$block_tmp"; then
        print_info "TTY$tty ya estaba configurado como $desktop + $bar"
        return 0
    fi

    backup_file "$PROFILE_FILE"
    if [ -f "$PROFILE_FILE" ]; then
        awk '
            /^# >>> init-install tty profiles$/ { skip = 1; next }
            /^# <<< init-install tty profiles$/ { skip = 0; next }
            skip { next }
            /^TTY[0-9]+_(DESKTOP|BAR)=/ { next }
            { print }
        ' "$PROFILE_FILE" > "$clean_tmp"
    fi

    {
        if [ -s "$clean_tmp" ]; then
            cat "$clean_tmp"
            printf '\n'
        fi
        cat "$block_tmp"
    } > "$PROFILE_FILE"

    print_success "TTY$tty configurado como $desktop + $bar en $PROFILE_FILE"
}

prompt_tty_profile() {
    local default_tty="${XDG_VTNR:-1}"
    local tty desktop_choice bar_choice desktop bar

    read -r -p "TTY a configurar [${default_tty}]: " tty
    tty="${tty:-$default_tty}"

    echo "Desktop para TTY$tty:"
    echo "  1) Hyprland"
    echo "  2) MangoWM"
    echo "  3) Ninguno"
    read -r -p "Elegí desktop [1]: " desktop_choice
    desktop_choice="${desktop_choice:-1}"
    case "$desktop_choice" in
        1) desktop="hyprland" ;;
        2) desktop="mango" ;;
        3) desktop="none" ;;
        *) die "Opción de desktop inválida: $desktop_choice" ;;
    esac

    echo "Barra/shell para TTY$tty:"
    echo "  1) Waybar"
    echo "  2) Noctalia Shell"
    echo "  3) Ninguna"
    read -r -p "Elegí barra [3]: " bar_choice
    bar_choice="${bar_choice:-3}"
    case "$bar_choice" in
        1) bar="waybar" ;;
        2) bar="noctalia" ;;
        3) bar="none" ;;
        *) die "Opción de barra inválida: $bar_choice" ;;
    esac

    update_tty_profile "$tty" "$desktop" "$bar"
}

install_session_scripts
install_zprofile_block

if [ -n "$TTY$DESKTOP$BAR" ]; then
    [ -n "$TTY" ] && [ -n "$DESKTOP" ] && [ -n "$BAR" ] || die "--tty, --desktop y --bar deben usarse juntos"
    update_tty_profile "$TTY" "$DESKTOP" "$BAR"
elif [ -t 0 ] && [ -t 1 ]; then
    prompt_tty_profile
else
    print_warning "No hay TTY interactiva; scripts y ~/.zprofile quedaron instalados, sin cambiar perfiles TTY"
fi
