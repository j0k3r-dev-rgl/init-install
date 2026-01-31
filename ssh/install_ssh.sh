#!/bin/bash

# ============================================================================
# Script de instalación y configuración de SSH
# Instala OpenSSH, copia configuración y genera claves SSH
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# --- Colores para la salida ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $*"
}

print_section() {
    echo -e "${BLUE}[*]${NC} $*"
}

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

echo "============================================"
echo "Instalador y Configurador de SSH"
echo "============================================"
echo ""

# 1. Instalación de OpenSSH
print_info "Instalando OpenSSH..."
pacman_install openssh nano

# 2. Habilitar y arrancar el servicio SSH
print_info "Habilitando servicio SSH..."
sudo systemctl enable sshd.service
sudo systemctl start sshd.service
print_success "Servicio SSH habilitado y en ejecución"

# 3. Crear directorio .ssh si no existe
print_info "Preparando directorio ~/.ssh..."
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
print_success "Directorio ~/.ssh preparado con permisos correctos"

# 4. Copiar archivo de configuración SSH
SSH_CONFIG_SOURCE="${SCRIPT_DIR}/config"
SSH_CONFIG_DEST="${HOME}/.ssh/config"

if [ -f "$SSH_CONFIG_SOURCE" ]; then
    print_info "Copiando archivo de configuración SSH..."
    
    if [ -f "$SSH_CONFIG_DEST" ]; then
        if [ -t 0 ] && [ -t 1 ]; then
            echo -n "Ya existe un archivo config en ~/.ssh. ¿Deseas sobreescribirlo? (s/n, por defecto: n): "
            read -r overwrite_config
            case "$overwrite_config" in
                [sS]|[sS][iI])
                    backup_file="${SSH_CONFIG_DEST}.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$SSH_CONFIG_DEST" "$backup_file"
                    print_info "Backup guardado en: $backup_file"
                    cp "$SSH_CONFIG_SOURCE" "$SSH_CONFIG_DEST"
                    chmod 600 "$SSH_CONFIG_DEST"
                    print_success "Archivo config copiado y permisos establecidos"
                    ;;
                *)
                    print_warning "Manteniendo archivo config existente"
                    ;;
            esac
        else
            print_warning "Archivo config ya existe. No se sobreescribió"
        fi
    else
        cp "$SSH_CONFIG_SOURCE" "$SSH_CONFIG_DEST"
        chmod 600 "$SSH_CONFIG_DEST"
        print_success "Archivo config copiado y permisos establecidos"
    fi
else
    print_warning "No se encontró archivo de configuración en: $SSH_CONFIG_SOURCE"
fi

# 4.5. Copiar archivo README con instrucciones
SSH_README_SOURCE="${SCRIPT_DIR}/readme.md"
SSH_README_DEST="${HOME}/.ssh/readme.md"

if [ -f "$SSH_README_SOURCE" ]; then
    print_info "Copiando archivo de instrucciones SSH..."
    cp "$SSH_README_SOURCE" "$SSH_README_DEST"
    chmod 644 "$SSH_README_DEST"
    print_success "Archivo de instrucciones copiado a ~/.ssh/readme.md"
fi

