#!/usr/bin/env python3
"""
Color Picker para Waybar/swaync — actualización en tiempo real
"""

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib

import re, os, subprocess, copy, signal

COLORS_FILE = os.path.expanduser("~/.config/waybar/colors.css")

# Ignorar SIGUSR1/2 por si pkill los envía accidentalmente a este proceso
signal.signal(signal.SIGUSR1, signal.SIG_IGN)
signal.signal(signal.SIGUSR2, signal.SIG_IGN)

# ─── Descripción de cada variable (qué afecta en la UI) ─────────────────────

COLOR_META = {
    "bg": {
        "label": "Fondo de barra y panel",
        "desc":  "Color base de waybar y del panel de notificaciones",
    },
    "surface": {
        "label": "Fondo de módulos",
        "desc":  "CPU, RAM, red, volumen — fondo de cada módulo",
    },
    "surface2": {
        "label": "Fondo hover / activo",
        "desc":  "Color al pasar el cursor sobre un módulo o botón",
    },
    "border": {
        "label": "Bordes y separadores",
        "desc":  "Líneas que rodean módulos, tarjetas y notificaciones",
    },
    "text": {
        "label": "Texto principal",
        "desc":  "Porcentajes, nombres de ventana, texto de notificaciones",
    },
    "text-muted": {
        "label": "Texto secundario",
        "desc":  "Descripción de notificaciones, hora, texto desactivado",
    },
    "blue": {
        "label": "Acento — CPU y notificaciones",
        "desc":  "Barra de CPU, icono de notificaciones, resaltados",
    },
    "cyan": {
        "label": "Acento — RAM y volumen",
        "desc":  "Barra de RAM, slider de volumen, sliders en panel",
    },
    "green": {
        "label": "Estado OK — Red conectada",
        "desc":  "Indicador de red activa, velocidades de descarga/subida",
    },
    "orange": {
        "label": "Advertencia — Temperatura",
        "desc":  "Sensor de temperatura, estado warning en CPU/RAM/Disco",
    },
    "red": {
        "label": "Critico — Botón de apagado",
        "desc":  "Botón apagado en barra, estado crítico, botones peligrosos",
    },
    "purple": {
        "label": "Acento — Disco",
        "desc":  "Indicador de uso de disco",
    },
}

DEFAULTS = {
    "bg":         "#0d1117",
    "surface":    "#161b22",
    "surface2":   "#21262d",
    "border":     "#30363d",
    "text":       "#c9d1d9",
    "text-muted": "#8b949e",
    "blue":       "#58a6ff",
    "cyan":       "#79c0ff",
    "green":      "#3fb950",
    "orange":     "#d29922",
    "red":        "#f85149",
    "purple":     "#bc8cff",
}

# ─── Helpers ─────────────────────────────────────────────────────────────────

def hex_to_rgba(hex_color):
    rgba = Gdk.RGBA()
    rgba.parse(hex_color)
    return rgba

def rgba_to_hex(rgba):
    r = int(rgba.red * 255)
    g = int(rgba.green * 255)
    b = int(rgba.blue * 255)
    return f"#{r:02x}{g:02x}{b:02x}"

def read_colors():
    colors = dict(DEFAULTS)
    try:
        with open(COLORS_FILE) as f:
            content = f.read()
        for m in re.finditer(r'@define-color\s+(\S+)\s+(#[0-9a-fA-F]{6});', content):
            colors[m.group(1)] = m.group(2)
    except FileNotFoundError:
        pass
    return colors

def write_all_colors(colors_dict):
    try:
        with open(COLORS_FILE) as f:
            content = f.read()
        for name, val in colors_dict.items():
            content = re.sub(
                rf'(@define-color\s+{re.escape(name)}\s+)(#[0-9a-fA-F]{{6}})(;)',
                rf'\g<1>{val}\g<3>',
                content
            )
        with open(COLORS_FILE, 'w') as f:
            f.write(content)
    except Exception as e:
        print(f"Error escribiendo colors.css: {e}")

def reload_waybar():
    """Envía SIGUSR2 directamente a los PIDs de waybar desde Python."""
    try:
        result = subprocess.run(['pidof', 'waybar'], capture_output=True, text=True)
        pids = result.stdout.strip().split()
        for pid in pids:
            if pid:
                os.kill(int(pid), signal.SIGUSR2)
    except Exception as e:
        print(f"Error recargando waybar: {e}")

def reload_swaync():
    subprocess.Popen(
        'pkill -x swaync 2>/dev/null; sleep 0.2 && swaync &',
        shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )

def reload_all():
    reload_waybar()
    reload_swaync()

# ─── CSS de la ventana ───────────────────────────────────────────────────────

