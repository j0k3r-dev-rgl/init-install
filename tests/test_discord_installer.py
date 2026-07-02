import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INSTALL_PY = ROOT / "install.py"
INSTALLER = ROOT / "discord" / "install_discord.sh"


class DiscordInstallerTests(unittest.TestCase):
    def test_discord_menu_uses_dedicated_installer(self):
        source = INSTALL_PY.read_text(encoding="utf-8")

        self.assertIn('Category("discord", "Discord", "Cliente Discord con soporte de compartir pantalla"', source)
        self.assertIn('scripts("discord/install_discord.sh")', source)
        self.assertNotIn('internal_runner=install_pacman_packages("Discord", ["discord"])', source)

    def test_discord_installer_installs_screen_sharing_dependencies(self):
        script = INSTALLER.read_text(encoding="utf-8")

        for package in [
            "discord",
            "pipewire",
            "pipewire-alsa",
            "pipewire-pulse",
            "wireplumber",
            "xdg-desktop-portal",
            "xdg-desktop-portal-gtk",
            "xdg-desktop-portal-wlr",
        ]:
            with self.subTest(package=package):
                self.assertIn(package, script)

    def test_discord_installer_creates_user_launcher_with_pipewire_flags(self):
        script = INSTALLER.read_text(encoding="utf-8")

        self.assertIn("$HOME/.local/share/applications/discord.desktop", script)
        self.assertIn("/usr/share/applications/discord.desktop", script)
        self.assertIn("--enable-features=WebRTCPipeWireCapturer", script)
        self.assertIn("--ozone-platform-hint=auto", script)
        self.assertIn("update-desktop-database", script)


if __name__ == "__main__":
    unittest.main()
