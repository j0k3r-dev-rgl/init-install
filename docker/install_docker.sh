#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

require_cmd sudo
require_cmd pacman
require_cmd systemctl

sudo -v

echo -e "${GREEN}Instalando Docker y Docker Compose...${NC}"
pacman_install docker docker-compose

echo -e "${GREEN}Habilitando e iniciando docker.service...${NC}"
sudo systemctl enable --now docker.service

TARGET_USER="${SUDO_USER:-$USER}"
if [ -z "$TARGET_USER" ]; then
    TARGET_USER="$USER"
fi

echo -e "${GREEN}Agregando el usuario '$TARGET_USER' al grupo docker...${NC}"
if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker || true
fi
sudo usermod -aG docker "$TARGET_USER"

echo -e "${GREEN}Docker instalado y configurado.${NC}"
echo "Para que el cambio de grupo tenga efecto, cierra sesión y vuelve a iniciar (o reinicia el sistema)."
echo "Luego podrás usar Docker sin sudo. Prueba: docker ps"