def apply_dark_css():
    css = b"""
    window { background-color: #0d1117; color: #c9d1d9; }
    .title  { font-size: 14px; font-weight: bold; color: #58a6ff; padding: 0 0 8px 0; }
    .name   { color: #c9d1d9; font-weight: bold; font-size: 13px; }
    .desc   { color: #8b949e; font-size: 11px; }
    .row    {
        background-color: #161b22;
        border-radius: 8px;
        padding: 8px 12px;
        margin: 2px 0;
        border: 1px solid #30363d;
    }
    .row:hover { background-color: #21262d; border-color: #58a6ff; }
    button.sec {
        background-color: #21262d; color: #8b949e;
        border: 1px solid #30363d; border-radius: 6px;
        padding: 6px 14px; font-size: 12px; min-width: 90px;
    }
    button.sec:hover { background-color: #30363d; color: #c9d1d9; }
    button.save {
        background-color: rgba(63,185,80,0.15); color: #3fb950;
        border: 1px solid #3fb950; border-radius: 6px;
        padding: 6px 14px; font-size: 12px; font-weight: bold; min-width: 90px;
    }
    button.save:hover { background-color: rgba(63,185,80,0.25); }
    button.danger {
        background-color: #21262d; color: #f85149;
        border: 1px solid #30363d; border-radius: 6px;
        padding: 6px 14px; font-size: 12px; min-width: 90px;
    }
    button.danger:hover { background-color: rgba(248,81,73,0.12); border-color: #f85149; }
    separator { background-color: #30363d; min-height: 1px; margin: 6px 0; }
    """
    provider = Gtk.CssProvider()
    provider.load_from_data(css)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

# ─── Ventana ─────────────────────────────────────────────────────────────────

class ColorPickerWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Colores del tema")
        self.set_default_size(440, 600)
        self.set_border_width(16)
        self.set_resizable(False)

        apply_dark_css()

        self.original  = read_colors()
        self.current   = copy.deepcopy(self.original)
        self._pending  = False
        self._buttons  = {}   # name → ColorButton

        self._build()
        self.connect("delete-event", self._on_delete)

    def _build(self):
        if self.get_child():
            self.get_child().destroy()

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(outer)

        title = Gtk.Label(label="󰏘  Personalizar colores del tema")
        title.get_style_context().add_class("title")
        title.set_halign(Gtk.Align.START)
        outer.pack_start(title, False, False, 0)

        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)
        outer.pack_start(scroll, True, True, 0)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        scroll.add(vbox)
        self._buttons.clear()

        for name, meta in COLOR_META.items():
            hex_val = self.current.get(name, "#ffffff")

            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
            row.get_style_context().add_class("row")

            # Texto
            texts = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            texts.set_hexpand(True)

            lbl = Gtk.Label(label=meta["label"])
            lbl.get_style_context().add_class("name")
            lbl.set_halign(Gtk.Align.START)

            dlbl = Gtk.Label(label=meta["desc"])
            dlbl.get_style_context().add_class("desc")
            dlbl.set_halign(Gtk.Align.START)
            dlbl.set_line_wrap(True)

            texts.pack_start(lbl, False, False, 0)
            texts.pack_start(dlbl, False, False, 0)

            # Color button
            btn = Gtk.ColorButton.new_with_rgba(hex_to_rgba(hex_val))
            btn.connect("color-set", self._on_color_changed, name)
            self._buttons[name] = btn

            row.pack_start(texts, True, True, 0)
            row.pack_end(btn, False, False, 0)
            vbox.pack_start(row, False, False, 0)

        # Footer
        outer.pack_start(Gtk.Separator(), False, False, 6)

        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        outer.pack_start(footer, False, False, 0)

        reset_btn = Gtk.Button(label="Restaurar defaults")
        reset_btn.get_style_context().add_class("sec")
        reset_btn.connect("clicked", self._on_reset)

        save_btn = Gtk.Button(label="Guardar")
        save_btn.get_style_context().add_class("save")
        save_btn.connect("clicked", self._on_save)

        cancel_btn = Gtk.Button(label="Cancelar")
        cancel_btn.get_style_context().add_class("danger")
        cancel_btn.connect("clicked", self._on_cancel_btn)

        footer.pack_start(reset_btn, False, False, 0)
        footer.pack_end(cancel_btn, False, False, 0)
        footer.pack_end(save_btn, False, False, 0)

        self.show_all()

    # ── Callbacks ─────────────────────────────────────────────────────────────

    def _on_color_changed(self, btn, name):
        self.current[name] = rgba_to_hex(btn.get_rgba())
        write_all_colors(self.current)
        if not self._pending:
            self._pending = True
            GLib.timeout_add(150, self._do_reload)

    def _do_reload(self):
        reload_all()
        self._pending = False
        return False

    def _on_reset(self, _):
        self.current = copy.deepcopy(DEFAULTS)
        write_all_colors(self.current)
        reload_all()
        self._build()

    def _on_save(self, _):
        """Guarda los colores actuales y cierra."""
        write_all_colors(self.current)
        reload_all()
        self.destroy()
        Gtk.main_quit()

    def _on_cancel_btn(self, _):
        self._revert_and_quit()

    def _on_delete(self, *_):
        self._revert_and_quit()
        return True   # impide cierre automático; lo hacemos nosotros

    def _revert_and_quit(self):
        write_all_colors(self.original)
        reload_all()
        self.destroy()
        Gtk.main_quit()


win = ColorPickerWindow()
win.show_all()
Gtk.main()
