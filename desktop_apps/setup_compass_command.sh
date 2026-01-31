#!/bin/bash

# Crea el comando global mongodb-compass-update

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update_mongodb_compass.sh"
BIN_DIR="$HOME/.local/bin"
COMMAND_NAME="mongodb-compass-update"

print_info "Creando comando global '$COMMAND_NAME'..."

# Crear directorio .local/bin si no existe
mkdir -p "$BIN_DIR"

# Crear symlink
ln -sf "$UPDATE_SCRIPT" "$BIN_DIR/$COMMAND_NAME"

# Verificar que .local/bin está en PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    print_info "Añadiendo $BIN_DIR al PATH en .zshrc..."
    echo "" >> "$HOME/.zshrc"
    echo "# MongoDB Compass Update Command" >> "$HOME/.zshrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
fi

print_info "Comando '$COMMAND_NAME' creado correctamente"
print_info "Uso: $COMMAND_NAME"
