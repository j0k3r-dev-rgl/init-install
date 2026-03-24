#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${HOME}/.init-install.conf"
LOG_FILE=""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

declare -a CATEGORY_ORDER=(
    system_base
    homebrew
    yay_install
    drivers_utilities
    hyprland
    waybar
    swaync
    wlogout
    rofi
    kitty
    nvim
    yazi
    docker
    system_essentials
    zsh
    keyring
    mongodb_compass
    opencode
    post_install
)

declare -A CATEGORY_TITLE
declare -A CATEGORY_SUMMARY
declare -A CATEGORY_SCRIPTS
declare -A CATEGORY_PACKAGES
declare -A CATEGORY_SELECTED

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

cleanup() {
    if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
        rm -f "$LOG_FILE"
    fi
}

trap cleanup EXIT
trap 'die "El script falló en la línea $LINENO"' ERR

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Falta el comando requerido: $1"
}

copy_if_missing() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
        print_info "Ya existe $(basename "$dst"), no se sobreescribe"
        return 0
    fi

    cp "$src" "$dst"
    print_success "Copiado: $dst"
}

init_categories() {
    CATEGORY_TITLE[system_base]="Sistema base"
    CATEGORY_SUMMARY[system_base]="Actualiza el sistema e instala paquetes base esenciales"
    CATEGORY_SCRIPTS[system_base]="$SCRIPT_DIR/system_base/install_base.sh"
    CATEGORY_PACKAGES[system_base]=$'Actualización:\n- pacman -Syu\n\nPaquetes:\n- base\n- base-devel\n- linux\n- linux-firmware\n- grub\n- efibootmgr\n- sudo\n- git\n- curl\n- wget\n- jq\n- nano\n- unzip\n- 7zip\n- tree'

    CATEGORY_TITLE[homebrew]="Homebrew"
    CATEGORY_SUMMARY[homebrew]="Instala Homebrew global y de usuario"
    CATEGORY_SCRIPTS[homebrew]="$SCRIPT_DIR/homebrew/install_homebrew.sh"
    CATEGORY_PACKAGES[homebrew]=$'Paquetes base para Homebrew:\n- base-devel\n- procps-ng\n- curl\n- file\n- git\n\nAcciones:\n- instala Homebrew global en /home/linuxbrew/.linuxbrew\n- instala Homebrew de usuario en ~/.linuxbrew\n- agrega shellenv a ~/.zshrc y ~/.bashrc'

    CATEGORY_TITLE[yay_install]="Yay y AUR"
    CATEGORY_SUMMARY[yay_install]="Instala yay y paquetes AUR necesarios"
    CATEGORY_SCRIPTS[yay_install]="$SCRIPT_DIR/yay_install/install_yay_packages.sh"
    CATEGORY_PACKAGES[yay_install]=$'Paquetes/acciones:\n- yay (si no existe)\n- google-chrome\n- wlogout'

    CATEGORY_TITLE[drivers_utilities]="Drivers y utilidades"
    CATEGORY_SUMMARY[drivers_utilities]="Red, audio, códecs, microcódigo, GPU y TRIM"
    CATEGORY_SCRIPTS[drivers_utilities]="$SCRIPT_DIR/drivers_utilities/network_install.sh|$SCRIPT_DIR/drivers_utilities/audio_install.sh|$SCRIPT_DIR/drivers_utilities/codecs_install.sh|$SCRIPT_DIR/drivers_utilities/cpu_microcode_install.sh|$SCRIPT_DIR/drivers_utilities/gpu_drivers_install.sh|$SCRIPT_DIR/drivers_utilities/configure_trim.sh"
    CATEGORY_PACKAGES[drivers_utilities]=$'Red:\n- networkmanager\n- network-manager-applet\n\nAudio:\n- pipewire\n- pipewire-alsa\n- pipewire-pulse\n- pipewire-jack\n- wireplumber\n- pavucontrol\n\nCódecs:\n- ffmpeg\n- gst-plugins-base\n- gst-plugins-good\n- gst-plugins-bad\n- gst-plugins-ugly\n- gst-libav\n\nMicrocódigo (según CPU):\n- amd-ucode\n- intel-ucode\n\nGPU (según hardware):\n- NVIDIA: nvidia, nvidia-utils, nvidia-settings\n- AMD: mesa, vulkan-radeon, libva-mesa-driver\n- Intel: mesa, vulkan-intel, intel-media-driver, libva-mesa-driver\n\nAcciones:\n- habilita NetworkManager\n- configura fstrim.timer diario'

    CATEGORY_TITLE[hyprland]="Hyprland"
    CATEGORY_SUMMARY[hyprland]="Instala Hyprland y su configuración"
    CATEGORY_SCRIPTS[hyprland]="$SCRIPT_DIR/hyprland/install_hyprland.sh"
    CATEGORY_PACKAGES[hyprland]=$'Paquetes:\n- hyprland\n\nAcciones:\n- ejecuta configure_hyprland.sh\n- copia configuración de Hyprland sin sobreescribir archivos existentes'

    CATEGORY_TITLE[waybar]="Waybar"
    CATEGORY_SUMMARY[waybar]="Instala Waybar y copia su configuración"
    CATEGORY_SCRIPTS[waybar]="$SCRIPT_DIR/waybar/install_waybar.sh"
    CATEGORY_PACKAGES[waybar]=$'Paquetes:\n- waybar\n- python-gobject\n\nAcciones:\n- copia configs a ~/.config/waybar'

    CATEGORY_TITLE[swaync]="swaync"
    CATEGORY_SUMMARY[swaync]="Instala centro de notificaciones swaync"
    CATEGORY_SCRIPTS[swaync]="$SCRIPT_DIR/swaync/install_swaync.sh"
    CATEGORY_PACKAGES[swaync]=$'Paquetes:\n- swaync\n- python-gobject\n\nAcciones:\n- copia configs a ~/.config/swaync'

    CATEGORY_TITLE[wlogout]="wlogout"
    CATEGORY_SUMMARY[wlogout]="Instala wlogout desde AUR y copia configuración"
    CATEGORY_SCRIPTS[wlogout]="$SCRIPT_DIR/wlogout/install_wlogout.sh"
    CATEGORY_PACKAGES[wlogout]=$'Paquetes:\n- wlogout (AUR)\n\nAcciones:\n- requiere yay\n- copia configs a ~/.config/wlogout'

    CATEGORY_TITLE[rofi]="Rofi"
    CATEGORY_SUMMARY[rofi]="Instala Rofi y sus launchers"
    CATEGORY_SCRIPTS[rofi]="$SCRIPT_DIR/rofi/install_rofi.sh"
    CATEGORY_PACKAGES[rofi]=$'Paquetes:\n- rofi\n\nAcciones:\n- copia configs a ~/.config/rofi\n- marca scripts .sh y .py como ejecutables'

    CATEGORY_TITLE[kitty]="Kitty"
    CATEGORY_SUMMARY[kitty]="Instala Kitty y copia configuración"
    CATEGORY_SCRIPTS[kitty]="$SCRIPT_DIR/kitty/install_kitty.sh"
    CATEGORY_PACKAGES[kitty]=$'Paquetes:\n- kitty\n\nAcciones:\n- copia configs a ~/.config/kitty'

    CATEGORY_TITLE[nvim]="Neovim"
    CATEGORY_SUMMARY[nvim]="Instala Neovim nightly y su configuración local"
    CATEGORY_SCRIPTS[nvim]="$SCRIPT_DIR/nvim/install.sh"
    CATEGORY_PACKAGES[nvim]=$'Paquetes:\n- git\n- gcc\n- make\n- unzip\n- ripgrep\n- fd\n- nodejs\n- npm\n- python\n- python-pip\n- python-pynvim\n- tree-sitter\n- tree-sitter-cli\n- wl-clipboard\n\nAcciones:\n- npm install -g neovim\n- descarga Neovim nightly a /opt/nvim-linux-x86_64\n- agrega /opt/nvim-linux-x86_64/bin al PATH\n- copia configs a ~/.config/nvim'

    CATEGORY_TITLE[yazi]="Yazi"
    CATEGORY_SUMMARY[yazi]="Instala Yazi y copia configuración"
    CATEGORY_SCRIPTS[yazi]="$SCRIPT_DIR/yazi/install_yazi.sh"
    CATEGORY_PACKAGES[yazi]=$'Paquetes:\n- ffmpeg\n- 7zip\n- fd\n- ripgrep\n- fzf\n- zoxide\n- poppler\n- unzip\n\nAcciones:\n- descarga Yazi y ya\n- instala binarios en /usr/local/bin\n- copia configs a ~/.config/yazi'

    CATEGORY_TITLE[docker]="Docker"
    CATEGORY_SUMMARY[docker]="Instala Docker, docker-compose y habilita el servicio"
    CATEGORY_SCRIPTS[docker]="$SCRIPT_DIR/docker/install_docker.sh"
    CATEGORY_PACKAGES[docker]=$'Paquetes:\n- docker\n- docker-compose\n\nAcciones:\n- habilita docker.service\n- agrega el usuario al grupo docker'

    CATEGORY_TITLE[system_essentials]="System essentials"
    CATEGORY_SUMMARY[system_essentials]="Instala utilidades diarias del sistema"
    CATEGORY_SCRIPTS[system_essentials]="$SCRIPT_DIR/system_essentials/install_essentials.sh"
    CATEGORY_PACKAGES[system_essentials]=$'Paquetes:\n- btop\n- eza\n- fd\n- ripgrep\n- fzf\n- udiskie\n- brightnessctl\n- playerctl\n- python-gobject\n- zoxide\n\nExtra:\n- asegura wlogout con yay si está disponible'

    CATEGORY_TITLE[zsh]="ZSH"
    CATEGORY_SUMMARY[zsh]="Instala ZSH, Oh My Zsh y plugins"
    CATEGORY_SCRIPTS[zsh]="$SCRIPT_DIR/zsh/install_zsh.sh"
    CATEGORY_PACKAGES[zsh]=$'Paquetes:\n- zsh\n- fzf\n- eza\n\nAcciones:\n- instala Oh My Zsh\n- clona zsh-autosuggestions\n- clona zsh-syntax-highlighting\n- clona powerlevel10k\n- copia .zshrc si no existe\n- cambia el shell por defecto a zsh si aplica'

    CATEGORY_TITLE[keyring]="GNOME Keyring"
    CATEGORY_SUMMARY[keyring]="Instala y configura GNOME Keyring para login, Hyprland y SSH"
    CATEGORY_SCRIPTS[keyring]="$SCRIPT_DIR/keyring/install_keyring.sh|$SCRIPT_DIR/keyring/configure_keyring.sh"
    CATEGORY_PACKAGES[keyring]=$'Paquetes:\n- gnome-keyring\n- libsecret\n- seahorse\n- gcr-4\n\nAcciones:\n- configura PAM para login\n- configura autostart para Hyprland\n- habilita gcr-ssh-agent.socket\n- exporta SSH_AUTH_SOCK'

    CATEGORY_TITLE[mongodb_compass]="MongoDB Compass"
    CATEGORY_SUMMARY[mongodb_compass]="Instala MongoDB Compass desde el binario oficial"
    CATEGORY_SCRIPTS[mongodb_compass]="$SCRIPT_DIR/mongodb_compass/install_compass.sh"
    CATEGORY_PACKAGES[mongodb_compass]=$'Dependencias requeridas:\n- jq\n- wget\n\nAcciones:\n- descarga el release oficial más reciente\n- instala en /opt/mongo/mongoDBCompass\n- crea mongodb-compass.desktop en ~/.local/share/applications'

    CATEGORY_TITLE[opencode]="Opencode"
    CATEGORY_SUMMARY[opencode]="Instala Opencode y copia su configuración"
    CATEGORY_SCRIPTS[opencode]="$SCRIPT_DIR/opencode/install_opencode.sh"
    CATEGORY_PACKAGES[opencode]=$'Acciones:\n- instala opencode si no existe\n- copia opencode.json a ~/.config/opencode\n- agrega ~/.opencode/bin al PATH en ~/.zshrc'

    CATEGORY_TITLE[post_install]="Post instalación"
    CATEGORY_SUMMARY[post_install]="Copia MIME, instala el comando update y deja la guía final"
    CATEGORY_SCRIPTS[post_install]="__internal_post_install__"
    CATEGORY_PACKAGES[post_install]=$'Acciones:\n- copia mimeapps/mimeapps.list a ~/.config/mimeapps.list si no existe\n- instala el comando update desde system_update/install_update_command.sh\n- copia COMANDOS.md a ~/COMANDOS.md si existe'
}

