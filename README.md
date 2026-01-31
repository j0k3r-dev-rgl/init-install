# Instalación Inicial - Arch Linux Dev Environment

[Español](#español) | [English](#english)

---

## Español

### ¿Qué es este proyecto?

Este repositorio contiene un conjunto de scripts **modulares y organizados** para automatizar la instalación y configuración inicial de un **entorno de desarrollo completo** en Arch Linux (y derivados) después de una instalación desde cero.

**Enfoque:** Sistema listo para desarrollo con Neovim personalizado, Hyprland como compositor Wayland, ZSH como shell por defecto, y todas las herramientas necesarias para programar en múltiples lenguajes.

### Características Principales

✅ **Instalación completamente modular y organizada**
✅ **Sistema base con drivers automáticos (NVIDIA/AMD/Intel)**
✅ **Hyprland como compositor Wayland**
✅ **ZSH + Oh My Zsh + Powerlevel10k configurado automáticamente**
✅ **Neovim con configuraciones personalizadas**
✅ **Herramientas de desarrollo (NVM, JDK 25, Maven, Docker)**
✅ **Cloudflare WARP integrado**
✅ **Fuentes Nerd Fonts para terminal**

### Herramientas y Componentes Instalados

#### 🎨 Entorno Gráfico y Aplicaciones
- **Hyprland** - Compositor Wayland moderno y eficiente
- **Kitty** - Emulador de terminal GPU-accelerated
- **Rofi** - Lanzador de aplicaciones (con temas de adi1090x)
- **Dolphin** - Gestor de archivos con soporte USB completo
- **mpv** - Reproductor de video y audio (optimizado para Wayland)
- **imv** - Visor de imágenes nativo para Wayland
- **MongoDB Compass** - GUI para MongoDB (opcional)
- **Fuentes**: JetBrains Mono Nerd, Font Awesome, Noto Emoji

#### 🔌 Soporte de Dispositivos
- **udisks2** - Sistema de montaje de discos automático
- **udiskie** - Automontaje de USB con icono en bandeja
- **gvfs** - Sistema de archivos virtual (MTP, PTP, AFC)

#### 🖥️ Sistema y Drivers
- **NetworkManager** - Gestión de red
- **PipeWire** - Sistema de audio moderno (reemplaza PulseAudio)
- **Códecs multimedia** - FFmpeg, GStreamer (todos los plugins)
- **Microcódigo CPU** - AMD/Intel (detección automática)
- **Drivers GPU** - NVIDIA/AMD/Intel (detección automática)

#### 🐚 Shell y Herramientas CLI
- **ZSH** - Shell por defecto
- **Oh My Zsh** - Framework de configuración
- **Powerlevel10k** - Tema avanzado con iconos
- **zsh-autosuggestions** - Sugerencias automáticas
- **zsh-syntax-highlighting** - Resaltado de sintaxis
- **fzf** - Fuzzy finder
- **eza** - Reemplazo moderno de `ls` con iconos
- **htop** - Monitor de procesos interactivo
- **btop** - Monitor de recursos moderno y visual

#### 💻 Desarrollo
- **Neovim** - Editor de texto avanzado con configuraciones personalizadas
- **Lombok** - Biblioteca Java para reducir código boilerplate (incluida con Neovim)
- **Bun** - JavaScript runtime ultrarrápido y toolkit all-in-one
- **NVM** - Node Version Manager
- **JDK 25** - Java Development Kit
- **Maven** - Gestor de dependencias Java
- **Docker + Docker Compose** - Contenedores
- **MongoDB Compass** - Cliente GUI para MongoDB con auto-actualización

#### 🌐 Red y Seguridad
- **Cloudflare WARP** - VPN y DNS seguro
- **SSH** - Configuración de servidor SSH
- **GNOME Keyring** - Sistema de llavero de contraseñas (Secret Service API)

#### 📦 Aplicaciones AUR
- **Google Chrome** - Navegador web
- **OnlyOffice** - Suite de oficina
- **opencode.ai** - CLI interactiva de IA

### Estructura del Repositorio

```
instalacion-inicial/
├── install.sh                    # Script principal orquestador
│
├── cloudflare_warp/              # Configuración de Cloudflare WARP
│   └── configure_warp.sh
│
├── drivers_utilities/            # Drivers y utilidades del sistema
│   ├── README.md                 # Documentación detallada
│   ├── network_install.sh        # NetworkManager
│   ├── audio_install.sh          # PipeWire (audio)
│   ├── codecs_install.sh         # Códecs multimedia
│   ├── cpu_microcode_install.sh  # Microcódigo AMD/Intel
│   └── gpu_drivers_install.sh    # Drivers NVIDIA/AMD/Intel
│
├── hyprland/                     # Compositor Wayland
│   ├── install_hyprland.sh       # Instalación
│   └── configure_hyprland.sh     # Configuración y autostart
│
├── yay_install/                  # Paquetes de AUR
│   └── install_yay_packages.sh   # Chrome, OnlyOffice, WARP
│
├── zsh/                          # Shell ZSH
│   ├── install_zsh.sh            # ZSH + Oh My Zsh + Powerlevel10k
│   └── change_shell.sh           # Cambio de shell por defecto
│
├── rofi/                         # Lanzador de aplicaciones
│   └── install_rofi.sh           # Rofi + temas adi1090x
│
├── desktop_apps/                 # Aplicaciones de escritorio
│   ├── install_desktop_apps.sh   # Dolphin, mpv, imv + USB
│   ├── configure_mime.sh         # Asociaciones de archivos
│   ├── install_mongodb_compass.sh # MongoDB Compass (GUI)
│   ├── update_mongodb_compass.sh  # Actualización automática
│   └── setup_compass_command.sh   # Comando global mongodb-compass-update
│
├── bun/                          # Bun (JavaScript runtime)
│   └── install_bun.sh            # Instalación de Bun
│
├── devtools/                     # Herramientas de desarrollo
│   └── install_nvm_jdk_maven.sh  # NVM + JDK 25 + Maven
│
├── docker/                       # Docker
│   └── install_docker.sh         # Docker + Docker Compose
│
├── hypr/                         # Configuraciones de Hyprland
│
├── keyring/                      # Llavero de contraseñas
│   ├── install_keyring.sh        # GNOME Keyring
│   ├── configure_keyring.sh      # PAM y autostart
│   └── verify_keyring.sh         # Verificación del sistema
│
├── kitty/                        # Terminal Kitty
│   └── install_kitty.sh          # Configuración y temas
│
├── nvim/                         # Neovim
│   ├── install.sh                # Neovim + configuraciones personalizadas
│   └── lombok.jar                # Lombok para Java (copiado a /usr/share/java/lombok/)
│
└── ssh/                          # SSH
    └── install_ssh.sh            # Servidor SSH
```

### Cómo Usar

#### Instalación Completa

1. **Clonar el repositorio:**
```bash
git clone <URL_DEL_REPO> instalacion-inicial
cd instalacion-inicial
```

2. **Ejecutar el script principal:**
```bash
chmod +x install.sh
./install.sh
```

El script te guiará paso a paso, preguntando qué componentes deseas instalar.

#### Instalación Modular (Scripts Individuales)

Cada componente puede ejecutarse de forma independiente:

```bash
# Instalar solo drivers de GPU
bash drivers_utilities/gpu_drivers_install.sh

# Instalar solo ZSH
bash zsh/install_zsh.sh
bash zsh/change_shell.sh

# Instalar solo Hyprland
bash hyprland/install_hyprland.sh
bash hyprland/configure_hyprland.sh

# Instalar solo Bun
bash bun/install_bun.sh

# Instalar solo herramientas de desarrollo
bash devtools/install_nvm_jdk_maven.sh

# Instalar solo Docker
bash docker/install_docker.sh
```

### Orden de Instalación (install.sh)

El script principal sigue este orden **optimizado** para evitar problemas:

1. **Sistema base** - Actualización y dependencias
2. **Drivers y utilidades** - NetworkManager, PipeWire, Códecs
3. **Hardware** - Microcódigo CPU, Drivers GPU
4. **Yay (AUR Helper)** - Para paquetes de AUR
5. **Paquetes AUR** - Chrome, OnlyOffice, WARP
6. **Fuentes** - Nerd Fonts e iconos
6.5. **Llavero de contraseñas** - GNOME Keyring (Secret Service API)
7. **Entorno gráfico** - Hyprland, Dolphin, mpv, imv, Rofi, MongoDB Compass
8. **ZSH** - Shell + Oh My Zsh + Powerlevel10k + cambio de shell
9. **Configuración** - Hyprland, asociaciones MIME
10. **Cloudflare WARP** - VPN y configuración
11. **Instaladores opcionales** - Kitty, Bun, DevTools, Neovim, Docker, SSH
12. **Herramientas adicionales** - opencode.ai
13. **Finalización** - Documentación y guías

> ⚠️ **Importante:** ZSH se configura ANTES de instalar Neovim y otras herramientas para garantizar que el shell esté correctamente configurado. Neovim se instala DESPUÉS de DevTools para asegurar que el soporte de Java y Lombok funcione correctamente.

### Notas Importantes

#### 🔄 Reinicio de Sesión
- **Después de cambiar a ZSH:** Reinicia tu sesión o abre una nueva terminal
- **Después de instalar Docker:** Cierra sesión y vuelve a iniciarla para que el grupo `docker` tenga efecto
- **Drivers NVIDIA:** Requieren reinicio completo del sistema

#### 🎨 Powerlevel10k
- La primera vez que abras ZSH, se ejecutará el asistente de configuración de Powerlevel10k
- Puedes reconfigurarlo en cualquier momento con: `p10k configure`

#### 🖥️ Hyprland Autostart
- El script puede configurar Hyprland para iniciarse automáticamente en TTY1
- Si usas un display manager (SDDM/GDM), configúralo ahí en su lugar

#### 🐳 Docker sin sudo
- Para usar Docker sin `sudo`, debes cerrar sesión después de la instalación
- El script agrega tu usuario al grupo `docker` automáticamente

#### 🔧 Neovim
- El script instala Neovim con configuraciones personalizadas
- Asegúrate de que ZSH ya esté configurado antes de instalar Neovim
- **Lombok para Java:** Se instala automáticamente en `/usr/share/java/lombok/lombok.jar` para soporte de desarrollo Java con anotaciones
- Neovim se instala después de DevTools para garantizar compatibilidad con JDK y Maven

#### 🌐 Cloudflare WARP
- Durante la instalación se pregunta si deseas habilitarlo inmediatamente
- Opcionalmente se configura para iniciarse automáticamente con Hyprland
- Comando manual: `warp-cli connect` / `warp-cli disconnect`
- Para ver estado: `warp-cli status`

#### 📚 Guía de Comandos Rápida
- Después de la instalación, escribe `h` en la terminal para ver una guía completa de todos los comandos útiles
- La guía incluye comandos para: WARP, Docker, NVM, Bun, Maven, Hyprland, GNOME Keyring, y más
- Archivo ubicado en: `~/COMANDOS.md`

#### 🔐 Llavero de Contraseñas (GNOME Keyring)
- Sistema estándar de Linux para almacenar contraseñas de forma segura
- Se desbloquea automáticamente con tu contraseña de usuario
- Compatible con navegadores, Git, SSH, Docker y más
- Interfaz gráfica: `seahorse`
- Comando CLI: `secret-tool`
- SSH agent integrado: `gcr-ssh-agent`

#### 🗄️ MongoDB Compass
- Cliente GUI para MongoDB con auto-actualización
- Descarga automática de la última versión desde GitHub
- Comando de actualización: `mongodb-compass-update`
- Instalación en `/opt/mongo/mongoDBCompass`
- Accesible desde Rofi o línea de comandos

#### 📁 Asociaciones de Archivos
- Los archivos se abren automáticamente con la aplicación correcta:
  - **Imágenes** (jpg, png, gif, etc.) → imv
  - **Videos** (mp4, mkv, webm, etc.) → mpv
  - **Audio** (mp3, flac, ogg, etc.) → mpv
  - **PDF** → OnlyOffice (predeterminado) + Chrome (alternativa con clic derecho)
  - **Documentos Office** (docx, xlsx, pptx) → OnlyOffice
  - **Archivos de texto** → Neovim

#### 🔌 Soporte USB
- Los pendrives y dispositivos USB se montan automáticamente
- Icono en bandeja del sistema para gestionar dispositivos
- Soporte para cámaras, teléfonos Android/iOS, y dispositivos MTP

### Personalización

Todos los scripts son modulares y pueden ser personalizados:

- **Configuraciones de Hyprland:** `hypr/hyprland.conf`
- **Configuraciones de Kitty:** `kitty/kitty.conf`
- **Configuraciones de Neovim:** `nvim/`
- **Plugins de ZSH:** Modifica `zsh/install_zsh.sh`

### Requisitos Previos

- Sistema Arch Linux (o derivado con `pacman`) instalado
- Conexión a internet activa
- Usuario con permisos `sudo`

### Soporte

Este es un proyecto personal de automatización. Los scripts están diseñados para:
- Arch Linux y derivados (Manjaro, EndeavourOS, etc.)
- Instalaciones limpias desde cero
- Entornos de desarrollo

---

## English

### What is this project?

This repository contains a set of **modular and organized scripts** to automate the installation and initial configuration of a **complete development environment** on Arch Linux (and derivatives) after a fresh install.

**Focus:** Development-ready system with customized Neovim, Hyprland as Wayland compositor, ZSH as default shell, and all necessary tools for multi-language programming.

### Key Features

✅ **Fully modular and organized installation**
✅ **Base system with automatic drivers (NVIDIA/AMD/Intel)**
✅ **Hyprland as Wayland compositor**
✅ **ZSH + Oh My Zsh + Powerlevel10k auto-configured**
✅ **Neovim with custom configurations**
✅ **Development tools (NVM, JDK 25, Maven, Docker)**
✅ **Cloudflare WARP integrated**
✅ **Nerd Fonts for terminal**

### Installed Tools and Components

#### 🎨 Graphical Environment and Applications
- **Hyprland** - Modern and efficient Wayland compositor
- **Kitty** - GPU-accelerated terminal emulator
- **Rofi** - Application launcher (with adi1090x themes)
- **Dolphin** - File manager with full USB support
- **mpv** - Video and audio player (Wayland optimized)
- **imv** - Native Wayland image viewer
- **MongoDB Compass** - MongoDB GUI client (optional)
- **Fonts**: JetBrains Mono Nerd, Font Awesome, Noto Emoji

#### 🔌 Device Support
- **udisks2** - Automatic disk mounting system
- **udiskie** - USB automount with tray icon
- **gvfs** - Virtual filesystem (MTP, PTP, AFC)

#### 🖥️ System and Drivers
- **NetworkManager** - Network management
- **PipeWire** - Modern audio system (replaces PulseAudio)
- **Multimedia codecs** - FFmpeg, GStreamer (all plugins)
- **CPU microcode** - AMD/Intel (automatic detection)
- **GPU drivers** - NVIDIA/AMD/Intel (automatic detection)

#### 🐚 Shell and CLI Tools
- **ZSH** - Default shell
- **Oh My Zsh** - Configuration framework
- **Powerlevel10k** - Advanced theme with icons
- **zsh-autosuggestions** - Automatic suggestions
- **zsh-syntax-highlighting** - Syntax highlighting
- **fzf** - Fuzzy finder
- **eza** - Modern `ls` replacement with icons
- **htop** - Interactive process viewer
- **btop** - Modern and visual resource monitor

#### 💻 Development
- **Neovim** - Advanced text editor with custom configurations
- **Lombok** - Java library to reduce boilerplate code (included with Neovim)
- **Bun** - Ultra-fast JavaScript runtime and all-in-one toolkit
- **NVM** - Node Version Manager
- **JDK 25** - Java Development Kit
- **Maven** - Java dependency manager
- **Docker + Docker Compose** - Containers
- **MongoDB Compass** - MongoDB GUI client with auto-update

#### 🌐 Network and Security
- **Cloudflare WARP** - VPN and secure DNS
- **SSH** - SSH server configuration
- **GNOME Keyring** - Password keyring system (Secret Service API)

#### 📦 AUR Applications
- **Google Chrome** - Web browser
- **OnlyOffice** - Office suite
- **opencode.ai** - AI interactive CLI

### How to Use

#### Complete Installation

1. **Clone the repository:**
```bash
git clone <REPO_URL> instalacion-inicial
cd instalacion-inicial
```

2. **Run the main script:**
```bash
chmod +x install.sh
./install.sh
```

The script will guide you step by step, asking which components you want to install.

#### Modular Installation (Individual Scripts)

Each component can be run independently:

```bash
# Install only GPU drivers
bash drivers_utilities/gpu_drivers_install.sh

# Install only ZSH
bash zsh/install_zsh.sh
bash zsh/change_shell.sh

# Install only development tools
bash devtools/install_nvm_jdk_maven.sh
```

### Installation Order (install.sh)

The main script follows this **optimized** order to avoid issues:

1. **Base system** - Update and dependencies
2. **Drivers and utilities** - NetworkManager, PipeWire, Codecs
3. **Hardware** - CPU microcode, GPU drivers
4. **Yay (AUR Helper)** - For AUR packages
5. **AUR packages** - Chrome, OnlyOffice, WARP
6. **Fonts** - Nerd Fonts and icons
6.5. **Password keyring** - GNOME Keyring (Secret Service API)
7. **Graphical environment** - Hyprland, Dolphin, mpv, imv, Rofi, MongoDB Compass
8. **ZSH** - Shell + Oh My Zsh + Powerlevel10k + shell change
9. **Configuration** - Hyprland, MIME associations
10. **Cloudflare WARP** - VPN and configuration
11. **Optional installers** - Kitty, Bun, DevTools, Neovim, Docker, SSH
12. **Additional tools** - opencode.ai
13. **Finalization** - Documentation and guides

> ⚠️ **Important:** ZSH is configured BEFORE installing Neovim and other tools to ensure the shell is properly set up. Neovim is installed AFTER DevTools to ensure Java and Lombok support works correctly.

### Important Notes

#### 🔄 Session Restart
- **After switching to ZSH:** Restart your session or open a new terminal
- **After installing Docker:** Log out and log back in for the `docker` group to take effect
- **NVIDIA drivers:** Require full system reboot

#### 🎨 Powerlevel10k
- The first time you open ZSH, the Powerlevel10k configuration wizard will run
- You can reconfigure it anytime with: `p10k configure`

#### 🖥️ Hyprland Autostart
- The script can configure Hyprland to start automatically on TTY1
- If you use a display manager (SDDM/GDM), configure it there instead

#### 🐳 Docker without sudo
- To use Docker without `sudo`, you must log out after installation
- The script adds your user to the `docker` group automatically

#### 🔧 Neovim
- The script installs Neovim with custom configurations
- Make sure ZSH is already configured before installing Neovim
- **Lombok for Java:** Automatically installed at `/usr/share/java/lombok/lombok.jar` for Java development with annotations support
- Neovim is installed after DevTools to ensure compatibility with JDK and Maven

### Requirements

- Arch Linux (or derivative with `pacman`) installed
- Active internet connection
- User with `sudo` permissions

### Support

This is a personal automation project. Scripts are designed for:
- Arch Linux and derivatives (Manjaro, EndeavourOS, etc.)
- Clean installs from scratch
- Development environments
