#!/bin/bash

ZSHRC="$HOME/.zshrc"
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Configurando el archivo .zshrc...${NC}"

# 1. Cambiar el tema a Powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"

# 2. Activar los plugins (Autosuggestions y Syntax Highlighting)
# Buscamos la línea de plugins=(git) y la reemplazamos con los nuevos
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"

# 3. Forzar el cambio de shell a ZSH para el usuario actual
echo -e "${GREEN}Cambiando shell por defecto a ZSH...${NC}"
sudo chsh -s $(which zsh) $USER

echo -e "${GREEN}¡Configuración completada!${NC}"
echo "-------------------------------------------------------"
echo "POR FAVOR, REINICIA TU TERMINAL (o escribe 'zsh')."
echo "Al iniciar, Powerlevel10k lanzará automáticamente el"
echo "asistente de configuración visual."
echo "-------------------------------------------------------"
