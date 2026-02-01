# Guía de Comandos - Setup Arch Linux

Esta guía contiene todos los comandos útiles para gestionar tu sistema después de la instalación.

---

## 🐚 ZSH y Terminal

### Powerlevel10k
```bash
p10k configure              # Reconfigurar el tema de Powerlevel10k
source ~/.zshrc             # Recargar configuración de ZSH
```

### Alias Configurados (eza)
```bash
ls                          # Lista archivos con iconos
ll                          # Lista detallada con iconos
la                          # Lista todos los archivos (incluyendo ocultos)
```

---

## 🖥️ Hyprland (Compositor Wayland)

### Comandos Básicos
```bash
start-hyprland              # Iniciar Hyprland manualmente
Hyprland                    # Iniciar Hyprland directamente
```

### Atajos de Teclado (Predeterminados)
- `SUPER + Q` - Cerrar ventana
- `SUPER + T` - Abrir terminal (Kitty)
- `SUPER + D` - Abrir launcher (Rofi)
- `SUPER + E` - Abrir gestor de archivos (Dolphin)
- `SUPER + F` - Pantalla completa
- `SUPER + V` - Cambiar a modo flotante

### Configuración
```bash
nvim ~/.config/hypr/hyprland.conf    # Editar configuración de Hyprland
```

---

## 🔐 Llavero de Contraseñas (GNOME Keyring)

### Interfaz Gráfica
```bash
seahorse                        # Abrir gestor de contraseñas (GUI)
```

### Gestión de Contraseñas (secret-tool)
```bash
# Guardar una contraseña
secret-tool store --label='Descripción' atributo valor

# Ejemplo: Guardar credencial de servidor
secret-tool store --label='Servidor SSH' server ejemplo.com user mi_usuario

# Buscar contraseñas
secret-tool search atributo valor
secret-tool search --all        # Listar todas las contraseñas

# Recuperar una contraseña
secret-tool lookup atributo valor

# Eliminar una contraseña
secret-tool clear atributo valor
```

### SSH Agent (gcr-ssh-agent)
```bash
ssh-add -l                      # Listar claves SSH cargadas
ssh-add ~/.ssh/id_rsa           # Añadir clave SSH al agente
ssh-add -D                      # Eliminar todas las claves del agente

# Guardar passphrase SSH en el keyring
/usr/lib/seahorse/ssh-askpass ~/.ssh/id_rsa

# Ver estado del SSH agent
echo $SSH_AUTH_SOCK
systemctl --user status gcr-ssh-agent.socket
```

### Git con Keyring
```bash
# Configurar Git para usar el keyring
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# Git guardará automáticamente las credenciales HTTPS
```

### Bloquear/Desbloquear Keyring
```bash
# Bloquear el keyring manualmente
dbus-send --session --dest=org.freedesktop.secrets \
  --type=method_call \
  /org/freedesktop/secrets \
  org.freedesktop.Secret.Service.Lock \
  array:objpath:/org/freedesktop/secrets/collection/login
```

### Servicio GNOME Keyring
```bash
ps aux | grep gnome-keyring     # Verificar que esté corriendo
systemctl --user status gnome-keyring-daemon.service
```



## 🐳 Docker

### Comandos Básicos
```bash
docker ps                             # Listar contenedores activos
docker ps -a                          # Listar todos los contenedores
docker images                         # Listar imágenes
docker pull <imagen>                  # Descargar imagen
docker run <imagen>                   # Ejecutar contenedor
docker stop <contenedor>              # Detener contenedor
docker rm <contenedor>                # Eliminar contenedor
docker rmi <imagen>                   # Eliminar imagen
```

### Docker Compose
```bash
docker-compose up                     # Iniciar servicios
docker-compose up -d                  # Iniciar en segundo plano
docker-compose down                   # Detener y eliminar contenedores
docker-compose logs                   # Ver logs
docker-compose ps                     # Ver servicios activos
```

