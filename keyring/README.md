# 🔐 Configuración del Llavero de Contraseñas (GNOME Keyring)

## Descripción

Este módulo instala y configura **GNOME Keyring**, el sistema estándar de llavero de contraseñas en Linux basado en la **Secret Service API (org.freedesktop.secrets)**.

## ¿Qué es GNOME Keyring?

GNOME Keyring es un demonio que almacena de forma segura contraseñas, claves SSH, certificados y otros secretos. Proporciona:

- **Secret Service API**: Estándar freedesktop.org para almacenamiento de secretos
- **SSH Agent**: Gestión de claves SSH (a través de gcr-ssh-agent)
- **Desbloqueo automático**: Se desbloquea con tu contraseña de usuario (vía PAM)
- **Compatibilidad universal**: Funciona con GNOME, KDE, Hyprland, i3, etc.

## Componentes Instalados

| Paquete | Descripción |
|---------|-------------|
| `gnome-keyring` | Demonio principal del keyring |
| `libsecret` | Biblioteca para Secret Service API |
| `seahorse` | Interfaz gráfica (Contraseñas y Claves) |
| `gcr-4` | SSH agent basado en GNOME Keyring |

## Configuración Aplicada

### 1. PAM (Pluggable Authentication Modules)

Se modifica `/etc/pam.d/login` para:
- Desbloquear automáticamente el keyring al iniciar sesión
- Crear el keyring si no existe

```pam
auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start
```

**IMPORTANTE**: El keyring debe tener la **misma contraseña** que tu usuario para el desbloqueo automático.

### 2. Autostart en Hyprland

El autostart de gnome-keyring está integrado en la configuración modular de Hyprland (`hyprland/conf/autostart.conf`).

Las líneas añadidas son:
```bash
# Actualizar variables de entorno D-Bus
exec-once = dbus-update-activation-environment --all

# Iniciar gnome-keyring-daemon
exec-once = gnome-keyring-daemon --start --components=secrets
```

Si se ejecuta `configure_keyring.sh` de forma independiente, este verificará y añadirá estas líneas a `~/.config/hypr/autostart.conf` si no están presentes.

### 3. SSH Agent (gcr-ssh-agent)

Se configura el socket systemd:
```bash
systemctl --user enable gcr-ssh-agent.socket
```

Y se establece la variable de entorno en `~/.config/environment.d/ssh_auth_sock.conf`:
```bash
SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
```

## Uso

### Interfaz Gráfica (Seahorse)

Abrir el gestor de contraseñas:
```bash
seahorse
```

O buscar "Contraseñas y claves" en el menú de aplicaciones.

### Línea de Comandos (secret-tool)

#### Guardar una contraseña
```bash
secret-tool store --label='Mi Servidor SSH' \
  server ejemplo.com \
  user mi_usuario
# Te pedirá la contraseña a guardar
```

#### Buscar contraseñas
```bash
# Buscar por atributo
secret-tool search server ejemplo.com

# Listar todos los secretos
secret-tool search --all
```

#### Recuperar una contraseña
```bash
secret-tool lookup server ejemplo.com user mi_usuario
```

#### Eliminar una contraseña
```bash
secret-tool clear server ejemplo.com user mi_usuario
```

### Gestión de Claves SSH

#### Listar claves cargadas
```bash
ssh-add -l
```

#### Añadir una clave SSH al keyring
```bash
/usr/lib/seahorse/ssh-askpass ~/.ssh/id_rsa
```

O simplemente usa la clave (te pedirá la passphrase la primera vez):
```bash
ssh -i ~/.ssh/id_rsa usuario@servidor
```

**Tip**: Marca "Recordar contraseña" en el diálogo para guardarla en el keyring.

#### Ver estado del SSH agent
```bash
echo $SSH_AUTH_SOCK
# Debería mostrar: /run/user/1000/gcr/ssh

systemctl --user status gcr-ssh-agent.socket
```

## Aplicaciones que Usan el Keyring

Muchas aplicaciones se integran automáticamente:

- **Navegadores**: Chromium, Firefox (con configuración)
- **Git**: Para credenciales HTTPS
- **Gestores de correo**: Evolution, Thunderbird
- **Gestores de archivos**: Nautilus, Thunar (para conexiones remotas)
- **Aplicaciones Flatpak**: A través de xdg-desktop-portal