# 5. Generación de claves SSH (3 claves diferentes)
if [ -t 0 ] && [ -t 1 ]; then
    echo ""
    echo "============================================"
    print_section "Generación de Claves SSH"
    echo "============================================"
    echo ""
    echo "Se generarán 3 claves SSH diferentes:"
    echo "  1. Para servidores (KVM, VPS, etc.)"
    echo "  2. Para GitHub"
    echo "  3. Para otros usos (backup, etc.)"
    echo ""
    echo -n "¿Deseas generar las claves SSH? (s/n, por defecto: s): "
    read -r generate_keys
    
    case "$generate_keys" in
        [nN]|[nN][oO])
            print_info "Generación de claves SSH omitida"
            ;;
        *)
            # --- Clave 1: Para Servidores ---
            echo ""
            print_section "Clave 1: Para Servidores"
            echo ""
            echo "Esta clave se usará para conectarte a tus servidores (kvm2, kvm4, etc.)"
            echo -n "Nombre para la clave del servidor [id_ed25519_server]: "
            read -r key_server_name
            key_server_name="${key_server_name:-id_ed25519_server}"
            
            echo -n "Email para identificar la clave (ej: admin@tudominio.com): "
            read -r key_server_email
            
            SSH_KEY_SERVER="${HOME}/.ssh/${key_server_name}"
            
            if [ -f "$SSH_KEY_SERVER" ]; then
                echo -n "La clave ya existe. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
                read -r overwrite_server
                case "$overwrite_server" in
                    [sS]|[sS][iI])
                        if [ -n "$key_server_email" ]; then
                            ssh-keygen -t ed25519 -C "$key_server_email" -f "$SSH_KEY_SERVER"
                        else
                            ssh-keygen -t ed25519 -f "$SSH_KEY_SERVER"
                        fi
                        ;;
                    *)
                        print_info "Manteniendo clave existente del servidor"
                        ;;
                esac
            else
                if [ -n "$key_server_email" ]; then
                    ssh-keygen -t ed25519 -C "$key_server_email" -f "$SSH_KEY_SERVER"
                else
                    ssh-keygen -t ed25519 -f "$SSH_KEY_SERVER"
                fi
            fi
            
            if [ -f "$SSH_KEY_SERVER" ]; then
                chmod 600 "$SSH_KEY_SERVER"
                chmod 644 "${SSH_KEY_SERVER}.pub"
                print_success "Clave del servidor generada: $SSH_KEY_SERVER"
            fi
            
            # --- Clave 2: Para GitHub ---
            echo ""
            print_section "Clave 2: Para GitHub"
            echo ""
            echo "Esta clave se usará para autenticarte con GitHub (git clone, push, etc.)"
            echo -n "Nombre para la clave de GitHub [id_ed25519_github]: "
            read -r key_github_name
            key_github_name="${key_github_name:-id_ed25519_github}"
            
            echo -n "Email de tu cuenta de GitHub (debe coincidir con tu email de GitHub): "
            read -r key_github_email
            
            SSH_KEY_GITHUB="${HOME}/.ssh/${key_github_name}"
            
            if [ -f "$SSH_KEY_GITHUB" ]; then
                echo -n "La clave ya existe. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
                read -r overwrite_github
                case "$overwrite_github" in
                    [sS]|[sS][iI])
                        if [ -n "$key_github_email" ]; then
                            ssh-keygen -t ed25519 -C "$key_github_email" -f "$SSH_KEY_GITHUB"
                        else
                            ssh-keygen -t ed25519 -f "$SSH_KEY_GITHUB"
                        fi
                        ;;
                    *)
                        print_info "Manteniendo clave existente de GitHub"
                        ;;
                esac
            else
                if [ -n "$key_github_email" ]; then
                    ssh-keygen -t ed25519 -C "$key_github_email" -f "$SSH_KEY_GITHUB"
                else
                    ssh-keygen -t ed25519 -f "$SSH_KEY_GITHUB"
                fi
            fi
            
            if [ -f "$SSH_KEY_GITHUB" ]; then
                chmod 600 "$SSH_KEY_GITHUB"
                chmod 644 "${SSH_KEY_GITHUB}.pub"
                print_success "Clave de GitHub generada: $SSH_KEY_GITHUB"
            fi
            
            # --- Clave 3: Para Otros Usos ---
            echo ""
            print_section "Clave 3: Para Otros Usos"
            echo ""
            echo "Esta clave es para otros propósitos (backup, otros servidores, etc.)"
            echo -n "Nombre para la clave adicional [id_ed25519_other]: "
            read -r key_other_name
            key_other_name="${key_other_name:-id_ed25519_other}"
            
            echo -n "Email o identificador para esta clave: "
            read -r key_other_email
            
            SSH_KEY_OTHER="${HOME}/.ssh/${key_other_name}"
            
            if [ -f "$SSH_KEY_OTHER" ]; then
                echo -n "La clave ya existe. ¿Deseas sobreescribirla? (s/n, por defecto: n): "
                read -r overwrite_other
                case "$overwrite_other" in
                    [sS]|[sS][iI])
                        if [ -n "$key_other_email" ]; then
                            ssh-keygen -t ed25519 -C "$key_other_email" -f "$SSH_KEY_OTHER"
                        else
                            ssh-keygen -t ed25519 -f "$SSH_KEY_OTHER"
                        fi
                        ;;
                    *)
                        print_info "Manteniendo clave adicional existente"
                        ;;
                esac
            else
                if [ -n "$key_other_email" ]; then
                    ssh-keygen -t ed25519 -C "$key_other_email" -f "$SSH_KEY_OTHER"
                else
                    ssh-keygen -t ed25519 -f "$SSH_KEY_OTHER"
                fi
            fi
            
            if [ -f "$SSH_KEY_OTHER" ]; then
                chmod 600 "$SSH_KEY_OTHER"
                chmod 644 "${SSH_KEY_OTHER}.pub"
                print_success "Clave adicional generada: $SSH_KEY_OTHER"
            fi
            
            echo ""
            echo "============================================"
            print_success "¡Todas las claves SSH generadas!"
            echo "============================================"
            echo ""
            
            # Mostrar resumen de claves públicas
            echo "📋 CLAVES PÚBLICAS GENERADAS:"
            echo ""
            
            if [ -f "${SSH_KEY_SERVER}.pub" ]; then
                echo "🔐 CLAVE PARA SERVIDORES (${key_server_name}):"
                echo "----------------------------------------"
                cat "${SSH_KEY_SERVER}.pub"
                echo "----------------------------------------"
                echo ""
            fi
            
            if [ -f "${SSH_KEY_GITHUB}.pub" ]; then
                echo "🔐 CLAVE PARA GITHUB (${key_github_name}):"
                echo "----------------------------------------"
                cat "${SSH_KEY_GITHUB}.pub"
                echo "----------------------------------------"
                echo ""
            fi
            
            if [ -f "${SSH_KEY_OTHER}.pub" ]; then
                echo "🔐 CLAVE ADICIONAL (${key_other_name}):"
                echo "----------------------------------------"
                cat "${SSH_KEY_OTHER}.pub"
                echo "----------------------------------------"
                echo ""
            fi
            ;;
    esac
