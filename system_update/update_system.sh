#!/bin/bash

# Script de actualización completa del sistema
# Actualiza pacman, yay (AUR) y verifica actualizaciones de MongoDB Compass

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $*${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}[UPDATE]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Verificar que pacman y yay estén disponibles
command -v pacman >/dev/null 2>&1 || { print_error "pacman no encontrado"; exit 1; }
command -v yay >/dev/null 2>&1 || { print_warning "yay no encontrado, saltando actualizaciones AUR"; }

print_header "ACTUALIZACIÓN COMPLETA DEL SISTEMA"

# ============================================================================
# 1. ACTUALIZAR REPOSITORIOS OFICIALES (PACMAN)
# ============================================================================

print_header "1. Actualizando repositorios oficiales (pacman)"

print_info "Sincronizando bases de datos de paquetes..."
sudo pacman -Sy

print_info "Verificando actualizaciones disponibles..."
UPDATES=$(pacman -Qu 2>/dev/null | wc -l)

if [ "$UPDATES" -gt 0 ]; then
    print_info "Paquetes con actualizaciones disponibles: $UPDATES"
    echo ""
    pacman -Qu
    echo ""
    
    if [ -t 0 ] && [ -t 1 ]; then
        read -p "¿Deseas actualizar los paquetes oficiales? (s/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[SsYy]$ ]]; then
            print_info "Actualizando paquetes oficiales..."
            sudo pacman -Su --noconfirm
            print_success "Paquetes oficiales actualizados"
        else
            print_warning "Actualización de pacman cancelada"
        fi
    else
        print_info "Actualizando paquetes oficiales (modo no interactivo)..."
        sudo pacman -Su --noconfirm
        print_success "Paquetes oficiales actualizados"
    fi
else
    print_success "No hay actualizaciones disponibles en repositorios oficiales"
fi

# ============================================================================
# 2. ACTUALIZAR PAQUETES AUR (YAY)
# ============================================================================

if command -v yay >/dev/null 2>&1; then
    print_header "2. Actualizando paquetes AUR (yay)"
    
    print_info "Verificando actualizaciones de AUR..."
    AUR_UPDATES=$(yay -Qua 2>/dev/null | wc -l)
    
    if [ "$AUR_UPDATES" -gt 0 ]; then
        print_info "Paquetes AUR con actualizaciones disponibles: $AUR_UPDATES"
        echo ""
        yay -Qua
        echo ""
        
        if [ -t 0 ] && [ -t 1 ]; then
            read -p "¿Deseas actualizar los paquetes AUR? (s/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[SsYy]$ ]]; then
                print_info "Actualizando paquetes AUR..."
                yay -Sua --noconfirm
                print_success "Paquetes AUR actualizados"
            else
                print_warning "Actualización de AUR cancelada"
            fi
        else
            print_info "Actualizando paquetes AUR (modo no interactivo)..."
            yay -Sua --noconfirm
            print_success "Paquetes AUR actualizados"
        fi
    else
        print_success "No hay actualizaciones disponibles en AUR"
    fi
else
    print_header "2. Paquetes AUR (yay)"
    print_warning "yay no está instalado, saltando actualizaciones de AUR"
fi

# ============================================================================
# 3. VERIFICAR MONGODB COMPASS
# ============================================================================

if command -v mongodb-compass-update >/dev/null 2>&1; then
    print_header "3. Verificando MongoDB Compass"
    
    # Ejecutar sin interacción para solo verificar
    MONGO_VERSION_FILE="/opt/mongo/mongoDBCompass/.version"
    
    if [ -f "$MONGO_VERSION_FILE" ]; then
        CURRENT_MONGO=$(cat "$MONGO_VERSION_FILE")
        print_info "MongoDB Compass actual: v$CURRENT_MONGO"
        
        if command -v jq >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
            LATEST_MONGO=$(curl -sL https://api.github.com/repos/mongodb-js/compass/releases/latest 2>/dev/null | jq -r '.tag_name' | sed 's/^v//')
            
            if [ -n "$LATEST_MONGO" ] && [ "$LATEST_MONGO" != "null" ]; then
                print_info "MongoDB Compass disponible: v$LATEST_MONGO"
                
                if [ "$CURRENT_MONGO" != "$LATEST_MONGO" ]; then
                    print_warning "¡Nueva versión de MongoDB Compass disponible!"
                    echo ""
                    if [ -t 0 ] && [ -t 1 ]; then
                        read -p "¿Deseas actualizar MongoDB Compass ahora? (s/n): " -n 1 -r
                        echo ""
                        if [[ $REPLY =~ ^[SsYy]$ ]]; then
                            mongodb-compass-update
                        else
                            print_info "Puedes actualizar después con: mongodb-compass-update"
                        fi
                    else
                        print_info "Ejecuta 'mongodb-compass-update' para actualizar"
                    fi
                else
                    print_success "MongoDB Compass está actualizado"
                fi
            fi
        else
            print_info "Ejecuta 'mongodb-compass-update' para verificar actualizaciones"
        fi
    else
        print_info "MongoDB Compass no está instalado"
    fi
fi

# ============================================================================
# 4. LIMPIEZA (OPCIONAL)
# ============================================================================

print_header "4. Limpieza del sistema"

print_info "Paquetes huérfanos detectados: $(pacman -Qdtq 2>/dev/null | wc -l)"

if [ "$(pacman -Qdtq 2>/dev/null | wc -l)" -gt 0 ]; then
    if [ -t 0 ] && [ -t 1 ]; then
        read -p "¿Deseas eliminar paquetes huérfanos? (s/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[SsYy]$ ]]; then
            sudo pacman -Rns $(pacman -Qdtq) --noconfirm
            print_success "Paquetes huérfanos eliminados"
        fi
    fi
fi

print_info "Espacio en caché de pacman: $(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)"

if [ -t 0 ] && [ -t 1 ]; then
    read -p "¿Deseas limpiar la caché de pacman? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        sudo pacman -Sc --noconfirm
        print_success "Caché de pacman limpiada"
    fi
fi

# ============================================================================
# RESUMEN FINAL
# ============================================================================

print_header "ACTUALIZACIÓN COMPLETADA"

print_success "Sistema actualizado correctamente"
echo ""
print_info "Comandos útiles:"
print_info "  • Ver paquetes instalados: pacman -Q"
print_info "  • Ver paquetes AUR: yay -Qm"
print_info "  • Actualizar MongoDB Compass: mongodb-compass-update"
echo ""
