#!/usr/bin/env python3
import curses
import os
import shutil
import subprocess
import sys
import textwrap
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_FILE = Path.home() / ".init-install.conf"
MUTUAL_EXCLUSIONS: dict[str, list[str]] = {
    "keyring": ["keepassxc"],
    "keepassxc": ["keyring"],
}


@dataclass(frozen=True)
class Category:
    key: str
    title: str
    summary: str
    packages: str
    scripts: tuple[str, ...] = ()
    internal_runner: Callable[[], None] | None = None


def copy_if_missing(src: Path, dst: Path) -> str:
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        return f"Ya existe {dst.name}, no se sobreescribe"
    shutil.copy2(src, dst)
    return f"Copiado: {dst}"


def run_post_install_actions() -> list[str]:
    messages: list[str] = ["[POST] Configurando MIME y comando update..."]

    mimeapps_src = SCRIPT_DIR / "mimeapps" / "mimeapps.list"
    if mimeapps_src.exists():
        messages.append(copy_if_missing(mimeapps_src, Path.home() / ".config" / "mimeapps.list"))

    update_installer = SCRIPT_DIR / "system_update" / "install_update_command.sh"
    if update_installer.exists():
        update_installer.chmod(update_installer.stat().st_mode | 0o111)
        result = subprocess.run(
            ["bash", str(update_installer)],
            cwd=SCRIPT_DIR,
            text=True,
            capture_output=True,
        )
        output = (result.stdout or "") + (result.stderr or "")
        if output.strip():
            messages.extend(output.strip().splitlines())
        if result.returncode != 0:
            raise subprocess.CalledProcessError(result.returncode, result.args, output=output)

    comandos_src = SCRIPT_DIR / "COMANDOS.md"
    if comandos_src.exists():
        destination = Path.home() / "COMANDOS.md"
        if destination.exists():
            messages.append("Ya existe COMANDOS.md, no se sobreescribe")
        else:
            shutil.copy2(comandos_src, destination)
            messages.append("Guía disponible en ~/COMANDOS.md")

    return messages