### Ejemplo: Git con GNOME Keyring

```bash
# Configurar Git para usar libsecret
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# Ahora Git guardará automáticamente las credenciales HTTPS
git clone https://github.com/usuario/repo.git
# Te pedirá usuario/password la primera vez, luego los recordará
```

### Ejemplo: Chromium/Chrome

Chromium usa automáticamente GNOME Keyring en Linux. Tus contraseñas de sitios web se guardan cifradas en el keyring.

Para verificar:
```bash
secret-tool search application chrome
```

## Estructura de Archivos

```
~/.local/share/keyrings/
├── login.keyring          # Keyring principal (cifrado)
├── user.keystore          # Almacén de certificados
└── Default_keyring.keyring # Keyring por defecto

~/.config/environment.d/
└── ssh_auth_sock.conf     # Variables de entorno SSH

~/.config/hypr/
└── autostart.conf         # Autostart de gnome-keyring
```

## Resolución de Problemas

### El keyring no se desbloquea automáticamente

**Causa**: La contraseña del keyring no coincide con la del usuario.

**Solución**:
1. Abre Seahorse
2. Haz clic derecho en "Login" → "Cambiar contraseña"
3. Usa la **misma contraseña** que tu usuario del sistema

### Las aplicaciones no recuerdan contraseñas

**Verificar**:
```bash
# Ver si gnome-keyring está corriendo
ps aux | grep gnome-keyring

# Verificar D-Bus
dbus-send --session --print-reply \
  --dest=org.freedesktop.secrets \
  /org/freedesktop/secrets \
  org.freedesktop.DBus.Introspectable.Introspect
```

### SSH agent no funciona

**Verificar**:
```bash
# Variable de entorno
echo $SSH_AUTH_SOCK

# Socket activo
systemctl --user status gcr-ssh-agent.socket

# Reiniciar si es necesario
systemctl --user restart gcr-ssh-agent.socket
```

### Resetear el keyring completamente

**⚠️ ADVERTENCIA**: Esto eliminará todas las contraseñas guardadas.

```bash
# Detener el demonio
pkill gnome-keyring-daemon

# Eliminar keyrings
rm -rf ~/.local/share/keyrings/*

# Reiniciar sesión
```

## Seguridad

### ¿Es seguro?

- ✅ Las contraseñas se cifran con **AES-128** o **Blowfish**
- ✅ El keyring se cifra con tu contraseña de usuario
- ✅ Compatible con TPM para mayor seguridad
- ⚠️ El keyring permanece desbloqueado mientras la sesión está activa
- ⚠️ Si alguien accede físicamente a tu sesión activa, puede acceder al keyring

### Keyring vacío (sin contraseña)

**NO RECOMENDADO**: Puedes crear un keyring sin contraseña, pero los secretos se guardarán **SIN CIFRAR**.

Solo hazlo si:
- Es un sistema de pruebas
- No guardas información sensible
- Priorizas comodidad sobre seguridad

### Bloquear el keyring manualmente

```bash
# Bloquear el keyring "login"
dbus-send --session --dest=org.freedesktop.secrets \
  --type=method_call \
  /org/freedesktop/secrets \
  org.freedesktop.Secret.Service.Lock \
  array:objpath:/org/freedesktop/secrets/collection/login
```

## Alternativas

| Herramienta | Ventajas | Desventajas |
|-------------|----------|-------------|
| **KDE Wallet** | Mejor integración con KDE | Solo para KDE Plasma |
| **pass** | CLI simple, Git-friendly | Sin GUI, manual |
| **Bitwarden** | Multiplataforma, sincronización | Requiere cuenta externa |
| **1Password** | Excelente UX, sincronización | Comercial, no FOSS |

## Referencias

- [ArchWiki: GNOME/Keyring](https://wiki.archlinux.org/title/GNOME/Keyring)
- [freedesktop.org Secret Service API](https://www.freedesktop.org/wiki/Specifications/secret-storage-spec/)
- [GNOME Keyring Project](https://wiki.gnome.org/Projects/GnomeKeyring)
- [Seahorse Documentation](https://help.gnome.org/users/seahorse/)

