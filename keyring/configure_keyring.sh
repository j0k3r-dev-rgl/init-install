#!/bin/bash

# Script de configuración de GNOME Keyring para TTY login y Hyprland
# Configura PAM para desbloqueo automático y variables de entorno

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[KEYRING]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

# ==============================================================================
# 1. CONFIGURACIÓN PAM para /etc/pam.d/login (TTY login)
# ==============================================================================

print_info "Configurando PAM para desbloqueo automático del keyring..."

PAM_LOGIN="/etc/pam.d/login"

# Verificar si el archivo PAM existe
if [ ! -f "$PAM_LOGIN" ]; then
    die "El archivo $PAM_LOGIN no existe"
fi

# Crear backup del archivo PAM
print_info "Creando backup de $PAM_LOGIN..."
sudo cp "$PAM_LOGIN" "${PAM_LOGIN}.backup.$(date +%Y%m%d_%H%M%S)"

# Verificar si las líneas ya existen
if grep -q "pam_gnome_keyring.so" "$PAM_LOGIN"; then
    print_warning "PAM ya está configurado para gnome-keyring, saltando..."
else
    print_info "Añadiendo configuración PAM para gnome-keyring..."
    
    # Crear archivo temporal con la configuración
    sudo awk '
        /^auth.*include.*system-local-login/ { 
            print; 
            print "auth       optional     pam_gnome_keyring.so"; 
            next 
        }
        /^session.*include.*system-local-login/ { 
            print; 
            print "session    optional     pam_gnome_keyring.so auto_start"; 
            next 
        }
        { print }
    ' "$PAM_LOGIN" | sudo tee "${PAM_LOGIN}.tmp" > /dev/null
    
    sudo mv "${PAM_LOGIN}.tmp" "$PAM_LOGIN"
    print_success "PAM configurado correctamente"
fi

# ==============================================================================
# 2. CONFIGURACIÓN DE AUTOSTART PARA HYPRLAND
# ==============================================================================

print_info "Configurando autostart de gnome-keyring para Hyprland..."

HYPR_CONFIG_DIR="$HOME/.config/hypr"
AUTOSTART_FILE="$HYPR_CONFIG_DIR/autostart.conf"

# Crear directorio si no existe
mkdir -p "$HYPR_CONFIG_DIR"

# Verificar si ya existe el autostart
if [ -f "$AUTOSTART_FILE" ] && grep -q "gnome-keyring-daemon" "$AUTOSTART_FILE"; then
    print_warning "Autostart de gnome-keyring ya configurado, saltando..."
else
    print_info "Añadiendo gnome-keyring-daemon al autostart de Hyprland..."
    
    # Crear o actualizar autostart.conf
    cat >> "$AUTOSTART_FILE" << 'EOF'

# === GNOME Keyring Daemon ===
# Necesario para el llavero de contraseñas y Secret Service API
exec-once = dbus-update-activation-environment --all
exec-once = gnome-keyring-daemon --start --components=secrets
EOF
    
    print_success "Autostart configurado en $AUTOSTART_FILE"
fi

# Asegurarse de que hyprland.conf incluye autostart.conf
HYPR_MAIN_CONFIG="$HYPR_CONFIG_DIR/hyprland.conf"
if [ -f "$HYPR_MAIN_CONFIG" ]; then
    if ! grep -q "source.*autostart.conf" "$HYPR_MAIN_CONFIG"; then
        print_info "Añadiendo source de autostart.conf a hyprland.conf..."
        echo "" >> "$HYPR_MAIN_CONFIG"
        echo "# Autostart applications" >> "$HYPR_MAIN_CONFIG"
        echo "source = ~/.config/hypr/autostart.conf" >> "$HYPR_MAIN_CONFIG"
        print_success "hyprland.conf actualizado"
    fi
fi

# ==============================================================================
# 3. CONFIGURACIÓN DE SSH AGENT (GCR-SSH-AGENT)
# ==============================================================================

print_info "Configurando gcr-ssh-agent para gestión de claves SSH..."

# Habilitar y iniciar el socket de gcr-ssh-agent
if systemctl --user is-enabled gcr-ssh-agent.socket &>/dev/null; then
    print_info "gcr-ssh-agent.socket ya está habilitado"
else
    print_info "Habilitando gcr-ssh-agent.socket..."
    systemctl --user enable gcr-ssh-agent.socket
fi

# Crear archivo de configuración de variables de entorno para SSH
ENV_DIR="$HOME/.config/environment.d"
mkdir -p "$ENV_DIR"

cat > "$ENV_DIR/ssh_auth_sock.conf" << 'EOF'
# SSH Agent Socket - gcr-ssh-agent (GNOME Keyring)
SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
EOF

print_success "gcr-ssh-agent configurado"

# ==============================================================================
# 4. CREAR KEYRING INICIAL (LOGIN)
# ==============================================================================

print_info "Información sobre el keyring 'login':"
echo ""
echo -e "${BLUE}IMPORTANTE:${NC}"
echo "  • El keyring 'login' se creará automáticamente en el primer inicio de sesión"
echo "  • Para desbloqueo automático, usa la MISMA contraseña que tu usuario"
echo "  • El keyring se guardará en: ~/.local/share/keyrings/login.keyring"
echo ""
echo -e "${BLUE}GESTIÓN DEL KEYRING:${NC}"
echo "  • Abrir gestor gráfico: seahorse (o 'Contraseñas y claves' en menú)"
echo "  • Ver contraseñas CLI: secret-tool search [atributo] [valor]"
echo "  • Guardar contraseña: secret-tool store --label='Mi Password' [atributo] [valor]"
echo ""

# ==============================================================================
# 5. VERIFICACIÓN
# ==============================================================================

print_info "Verificando instalación..."

# Verificar que los paquetes están instalados
for pkg in gnome-keyring libsecret seahorse gcr-4; do
    if pacman -Q "$pkg" &>/dev/null; then
        print_success "$pkg instalado"
    else
        print_warning "$pkg NO instalado"
    fi
done

# Verificar PAM
if grep -q "pam_gnome_keyring.so" "$PAM_LOGIN"; then
    print_success "Configuración PAM OK"
else
    print_warning "Configuración PAM incompleta"
fi

# Verificar autostart
if [ -f "$AUTOSTART_FILE" ] && grep -q "gnome-keyring-daemon" "$AUTOSTART_FILE"; then
    print_success "Autostart de Hyprland OK"
else
    print_warning "Autostart de Hyprland no configurado"
fi

echo ""
print_success "¡Configuración de GNOME Keyring completada!"
echo ""
echo -e "${GREEN}PRÓXIMOS PASOS:${NC}"
echo "  1. Reinicia la sesión (logout/login)"
echo "  2. Al iniciar sesión, se creará automáticamente el keyring 'login'"
echo "  3. Las aplicaciones podrán guardar contraseñas automáticamente"
echo ""
echo -e "${GREEN}COMANDOS ÚTILES:${NC}"
echo "  • Abrir Seahorse (GUI):       ${BLUE}seahorse${NC}"
echo "  • Listar secretos:             ${BLUE}secret-tool search --all${NC}"
echo "  • Estado SSH agent:            ${BLUE}ssh-add -l${NC}"
echo "  • Guardar passphrase SSH:      ${BLUE}/usr/lib/seahorse/ssh-askpass ~/.ssh/id_rsa${NC}"
echo ""