fi

echo ""
echo "============================================"
print_success "Configuración de SSH completada!"
echo "============================================"
echo ""
echo "📋 Resumen:"
echo ""
echo "✓ OpenSSH instalado y servicio habilitado"
echo "✓ Directorio ~/.ssh configurado con permisos correctos"
if [ -f "$SSH_CONFIG_DEST" ]; then
    echo "✓ Archivo de configuración SSH copiado en ~/.ssh/config"
fi

# Contar claves generadas
keys_count=0
[ -f "${HOME}/.ssh/${key_server_name:-id_ed25519_server}" ] && keys_count=$((keys_count + 1))
[ -f "${HOME}/.ssh/${key_github_name:-id_ed25519_github}" ] && keys_count=$((keys_count + 1))
[ -f "${HOME}/.ssh/${key_other_name:-id_ed25519_other}" ] && keys_count=$((keys_count + 1))

if [ "$keys_count" -gt 0 ]; then
    echo "✓ $keys_count clave(s) SSH generadas"
fi

echo ""
echo "📝 Próximos pasos:"
echo ""
echo "1. Configurar hosts en ~/.ssh/config con las IPs de tus servidores"
echo ""
if [ -f "${HOME}/.ssh/${key_server_name:-id_ed25519_server}.pub" ]; then
    echo "2. Para servidores - Copia esta clave pública a tus servidores:"
    echo "   ssh-copy-id -i ~/.ssh/${key_server_name:-id_ed25519_server}.pub usuario@servidor"
    echo ""
fi

if [ -f "${HOME}/.ssh/${key_github_name:-id_ed25519_github}.pub" ]; then
    echo "3. Para GitHub - Agrega esta clave pública en:"
    echo "   https://github.com/settings/keys"
    echo "   (Settings > SSH and GPG keys > New SSH key)"
    echo ""
    echo "   O usa este comando si tienes gh CLI instalado:"
    echo "   gh ssh-key add ~/.ssh/${key_github_name:-id_ed25519_github}.pub"
    echo ""
fi

echo "4. Verifica la conexión SSH a un servidor:"
echo "   ssh usuario@servidor"
echo ""
echo "============================================"