CATEGORIES: tuple[Category, ...] = (
    Category(
        "system_base",
        "Sistema base",
        "Actualiza el sistema e instala paquetes base esenciales",
        """Actualización:
- pacman -Syu

Paquetes:
- base
- base-devel
- linux
- linux-firmware
- grub
- efibootmgr
- sudo
- git
- curl
- wget
- jq
- nano
- unzip
- 7zip
- tree""",
        (str(SCRIPT_DIR / "system_base" / "install_base.sh"),),
    ),
    Category(
        "homebrew",
        "Homebrew",
        "Instala Homebrew global y de usuario",
        """Paquetes base para Homebrew:
- base-devel
- procps-ng
- curl
- file
- git

Acciones:
- instala Homebrew global en /home/linuxbrew/.linuxbrew
- instala Homebrew de usuario en ~/.linuxbrew
- agrega shellenv a ~/.zshrc y ~/.bashrc""",
        (str(SCRIPT_DIR / "homebrew" / "install_homebrew.sh"),),
    ),
    Category(
        "yay_install",
        "Yay y AUR",
        "Instala yay y paquetes AUR necesarios",
        """Paquetes/acciones:
- yay (si no existe)
- google-chrome
- wlogout""",
        (str(SCRIPT_DIR / "yay_install" / "install_yay_packages.sh"),),
    ),
    Category(
        "drivers_utilities",
        "Drivers y utilidades",
        "Red, audio, códecs, microcódigo, GPU y TRIM",
        """Red:
- networkmanager
- network-manager-applet

Audio:
- pipewire
- pipewire-alsa
- pipewire-pulse
- pipewire-jack
- wireplumber
- pavucontrol

Códecs:
- ffmpeg
- gst-plugins-base
- gst-plugins-good
- gst-plugins-bad
- gst-plugins-ugly
- gst-libav

Microcódigo (según CPU):
- amd-ucode
- intel-ucode

GPU (según hardware):
- NVIDIA: nvidia, nvidia-utils, nvidia-settings
- AMD: mesa, vulkan-radeon, libva-mesa-driver
- Intel: mesa, vulkan-intel, intel-media-driver, libva-mesa-driver

Acciones:
- habilita NetworkManager
- configura fstrim.timer diario""",
        (
            str(SCRIPT_DIR / "drivers_utilities" / "network_install.sh"),
            str(SCRIPT_DIR / "drivers_utilities" / "audio_install.sh"),
            str(SCRIPT_DIR / "drivers_utilities" / "codecs_install.sh"),
            str(SCRIPT_DIR / "drivers_utilities" / "cpu_microcode_install.sh"),
            str(SCRIPT_DIR / "drivers_utilities" / "gpu_drivers_install.sh"),
            str(SCRIPT_DIR / "drivers_utilities" / "configure_trim.sh"),
        ),
    ),
    Category(
        "hyprland",
        "Hyprland",
        "Instala Hyprland y su configuración",
        """Paquetes:
- hyprland

Acciones:
- ejecuta configure_hyprland.sh
- copia configuración de Hyprland sin sobreescribir archivos existentes""",
        (str(SCRIPT_DIR / "hyprland" / "install_hyprland.sh"),),
    ),
    Category(
        "waybar",
        "Waybar",
        "Instala Waybar y copia su configuración",
        """Paquetes:
- waybar
- python-gobject

Acciones:
- copia configs a ~/.config/waybar""",
        (str(SCRIPT_DIR / "waybar" / "install_waybar.sh"),),
    ),
    Category(
        "swaync",
        "swaync",
        "Instala centro de notificaciones swaync",
        """Paquetes:
- swaync
- python-gobject

Acciones:
- copia configs a ~/.config/swaync""",
        (str(SCRIPT_DIR / "swaync" / "install_swaync.sh"),),
    ),
    Category(
        "wlogout",
        "wlogout",
        "Instala wlogout desde AUR y copia configuración",
        """Paquetes:
- wlogout (AUR)

Acciones:
- requiere yay
- copia configs a ~/.config/wlogout""",
        (str(SCRIPT_DIR / "wlogout" / "install_wlogout.sh"),),
    ),
    Category(
        "rofi",
        "Rofi",
        "Instala Rofi y sus launchers",
        """Paquetes:
- rofi

Acciones:
- copia configs a ~/.config/rofi
- marca scripts .sh y .py como ejecutables""",
        (str(SCRIPT_DIR / "rofi" / "install_rofi.sh"),),
    ),
    Category(
        "kitty",
        "Kitty",
        "Instala Kitty y copia configuración",
        """Paquetes:
- kitty

Acciones:
- copia configs a ~/.config/kitty""",
        (str(SCRIPT_DIR / "kitty" / "install_kitty.sh"),),
    ),
    Category(
        "nvim",
        "Neovim",
        "Instala Neovim nightly y su configuración local",
        """Paquetes:
- git
- gcc
- make
- unzip
- ripgrep
- fd
- nodejs
- npm
- python
- python-pip
- python-pynvim
- tree-sitter
- tree-sitter-cli
- wl-clipboard

Acciones:
- npm install -g neovim
- descarga Neovim nightly a /opt/nvim-linux-x86_64
- agrega /opt/nvim-linux-x86_64/bin al PATH
- copia configs a ~/.config/nvim""",
        (str(SCRIPT_DIR / "nvim" / "install.sh"),),
    ),
    Category(
        "yazi",
        "Yazi",
        "Instala Yazi y copia configuración",
        """Paquetes:
- ffmpeg
- 7zip
- fd
- ripgrep
- fzf
- zoxide
- poppler
- unzip

Acciones:
- descarga Yazi y ya
- instala binarios en /usr/local/bin
- copia configs a ~/.config/yazi""",
        (str(SCRIPT_DIR / "yazi" / "install_yazi.sh"),),
    ),
    Category(
        "docker",
        "Docker",
        "Instala Docker, docker-compose y habilita el servicio",
        """Paquetes:
- docker
- docker-compose

Acciones:
- habilita docker.service
- agrega el usuario al grupo docker""",
        (str(SCRIPT_DIR / "docker" / "install_docker.sh"),),
    ),
    Category(
        "system_essentials",
        "System essentials",
        "Instala utilidades diarias del sistema",
        """Paquetes:
- btop
- eza
- fd
- ripgrep
- fzf
- udiskie
- brightnessctl
- playerctl
- python-gobject
- zoxide

Extra:
- asegura wlogout con yay si está disponible""",
        (str(SCRIPT_DIR / "system_essentials" / "install_essentials.sh"),),
    ),
    Category(
        "zsh",
        "ZSH",
        "Instala ZSH, Oh My Zsh y plugins",
        """Paquetes:
- zsh
- fzf
- eza

Acciones:
- instala Oh My Zsh
- clona zsh-autosuggestions
- clona zsh-syntax-highlighting
- clona powerlevel10k
- copia .zshrc si no existe
- cambia el shell por defecto a zsh si aplica""",
        (str(SCRIPT_DIR / "zsh" / "install_zsh.sh"),),
    ),
    Category(
        "keyring",
        "GNOME Keyring",
        "Instala y configura GNOME Keyring para login, Hyprland y SSH",
        """Paquetes:
- gnome-keyring
- libsecret
- seahorse
- gcr-4

Acciones:
- configura PAM para login
- configura autostart para Hyprland
- habilita gcr-ssh-agent.socket
- exporta SSH_AUTH_SOCK""",
        (
            str(SCRIPT_DIR / "keyring" / "install_keyring.sh"),
            str(SCRIPT_DIR / "keyring" / "configure_keyring.sh"),
        ),
    ),
    Category(
        "keepassxc",
        "KeePassXC",
        "Gestor de contraseñas y SSH Agent (alternativa a GNOME Keyring)",
        """KeePassXC + libsecret:
- Gestor de contraseñas moderno
- SSH Agent integrado
- Wayland compatible
- Funciona con MongoDB Compass

Paquetes:
- keepassxc
- libsecret

mutual_exclusion: gnome_keyring""",
        (str(SCRIPT_DIR / "keepassxc" / "install_keepassxc.sh"),),
    ),
    Category(
        "mongodb_compass",
        "MongoDB Compass",
        "Instala MongoDB Compass desde el binario oficial",
        """Dependencias requeridas:
- jq
- wget

Acciones:
- descarga el release oficial más reciente
- instala en /opt/mongo/mongoDBCompass
- crea mongodb-compass.desktop en ~/.local/share/applications""",
        (str(SCRIPT_DIR / "mongodb_compass" / "install_compass.sh"),),
    ),
    Category(
        "opencode",
        "Opencode",
        "Instala Opencode y copia su configuración",
        """Acciones:
- instala opencode si no existe
- copia opencode.json a ~/.config/opencode
- agrega ~/.opencode/bin al PATH en ~/.zshrc""",
        (str(SCRIPT_DIR / "opencode" / "install_opencode.sh"),),
    ),
    Category(
        "claude_code",
        "Claude Code",
        "Instala Claude Code CLI",
        """Acciones:
- instala Claude Code con el instalador oficial
- evita reinstalar si el comando claude ya existe
- asegura ~/.local/bin en el PATH cuando hace falta""",
        (str(SCRIPT_DIR / "claude_code" / "install_claude_code.sh"),),
    ),
    Category(
        "codex",
        "Codex",
        "Instala Codex CLI via Homebrew",
        """Dependencias:
- Homebrew (debe estar instalado)

Acciones:
- verifica si codex ya está instalado
- ejecuta brew install codex""",
        (str(SCRIPT_DIR / "codex" / "install_codex.sh"),),
    ),
    Category(
        "intellij",
        "IntelliJ IDEA",
        "Instala IntelliJ IDEA Ultimate desde la API oficial de JetBrains",
        """Dependencias:
- jq
- curl
- tar

Acciones:
- consulta la última versión desde la API de JetBrains
- descarga e instala en /opt/intellij
- crea symlink idea en /usr/local/bin
- crea intellij-idea.desktop en ~/.local/share/applications""",
        (str(SCRIPT_DIR / "intellij" / "install_intellij.sh"),),
    ),
    Category(
        "post_install",
        "Post instalación",
        "Copia MIME, instala el comando update y deja la guía final",
        """Acciones:
- copia mimeapps/mimeapps.list a ~/.config/mimeapps.list si no existe
- instala el comando update desde system_update/install_update_command.sh
- copia COMANDOS.md a ~/COMANDOS.md si existe""",
        internal_runner=run_post_install_actions,
    ),
)