### Servicio Docker
```bash
sudo systemctl status docker          # Ver estado del servicio
sudo systemctl start docker           # Iniciar Docker
sudo systemctl stop docker            # Detener Docker
```

---

## 💻 Desarrollo

### NVM (Node Version Manager)
```bash
nvm ls                                # Listar versiones de Node instaladas
nvm ls-remote                         # Listar versiones disponibles
nvm install <version>                 # Instalar versión de Node
nvm install --lts                     # Instalar última versión LTS
nvm use <version>                     # Usar versión específica
nvm alias default <version>           # Establecer versión por defecto
node --version                        # Ver versión actual de Node
npm --version                         # Ver versión de npm
```

### Bun (JavaScript Runtime)
```bash
bun --version                         # Ver versión de Bun
bun install                           # Instalar dependencias
bun run <script>                      # Ejecutar script
bun add <paquete>                     # Agregar paquete
bun remove <paquete>                  # Eliminar paquete
bun create <template>                 # Crear proyecto desde template
bun upgrade                           # Actualizar Bun
```

### Java (JDK)
```bash
java -version                         # Ver versión de Java
javac -version                        # Ver versión del compilador
```

### Maven
```bash
mvn --version                         # Ver versión de Maven
mvn clean install                     # Compilar proyecto
mvn package                           # Empaquetar aplicación
mvn test                              # Ejecutar tests
```

### MongoDB Compass
```bash
mongodb-compass-update                # Actualizar MongoDB Compass
/opt/mongodb-compass/MongoDB\ Compass # Ejecutar manualmente
# También disponible en Rofi como "MongoDB Compass"
```

---

## 📦 Gestión de Paquetes

### Actualización Completa del Sistema
```bash
update                                # Actualizar TODO (pacman + yay + MongoDB Compass)
                                     # Incluye limpieza opcional de paquetes huérfanos
```

### Pacman
```bash
sudo pacman -Syu                      # Actualizar sistema completo
sudo pacman -S <paquete>              # Instalar paquete
sudo pacman -R <paquete>              # Eliminar paquete
sudo pacman -Rs <paquete>             # Eliminar paquete y dependencias
sudo pacman -Ss <término>             # Buscar paquete
sudo pacman -Qi <paquete>             # Ver información de paquete instalado
sudo pacman -Qe                       # Listar paquetes instalados explícitamente
sudo pacman -Sc                       # Limpiar caché de paquetes
```

### Yay (AUR Helper)
```bash
yay -Syu                              # Actualizar sistema y paquetes AUR
yay -S <paquete>                      # Instalar paquete de AUR
yay -R <paquete>                      # Eliminar paquete
yay -Ss <término>                     # Buscar en repositorios y AUR
yay -Ps                               # Mostrar estadísticas del sistema
yay -Yc                               # Limpiar dependencias huérfanas
```

---

## 🖼️ Aplicaciones

### Rofi (Lanzador)
```bash
rofi -show drun                       # Mostrar aplicaciones
rofi -show run                        # Mostrar comandos
rofi -show window                     # Mostrar ventanas
```

### Kitty (Terminal)
```bash
kitty +kitten themes                  # Cambiar tema de Kitty
nvim ~/.config/kitty/kitty.conf       # Editar configuración de Kitty
```

### Neovim
```bash
nvim                                  # Abrir Neovim
nvim <archivo>                        # Abrir archivo
:checkhealth                          # Verificar salud de Neovim (dentro de nvim)
```

---

## 🔌 Dispositivos USB

### Montaje Automático (udiskie)
```bash
systemctl --user status udiskie       # Ver estado del servicio
systemctl --user start udiskie        # Iniciar servicio
systemctl --user enable udiskie       # Habilitar al inicio
```

### Montaje Manual
```bash
lsblk                                 # Listar dispositivos de bloque
udisksctl mount -b /dev/sdX1          # Montar partición
udisksctl unmount -b /dev/sdX1        # Desmontar partición
```

---

## 🔊 Audio (PipeWire)