default_selections() {
    local category
    for category in "${CATEGORY_ORDER[@]}"; do
        CATEGORY_SELECTED["$category"]=ON
    done
}

save_selections() {
    {
        printf '# init-install selections\n'
        local category
        for category in "${CATEGORY_ORDER[@]}"; do
            printf '%s=%s\n' "$category" "${CATEGORY_SELECTED[$category]}"
        done
    } > "$CONFIG_FILE"
}

load_selections() {
    default_selections

    if [ ! -f "$CONFIG_FILE" ]; then
        save_selections
        return 0
    fi

    local line key value
    while IFS='=' read -r key value; do
        [ -n "$key" ] || continue
        [[ "$key" =~ ^# ]] && continue

        if [ -n "${CATEGORY_SELECTED[$key]+x}" ]; then
            case "$value" in
                ON|OFF)
                    CATEGORY_SELECTED[$key]="$value"
                    ;;
            esac
        fi
    done < "$CONFIG_FILE"
}

set_all_selections() {
    local value="$1"
    local category
    for category in "${CATEGORY_ORDER[@]}"; do
        CATEGORY_SELECTED["$category"]="$value"
    done
    save_selections
}

sync_selections_from_output() {
    local output="$1"
    local category

    for category in "${CATEGORY_ORDER[@]}"; do
        CATEGORY_SELECTED["$category"]=OFF
    done

    local tag
    for tag in $output; do
        tag="${tag%\"}"
        tag="${tag#\"}"
        if [ -n "${CATEGORY_SELECTED[$tag]+x}" ]; then
            CATEGORY_SELECTED[$tag]=ON
        fi
    done

    save_selections
}

ensure_whiptail() {
    if command -v whiptail >/dev/null 2>&1; then
        return 0
    fi

    print_info "whiptail no está instalado. Instalando libnewt..."
    sudo pacman -S --needed --noconfirm libnewt
    require_cmd whiptail
}

show_welcome() {
    whiptail \
        --title "init-install" \
        --msgbox "Selector interactivo para instalar el setup modular de Arch Linux.\n\nConfiguración guardada en:\n$CONFIG_FILE" \
        12 70
}

build_checklist_args() {
    local args=()
    local category
    for category in "${CATEGORY_ORDER[@]}"; do
        args+=("$category" "${CATEGORY_TITLE[$category]} — ${CATEGORY_SUMMARY[$category]}" "${CATEGORY_SELECTED[$category]}")
    done
    printf '%s\n' "${args[@]}"
}

selected_categories() {
    local selected=()
    local category
    for category in "${CATEGORY_ORDER[@]}"; do
        if [ "${CATEGORY_SELECTED[$category]}" = "ON" ]; then
            selected+=("$category")
        fi
    done

    printf '%s\n' "${selected[@]}"
}

show_packages_menu() {
    local args=()
    local category
    for category in "${CATEGORY_ORDER[@]}"; do
        args+=("$category" "${CATEGORY_TITLE[$category]}")
    done

    while true; do
        local selected_category
        selected_category=$(whiptail \
            --title "Paquetes por categoría" \
            --menu "Elegí una categoría para ver qué instala." \
            24 90 16 \
            "${args[@]}" \
            3>&1 1>&2 2>&3) || return 0

        whiptail \
            --title "${CATEGORY_TITLE[$selected_category]}" \
            --msgbox "${CATEGORY_PACKAGES[$selected_category]}" \
            28 90
    done
}

run_post_install() {
    print_info "[POST] Configurando MIME y comando update..."
    copy_if_missing "$SCRIPT_DIR/mimeapps/mimeapps.list" "$HOME/.config/mimeapps.list"

    local update_cmd_installer="$SCRIPT_DIR/system_update/install_update_command.sh"
    if [ -f "$update_cmd_installer" ]; then
        chmod +x "$update_cmd_installer" 2>/dev/null || true
        bash "$update_cmd_installer"
    fi

    if [ -f "$SCRIPT_DIR/COMANDOS.md" ]; then
        cp "$SCRIPT_DIR/COMANDOS.md" "$HOME/COMANDOS.md"
        print_success "Guía disponible en ~/COMANDOS.md"
    fi
}

run_category() {
    local category="$1"
    local script_group="${CATEGORY_SCRIPTS[$category]}"

    if [ "$script_group" = "__internal_post_install__" ]; then
        run_post_install
        return 0
    fi

    local script_path
    IFS='|' read -r -a script_paths <<< "$script_group"
    for script_path in "${script_paths[@]}"; do
        [ -f "$script_path" ] || die "No se encontró el script: $script_path"
        chmod +x "$script_path" 2>/dev/null || true
        bash "$script_path"
    done
}

run_installation() {
    local categories=("$@")
    local total="${#categories[@]}"

    if [ "$total" -eq 0 ]; then
        whiptail --title "Nada seleccionado" --msgbox "No hay categorías seleccionadas para instalar." 10 60
        return 0
    fi

    LOG_FILE="$(mktemp)"

    if ! {
        local index=0
        local category percent

        for category in "${categories[@]}"; do
            index=$((index + 1))
            percent=$((((index - 1) * 100) / total))
            printf 'XXX\n%d\n[%d/%d] %s\nXXX\n' "$percent" "$index" "$total" "${CATEGORY_TITLE[$category]}"

            if ! run_category "$category" >> "$LOG_FILE" 2>&1; then
                printf 'XXX\n%d\nFalló: %s\nXXX\n' "$percent" "${CATEGORY_TITLE[$category]}"
                return 1
            fi

            percent=$((index * 100 / total))
            printf 'XXX\n%d\nCompletado: %s\nXXX\n' "$percent" "${CATEGORY_TITLE[$category]}"
        done
    } | whiptail --title "Instalando" --gauge "Iniciando instalación..." 10 78 0; then
        local error_log
        error_log="$(sed 's/\x1b\[[0-9;]*m//g' "$LOG_FILE")"
        whiptail \
            --title "Instalación fallida" \
            --msgbox "La instalación se detuvo. Revisá el log:\n\n${error_log:0:3500}" \
            28 100
        return 1
    fi

    whiptail \
        --title "Instalación completada" \
        --msgbox "La instalación finalizó correctamente.\n\nLog guardado temporalmente en:\n$LOG_FILE" \
        12 70
}

show_options_menu() {
    while true; do
        local option
        option=$(whiptail \
            --title "Opciones" \
            --menu "Elegí una acción adicional." \
            18 70 8 \
            install_all "Instalar todas las categorías" \
            select_all "Marcar todas las categorías" \
            deselect_all "Desmarcar todas las categorías" \
            view_packages "Ver paquetes por categoría" \
            back "Volver al checklist" \
            exit "Salir" \
            3>&1 1>&2 2>&3) || return 0

        case "$option" in
            install_all)
                run_installation "${CATEGORY_ORDER[@]}"
                ;;
            select_all)
                set_all_selections ON
                ;;
            deselect_all)
                set_all_selections OFF
                ;;
            view_packages)
                show_packages_menu
                ;;
            back)
                return 0
                ;;
            exit)
                exit 0
                ;;
        esac
    done
}

main_menu_loop() {
    while true; do
        mapfile -t checklist_args < <(build_checklist_args)

        local selection_output status
        local selected=()

        if selection_output=$(whiptail \
            --title "init-install" \
            --checklist "Seleccioná las categorías a instalar.\n\nEspacio: marcar/desmarcar\nTab: cambiar botón" \
            26 110 18 \
            --ok-button "Instalar" \
            --cancel-button "Salir" \
            --extra-button \
            --extra-label "Opciones" \
            "${checklist_args[@]}" \
            3>&1 1>&2 2>&3); then
            status=0
        else
            status=$?
        fi

        case "$status" in
            0)
                sync_selections_from_output "$selection_output"
                mapfile -t selected < <(selected_categories)
                run_installation "${selected[@]}"
                ;;
            1)
                break
                ;;
            3)
                sync_selections_from_output "$selection_output"
                show_options_menu
                ;;
        esac
    done
}

require_cmd bash
require_cmd sudo
require_cmd pacman

if ! command -v pacman >/dev/null 2>&1; then
    die "Este script está pensado para Arch/derivados (pacman no encontrado)."
fi

sudo -v
ensure_whiptail
init_categories
load_selections
show_welcome
main_menu_loop
