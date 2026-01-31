#!/bin/bash

# Instala el comando global 'update' para actualización completa del sistema

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update_system.sh"
BIN_DIR="$HOME/.local/bin"
COMMAND_NAME="update"

print_info "Instalando comando global 'update'..."

# Crear directorio .local/bin si no existe
mkdir -p "$BIN_DIR"

# Copiar el script
cp "$UPDATE_SCRIPT" "$BIN_DIR/$COMMAND_NAME"
chmod +x "$BIN_DIR/$COMMAND_NAME"

# Verificar que .local/bin está en PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    print_info "Añadiendo $BIN_DIR al PATH en .zshrc..."
    
    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Local bin directory" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
fi

print_info "Comando 'update' instalado correctamente"
print_info "Ubicación: $BIN_DIR/$COMMAND_NAME"
print_info ""
print_info "Uso: update"
print_info ""
print_info "Este comando actualizará:"
print_info "  • Paquetes oficiales (pacman)"
print_info "  • Paquetes AUR (yay)"
print_info "  • MongoDB Compass (si está instalado)"
print_info "  • Limpieza opcional del sistema"
