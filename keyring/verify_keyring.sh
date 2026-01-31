#!/bin/bash

# Script de verificación de GNOME Keyring
# Comprueba que todos los componentes estén correctamente instalados y configurados

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

check_ok() {
    echo -e "  ${GREEN}✓${NC} $*"
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $*"
    ((WARNINGS++))
}

check_error() {
    echo -e "  ${RED}✗${NC} $*"
    ((ERRORS++))
}

# ==============================================================================
# 1. VERIFICAR PAQUETES INSTALADOS
# ==============================================================================

print_header "1. Verificando paquetes instalados"

for pkg in gnome-keyring libsecret seahorse gcr-4; do
    if pacman -Q "$pkg" &>/dev/null; then
        check_ok "$pkg instalado"
    else
        check_error "$pkg NO instalado"
    fi
done

# ==============================================================================
# 2. VERIFICAR CONFIGURACIÓN PAM
# ==============================================================================

print_header "2. Verificando configuración PAM"

PAM_LOGIN="/etc/pam.d/login"

if [ -f "$PAM_LOGIN" ]; then
    if grep -q "pam_gnome_keyring.so" "$PAM_LOGIN"; then
        check_ok "PAM configurado en $PAM_LOGIN"
        
        # Verificar línea auth
        if grep -q "^auth.*pam_gnome_keyring.so" "$PAM_LOGIN"; then
            check_ok "Línea 'auth' presente"
        else
            check_warn "Línea 'auth' no encontrada o comentada"
        fi
        
        # Verificar línea session
        if grep -q "^session.*pam_gnome_keyring.so.*auto_start" "$PAM_LOGIN"; then
            check_ok "Línea 'session auto_start' presente"
        else
            check_warn "Línea 'session auto_start' no encontrada o comentada"
        fi
    else
        check_error "PAM NO configurado (falta pam_gnome_keyring.so)"
    fi
else
    check_error "$PAM_LOGIN no existe"
fi

# ==============================================================================
# 3. VERIFICAR PROCESO GNOME-KEYRING
# ==============================================================================

print_header "3. Verificando proceso gnome-keyring-daemon"

if pgrep -x gnome-keyring-d >/dev/null; then
    check_ok "gnome-keyring-daemon está corriendo"
    
    # Mostrar información del proceso
    KEYRING_PID=$(pgrep -x gnome-keyring-d)
    KEYRING_USER=$(ps -o user= -p "$KEYRING_PID")
    check_ok "PID: $KEYRING_PID, Usuario: $KEYRING_USER"
else
    check_warn "gnome-keyring-daemon NO está corriendo"
    echo "       (Es normal si no has iniciado sesión gráfica)"
fi

# ==============================================================================
# 4. VERIFICAR SERVICIO SYSTEMD
# ==============================================================================

print_header "4. Verificando servicios systemd"

if systemctl --user is-active gnome-keyring-daemon.service &>/dev/null; then
    check_ok "gnome-keyring-daemon.service está activo"
else
    check_warn "gnome-keyring-daemon.service NO está activo"
    echo "       (Es normal si no has iniciado sesión)"
fi

if systemctl --user is-enabled gcr-ssh-agent.socket &>/dev/null; then
    check_ok "gcr-ssh-agent.socket está habilitado"
else
    check_warn "gcr-ssh-agent.socket NO está habilitado"
fi

if systemctl --user is-active gcr-ssh-agent.socket &>/dev/null; then
    check_ok "gcr-ssh-agent.socket está activo"
else
    check_warn "gcr-ssh-agent.socket NO está activo"
fi

# ==============================================================================
# 5. VERIFICAR VARIABLES DE ENTORNO
# ==============================================================================

print_header "5. Verificando variables de entorno"

ENV_FILE="$HOME/.config/environment.d/ssh_auth_sock.conf"
if [ -f "$ENV_FILE" ]; then
    check_ok "Archivo de entorno SSH existe: $ENV_FILE"
else
    check_warn "Archivo de entorno SSH NO existe: $ENV_FILE"
fi

if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    check_ok "SSH_AUTH_SOCK está definida: $SSH_AUTH_SOCK"
    
    if [ -S "$SSH_AUTH_SOCK" ]; then
        check_ok "Socket SSH existe y es válido"
    else
        check_warn "Socket SSH no existe o no es válido"
    fi
else
    check_warn "SSH_AUTH_SOCK NO está definida"
    echo "       (Reinicia la sesión para cargar las variables)"