### Comandos Básicos
```bash
wpctl status                          # Ver estado de PipeWire
wpctl get-volume @DEFAULT_SINK@       # Ver volumen actual
wpctl set-volume @DEFAULT_SINK@ 50%   # Establecer volumen al 50%
wpctl set-mute @DEFAULT_SINK@ toggle  # Silenciar/activar audio
```

### Servicio PipeWire
```bash
systemctl --user status pipewire      # Ver estado del servicio
systemctl --user restart pipewire     # Reiniciar PipeWire
```

---

## 🌐 Red

### NetworkManager
```bash
nmcli device status                   # Ver estado de dispositivos
nmcli connection show                 # Listar conexiones
nmcli device wifi list                # Listar redes WiFi
nmcli device wifi connect <SSID> password <password>  # Conectar a WiFi
nmcli connection up <nombre>          # Activar conexión
nmcli connection down <nombre>        # Desactivar conexión
```

### Estado de Red
```bash
ip a                                  # Ver direcciones IP
ping 8.8.8.8                          # Verificar conectividad
```

---

## 🔧 Sistema

### Systemd (Servicios)
```bash
sudo systemctl status <servicio>      # Ver estado de servicio
sudo systemctl start <servicio>       # Iniciar servicio
sudo systemctl stop <servicio>        # Detener servicio
sudo systemctl restart <servicio>     # Reiniciar servicio
sudo systemctl enable <servicio>      # Habilitar al inicio
sudo systemctl disable <servicio>     # Deshabilitar al inicio
systemctl --user <comando>            # Comandos para servicios de usuario
```

### Monitoreo del Sistema
```bash
htop                                  # Monitor de procesos (tradicional)
btop                                  # Monitor de procesos moderno
free -h                               # Ver uso de memoria
df -h                                 # Ver uso de disco
nvidia-smi                            # Monitor de GPU NVIDIA (si aplica)
```

### Logs
```bash
journalctl -xe                        # Ver últimos logs del sistema
journalctl -f                         # Seguir logs en tiempo real
journalctl -u <servicio>              # Ver logs de servicio específico
journalctl --since "1 hour ago"       # Logs de la última hora
```

---

## 🔐 SSH

### Comandos Básicos
```bash
ssh usuario@servidor                  # Conectar a servidor
ssh-keygen -t ed25519                 # Generar nueva clave SSH
ssh-copy-id usuario@servidor          # Copiar clave pública al servidor
```

### Servicio SSH
```bash
sudo systemctl status sshd            # Ver estado del servicio SSH
sudo systemctl start sshd             # Iniciar SSH
sudo systemctl enable sshd            # Habilitar SSH al inicio
```

---

## 🔍 Búsqueda y Archivos

### fzf (Fuzzy Finder)
```bash
fzf                                   # Buscar archivos interactivamente
CTRL+R                                # Buscar en historial (en terminal)
CTRL+T                                # Buscar archivos (en terminal)
ALT+C                                 # Cambiar directorio (en terminal)
```

### Búsqueda de Archivos
```bash
find . -name "*.txt"                  # Buscar archivos por nombre
fd <término>                          # Búsqueda rápida (si fd está instalado)
locate <archivo>                      # Buscar en base de datos (requiere updatedb)
```

---

## 📝 Variables de Entorno

Las siguientes variables están configuradas automáticamente en `~/.zshrc`:

- `PATH` incluye `~/.local/bin`
- `BUN_INSTALL` apunta a `~/.bun`
- `NVM_DIR` apunta a `~/.nvm`
- `JAVA_HOME` apunta a `/usr/lib/jvm/default`
- `M2_HOME` y `MAVEN_HOME` apuntan a `~/.local/share/maven`

---

## 🆘 Ayuda Rápida

Para ver esta guía en cualquier momento, simplemente escribe en tu terminal:

```bash
h
```

---

**Nota:** Este archivo se genera automáticamente durante la instalación.
Para más información, consulta el archivo `README.md` del repositorio.
