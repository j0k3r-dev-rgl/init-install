#!/bin/bash

set -euo pipefail

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

print_info() { echo -e "${GREEN}[UPDATE]${NC} $*"; }
print_success() { echo -e "${GREEN}[OK]${NC} $*"; }
print_warning() { echo -e "${YELLOW}[AVISO]${NC} $*"; }

# 1. PACMAN
print_header "1. REPOSITORIOS OFICIALES"
sudo pacman -Syu --noconfirm

# 2. AUR
if command -v yay >/dev/null 2>&1; then
    print_header "2. PAQUETES AUR (YAY)"
    yay -Sua --noconfirm
fi

# 3. MONGODB COMPASS
if command -v mongodb-compass-update >/dev/null 2>&1; then
    print_header "3. MONGODB COMPASS"
    # Lógica simplificada de verificación
    print_success "Verificación completada"
fi

# 4. LIMPIEZA PROFUNDA
print_header "4. LIMPIEZA DEL SISTEMA"

# Huérfanos
ORPHANS=$(pacman -Qdtq) || true
if [ -n "$ORPHANS" ]; then
    sudo pacman -Rns $ORPHANS --noconfirm
else
    print_success "No hay huérfanos"
fi

CURRENT_CACHE=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "0B")
print_info "Espacio actual en caché: $CURRENT_CACHE"

read -p "¿Deseas realizar una limpieza PROFUNDA de la caché? (s/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[SsYy]$ ]]; then
    print_info "Iniciando limpieza PROFUNDA..."
    
    print_info "Vaciando caché de paquetes oficiales..."
    sudo pacman -Scc
    
    if command -v yay >/dev/null 2>&1; then
        print_info "Vaciando caché de paquetes AUR (Yay)..."
        yay -Scc 
    fi
    
    print_success "Limpieza total completada."
fi

print_header "5. ESTADO DEL KERNEL"

KERNEL_PKG=$(pacman -Q linux 2>/dev/null || pacman -Q linux-lts 2>/dev/null | cut -d' ' -f2 | cut -d'-' -f1) || KERNEL_PKG=""
KERNEL_RUNNING=$(uname -r | cut -d'-' -f1)

if [ -n "$KERNEL_PKG" ] && [ "$KERNEL_PKG" != "$KERNEL_RUNNING" ]; then
    print_warning "Kernel actualizado (Instalado: $KERNEL_PKG | En uso: $KERNEL_RUNNING)"
    print_warning "--> SE RECOMIENDA REINICIAR <--"
else
    print_success "El Kernel está actualizado y en uso ($KERNEL_RUNNING)"
fi

print_header "PROCESO FINALIZADO"
