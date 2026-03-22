#!/bin/bash

# ============================================================================
# Script de instalación de Waybar + swaync + wlogout
# Instala paquetes, copia configuraciones y reemplaza rutas del usuario
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
die()           { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="$HOME"
USERNAME="$(whoami)"

echo "============================================"
echo "Instalador de Waybar + swaync + wlogout"
echo "============================================"
echo ""

# ── 1. Paquetes ──────────────────────────────────────────────────────────────

print_info "Instalando paquetes..."
sudo pacman -S --needed --noconfirm \
    waybar \
    swaync \
    wlogout \
    python-gobject \
    gtk3

print_success "Paquetes instalados"

# ── 2. Directorios de destino ─────────────────────────────────────────────────

mkdir -p "$USER_HOME/.config/waybar"
mkdir -p "$USER_HOME/.config/swaync"
mkdir -p "$USER_HOME/.config/wlogout"

# ── 3. Copiar configs de waybar ───────────────────────────────────────────────

print_info "Copiando configuración de waybar..."

cp "$SCRIPT_DIR/conf/waybar/config.jsonc"   "$USER_HOME/.config/waybar/config.jsonc"
cp "$SCRIPT_DIR/conf/waybar/style.css"      "$USER_HOME/.config/waybar/style.css"
cp "$SCRIPT_DIR/conf/waybar/color-picker.py" "$USER_HOME/.config/waybar/color-picker.py"
chmod +x "$USER_HOME/.config/waybar/color-picker.py"

# colors.css solo si no existe (para no pisar personalizaciones)
if [ ! -f "$USER_HOME/.config/waybar/colors.css" ]; then
    cp "$SCRIPT_DIR/conf/waybar/colors.css" "$USER_HOME/.config/waybar/colors.css"
    print_success "colors.css copiado (colores por defecto)"
else
    print_info "colors.css ya existe, no se sobreescribe"
fi

# Reemplazar HOME_PLACEHOLDER con el home real del usuario
sed -i "s|HOME_PLACEHOLDER|${USER_HOME}|g" "$USER_HOME/.config/waybar/config.jsonc"

print_success "Configuración de waybar lista"

# ── 4. Copiar configs de swaync ───────────────────────────────────────────────

print_info "Copiando configuración de swaync..."

cp "$SCRIPT_DIR/conf/swaync/config.json" "$USER_HOME/.config/swaync/config.json"
cp "$SCRIPT_DIR/conf/swaync/style.css"   "$USER_HOME/.config/swaync/style.css"

# Reemplazar placeholders con valores reales
sed -i "s|HOME_PLACEHOLDER|${USER_HOME}|g"         "$USER_HOME/.config/swaync/style.css"
sed -i "s|USERNAME_PLACEHOLDER|${USERNAME}|g"       "$USER_HOME/.config/swaync/config.json"

print_success "Configuración de swaync lista"

# ── 5. Copiar configs de wlogout ──────────────────────────────────────────────

print_info "Copiando configuración de wlogout..."

cp "$SCRIPT_DIR/conf/wlogout/layout"    "$USER_HOME/.config/wlogout/layout"
cp "$SCRIPT_DIR/conf/wlogout/style.css" "$USER_HOME/.config/wlogout/style.css"

print_success "Configuración de wlogout lista"

# ── 6. Habilitar swaync como servicio de usuario ──────────────────────────────

print_info "Habilitando swaync como servicio de usuario..."
systemctl --user enable --now swaync.service 2>/dev/null || \
    print_info "swaync no tiene unit de systemd, se iniciará desde Hyprland autostart"

# ── 7. Resumen ────────────────────────────────────────────────────────────────

echo ""
echo "============================================"
print_success "Waybar instalado correctamente"
echo "============================================"
echo ""
echo "Configuraciones instaladas en:"
echo "  • ~/.config/waybar/    (barra, estilos, color-picker)"
echo "  • ~/.config/swaync/    (notificaciones)"
echo "  • ~/.config/wlogout/   (menú de apagado)"
echo ""
echo "Notas:"
echo "  • El color-picker (󰏘) edita ~/.config/waybar/colors.css en tiempo real"
echo "  • Si tienes wallpaper en ~/wallpapers/profile.png se usará en el panel swaync"
echo "  • Para añadir waybar al autostart de Hyprland:"
echo "    exec-once = waybar &"
echo "    exec-once = swaync &"
echo ""