fi

# ==============================================================================
# 6. VERIFICAR D-BUS
# ==============================================================================

print_header "6. Verificando Secret Service D-Bus"

if command -v dbus-send &>/dev/null; then
    if dbus-send --session --print-reply \
       --dest=org.freedesktop.secrets \
       /org/freedesktop/secrets \
       org.freedesktop.DBus.Introspectable.Introspect &>/dev/null; then
        check_ok "Secret Service API disponible en D-Bus"
    else
        check_warn "Secret Service API NO disponible"
        echo "       (Inicia sesión gráfica o reinicia gnome-keyring-daemon)"
    fi
else
    check_warn "dbus-send no está disponible"
fi

# ==============================================================================
# 7. VERIFICAR ARCHIVOS DE CONFIGURACIÓN
# ==============================================================================

print_header "7. Verificando archivos de configuración"

HYPR_AUTOSTART="$HOME/.config/hypr/autostart.conf"
if [ -f "$HYPR_AUTOSTART" ]; then
    if grep -q "gnome-keyring-daemon" "$HYPR_AUTOSTART"; then
        check_ok "Autostart de Hyprland configurado"
    else
        check_warn "Autostart de Hyprland sin gnome-keyring"
    fi
else
    check_warn "Archivo autostart.conf no existe"
fi

HYPR_MAIN="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_MAIN" ]; then
    if grep -q "source.*autostart.conf" "$HYPR_MAIN"; then
        check_ok "hyprland.conf incluye autostart.conf"
    else
        check_warn "hyprland.conf NO incluye autostart.conf"
    fi
fi

# ==============================================================================
# 8. VERIFICAR KEYRING
# ==============================================================================

print_header "8. Verificando keyrings existentes"

KEYRING_DIR="$HOME/.local/share/keyrings"
if [ -d "$KEYRING_DIR" ]; then
    check_ok "Directorio de keyrings existe: $KEYRING_DIR"
    
    if [ -f "$KEYRING_DIR/login.keyring" ]; then
        check_ok "Keyring 'login' existe"
    else
        check_warn "Keyring 'login' NO existe"
        echo "       (Se creará en el primer inicio de sesión)"
    fi
    
    # Listar keyrings
    KEYRING_COUNT=$(find "$KEYRING_DIR" -name "*.keyring" 2>/dev/null | wc -l)
    if [ "$KEYRING_COUNT" -gt 0 ]; then
        check_ok "Keyrings encontrados: $KEYRING_COUNT"
    fi
else
    check_warn "Directorio de keyrings NO existe: $KEYRING_DIR"
    echo "       (Se creará en el primer inicio de sesión)"
fi

# ==============================================================================
# 9. TEST DE FUNCIONALIDAD (OPCIONAL)
# ==============================================================================

print_header "9. Test de funcionalidad (opcional)"

if command -v secret-tool &>/dev/null; then
    check_ok "secret-tool está disponible"
    
    # Solo hacer test si hay keyring y está desbloqueado
    if [ -f "$KEYRING_DIR/login.keyring" ] && pgrep -x gnome-keyring-d >/dev/null; then
        echo "       Puedes probar: secret-tool store --label='Test' test test"
    fi
else
    check_error "secret-tool NO está disponible (falta libsecret)"
fi

if command -v seahorse &>/dev/null; then
    check_ok "seahorse (GUI) está disponible"
else
    check_warn "seahorse NO está disponible"
fi

# ==============================================================================
# RESUMEN
# ==============================================================================

print_header "RESUMEN"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Todo correcto! GNOME Keyring está correctamente configurado.${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Configuración completada con $WARNINGS advertencia(s).${NC}"
    echo "  La mayoría de las advertencias son normales si no has iniciado sesión gráfica."
else
    echo -e "${RED}✗ Se encontraron $ERRORS error(es) y $WARNINGS advertencia(s).${NC}"
    echo "  Revisa los mensajes anteriores y ejecuta los scripts de instalación."
fi

echo ""
echo -e "${BLUE}PRÓXIMOS PASOS:${NC}"
echo "  1. Si hay errores: Ejecuta install_keyring.sh y configure_keyring.sh"
echo "  2. Reinicia la sesión para cargar las variables de entorno"
echo "  3. Inicia Hyprland: gnome-keyring-daemon se iniciará automáticamente"
echo "  4. Prueba con: seahorse (GUI) o secret-tool (CLI)"
echo ""

exit $ERRORS