class InstallerApp:
    def __init__(self, stdscr: curses.window) -> None:
        self.stdscr = stdscr
        self.categories = list(CATEGORIES)
        self.selections = {category.key: True for category in self.categories}
        self.current_index = 0
        self.top_index = 0
        self.message = "↑/↓ navegar · Espacio/Enter alterna · A instalar · T toggle all · V ver · S salir"
        self.number_buffer = ""
        self.load_selections()

    def load_selections(self) -> None:
        if not CONFIG_FILE.exists():
            self.save_selections()
            return

        for raw_line in CONFIG_FILE.read_text(encoding="utf-8").splitlines():
            if not raw_line or raw_line.startswith("#") or "=" not in raw_line:
                continue
            key, value = raw_line.split("=", 1)
            if key in self.selections and value in {"ON", "OFF"}:
                self.selections[key] = value == "ON"

    def save_selections(self) -> None:
        lines = ["# init-install selections"]
        for category in self.categories:
            lines.append(f"{category.key}={'ON' if self.selections[category.key] else 'OFF'}")
        CONFIG_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")

    def toggle_current(self) -> None:
        category = self.categories[self.current_index]
        self.selections[category.key] = not self.selections[category.key]
        if self.selections[category.key]:
            for excluded in MUTUAL_EXCLUSIONS.get(category.key, []):
                if excluded in self.selections:
                    self.selections[excluded] = False
        self.save_selections()

    def toggle_all(self) -> None:
        enable_all = not all(self.selections.values())
        for key in self.selections:
            self.selections[key] = enable_all
        self.save_selections()
        self.message = "Todas las categorías activadas" if enable_all else "Todas las categorías desactivadas"

    def selected_categories(self) -> list[Category]:
        return [category for category in self.categories if self.selections[category.key]]

    def ensure_visible(self) -> None:
        height, _ = self.stdscr.getmaxyx()
        list_height = max(1, height - 6)
        if self.current_index < self.top_index:
            self.top_index = self.current_index
        elif self.current_index >= self.top_index + list_height:
            self.top_index = self.current_index - list_height + 1

    def add_line(self, y: int, x: int, text: str, attr: int = 0) -> None:
        height, width = self.stdscr.getmaxyx()
        if y >= height:
            return
        available = max(1, width - x - 1)
        self.stdscr.addnstr(y, x, text, available, attr)

    def render(self) -> None:
        self.stdscr.erase()
        curses.curs_set(0)
        self.ensure_visible()
        height, width = self.stdscr.getmaxyx()

        title = "INIT-INSTALL — Menú Interactivo"
        self.add_line(0, max(0, (width - len(title)) // 2), title, curses.A_BOLD)
        self.add_line(1, 0, f"Configuración: {CONFIG_FILE}")
        if self.number_buffer:
            self.add_line(2, 0, f"Número: {self.number_buffer} (Enter para alternar)", curses.A_DIM)
        else:
            self.add_line(2, 0, "Usá flechas para moverte o escribí un número de categoría", curses.A_DIM)

        start_y = 4
        visible_rows = max(1, height - 6)
        for row, index in enumerate(range(self.top_index, min(len(self.categories), self.top_index + visible_rows))):
            category = self.categories[index]
            marker = "[x]" if self.selections[category.key] else "[ ]"
            line = f"{index + 1:>2}. {marker} {category.key}"
            attr = curses.A_REVERSE if index == self.current_index else curses.A_NORMAL
            self.add_line(start_y + row, 0, line, attr)

        footer_y = height - 2
        self.add_line(footer_y, 0, "A: Instalar  T: Toggle All  V: Ver  S: Salir", curses.A_BOLD)
        self.add_line(footer_y + 1, 0, self.message)
        self.stdscr.refresh()

    def move(self, delta: int) -> None:
        self.current_index = max(0, min(len(self.categories) - 1, self.current_index + delta))
        self.number_buffer = ""

    def jump_to_number(self) -> None:
        if not self.number_buffer:
            return
        number = int(self.number_buffer)
        self.number_buffer = ""
        if 1 <= number <= len(self.categories):
            self.current_index = number - 1
            self.toggle_current()
            self.message = f"Alternado: {self.categories[self.current_index].title}"
        else:
            self.message = "Número fuera de rango"

    def view_current(self) -> None:
        category = self.categories[self.current_index]
        scroll = 0
        content = [category.title, "", category.summary, "", *category.packages.splitlines()]

        while True:
            self.stdscr.erase()
            height, width = self.stdscr.getmaxyx()
            wrapped: list[str] = []
            for line in content:
                parts = textwrap.wrap(line, max(20, width - 2)) or [""]
                wrapped.extend(parts)

            visible_height = max(1, height - 2)
            max_scroll = max(0, len(wrapped) - visible_height)
            scroll = max(0, min(scroll, max_scroll))

            for idx, line in enumerate(wrapped[scroll:scroll + visible_height]):
                self.add_line(idx, 0, line)
            self.add_line(height - 1, 0, "↑/↓ desplazar · q/Esc volver", curses.A_BOLD)
            self.stdscr.refresh()

            key = self.stdscr.getch()
            if key in (ord("q"), ord("Q"), 27):
                break
            if key in (curses.KEY_UP, ord("k")):
                scroll -= 1
            elif key in (curses.KEY_DOWN, ord("j")):
                scroll += 1
            elif key == curses.KEY_NPAGE:
                scroll += visible_height
            elif key == curses.KEY_PPAGE:
                scroll -= visible_height

    def draw_install_screen(self, current: int, total: int, category_title: str, logs: list[str]) -> None:
        self.stdscr.erase()
        height, width = self.stdscr.getmaxyx()

        percent = int((current / total) * 100) if total else 100
        bar_width = max(10, min(width - 12, 50))
        filled = int((percent / 100) * bar_width)
        bar = "[" + "#" * filled + "-" * (bar_width - filled) + "]"

        self.add_line(0, 0, "Instalando categorías", curses.A_BOLD)
        self.add_line(1, 0, f"[{current}/{total}] {category_title}")
        self.add_line(2, 0, f"Progreso: {bar} {percent}%")
        self.add_line(4, 0, "Salida en tiempo real:")

        log_height = max(1, height - 7)
        for idx, line in enumerate(logs[-log_height:]):
            self.add_line(5 + idx, 0, line)

        self.add_line(height - 1, 0, "No cierres la terminal durante la instalación", curses.A_DIM)
        self.stdscr.refresh()

    def run_script(self, script_path: str, current: int, total: int, category_title: str, logs: list[str]) -> None:
        script = Path(script_path)
        if not script.exists():
            raise FileNotFoundError(f"No se encontró el script: {script}")
        script.chmod(script.stat().st_mode | 0o111)

        process = subprocess.Popen(
            ["bash", str(script)],
            cwd=SCRIPT_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        assert process.stdout is not None
        for line in iter(process.stdout.readline, ""):
            logs.append(line.rstrip())
            self.draw_install_screen(current, total, category_title, logs)
        process.stdout.close()
        return_code = process.wait()
        if return_code != 0:
            raise subprocess.CalledProcessError(return_code, process.args)

    def pause_message(self, title: str, lines: list[str]) -> None:
        while True:
            self.stdscr.erase()
            height, width = self.stdscr.getmaxyx()
            self.add_line(0, 0, title, curses.A_BOLD)
            visible_height = max(1, height - 2)
            for idx, line in enumerate(lines[:visible_height]):
                self.add_line(1 + idx, 0, line)
            self.add_line(height - 1, 0, "Presioná una tecla para continuar", curses.A_BOLD)
            self.stdscr.refresh()
            self.stdscr.getch()
            return

    def append_log(self, logs: list[str], message: str, current: int, total: int, category_title: str) -> None:
        logs.append(message)
        self.draw_install_screen(current, total, category_title, logs)

    def run_installation(self) -> None:
        selected = self.selected_categories()
        if not selected:
            self.message = "Nada seleccionado"
            return

        all_logs: list[str] = []
        for index, category in enumerate(selected, start=1):
            category_logs = [f"==> {category.title}"]
            self.draw_install_screen(index, len(selected), category.title, category_logs)
            try:
                if category.internal_runner is not None:
                    category_logs.extend(category.internal_runner())
                    self.draw_install_screen(index, len(selected), category.title, category_logs)
                else:
                    for script in category.scripts:
                        self.run_script(script, index, len(selected), category.title, category_logs)
                category_logs.append(f"Completado: {category.title}")
                all_logs.extend(category_logs)
                self.draw_install_screen(index, len(selected), category.title, category_logs)
                time.sleep(0.5)
            except Exception as exc:
                category_logs.append(f"ERROR: {exc}")
                all_logs.extend(category_logs)
                self.draw_install_screen(index, len(selected), category.title, category_logs)
                self.pause_message("La instalación falló", category_logs[-20:])
                self.message = f"Falló: {category.title}"
                return

        self.pause_message("La instalación finalizó correctamente", all_logs[-20:] or ["Sin salida"])
        self.message = "Instalación completada"

    def run(self) -> None:
        self.stdscr.keypad(True)
        while True:
            self.render()
            key = self.stdscr.getch()

            if key in (curses.KEY_UP, ord("k")):
                self.move(-1)
            elif key in (curses.KEY_DOWN, ord("j")):
                self.move(1)
            elif key in (curses.KEY_HOME,):
                self.current_index = 0
                self.number_buffer = ""
            elif key in (curses.KEY_END,):
                self.current_index = len(self.categories) - 1
                self.number_buffer = ""
            elif key in (ord(" "), curses.KEY_ENTER, 10, 13):
                if self.number_buffer:
                    self.jump_to_number()
                else:
                    self.toggle_current()
                    self.message = f"Alternado: {self.categories[self.current_index].title}"
            elif ord("0") <= key <= ord("9"):
                digit = chr(key)
                next_buffer = self.number_buffer + digit
                if len(next_buffer) <= 2:
                    self.number_buffer = next_buffer.lstrip("0") or "0"
                    self.message = "Presioná Enter para alternar esa categoría"
            elif key in (ord("a"), ord("A")):
                self.number_buffer = ""
                self.run_installation()
            elif key in (ord("t"), ord("T")):
                self.number_buffer = ""
                self.toggle_all()
            elif key in (ord("v"), ord("V")):
                self.number_buffer = ""
                self.view_current()
            elif key in (ord("s"), ord("S"), ord("q"), ord("Q")):
                return
            elif key == 27:
                self.number_buffer = ""
                self.message = "Selección cancelada"


def validate_environment() -> None:
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        raise SystemExit("Este script requiere ejecutarse en una TTY interactiva.")
    for command in ("bash", "sudo"):
        if shutil.which(command) is None:
            raise SystemExit(f"Falta el comando requerido: {command}")
    if shutil.which("pacman") is None:
        raise SystemExit("Este script está pensado para Arch/derivados (pacman no encontrado).")
    subprocess.run(["sudo", "-v"], check=True)


def main(stdscr: curses.window) -> None:
    curses.use_default_colors()
    app = InstallerApp(stdscr)
    app.run()


if __name__ == "__main__":
    validate_environment()
    curses.wrapper(main)
