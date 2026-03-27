#!/bin/bash

set -euo pipefail

sudo pacman -S --needed --noconfirm docker docker-compose
sudo systemctl enable --now docker.service

TARGET_USER="${SUDO_USER:-$USER}"
if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker || true
fi
sudo usermod -aG docker "$TARGET_USER"
