import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INSTALL_PY = ROOT / "install.py"
HYPR_AUTOSTART = ROOT / "hyprland" / "configs" / "autostart.conf"
MANGO_CONFIG = ROOT / "mango" / "configs" / "config.conf"
HYPR_CONFIGURE = ROOT / "hyprland" / "configure_hyprland.sh"
SESSION_INSTALLER = ROOT / "session" / "install_session_profiles.sh"
SESSION_SCRIPT = ROOT / "session" / "init-install-session"
AUTOSTART_SCRIPT = ROOT / "session" / "init-install-autostart"


class SessionProfilesTests(unittest.TestCase):
    def test_desktop_menu_exposes_tty_session_profiles(self):
        source = INSTALL_PY.read_text(encoding="utf-8")

        self.assertIn('Category("session_profiles", "TTY session profiles"', source)
        self.assertIn('scripts("session/install_session_profiles.sh")', source)

    def test_compositor_configs_use_common_autostart_hook_not_specific_bars(self):
        hypr = HYPR_AUTOSTART.read_text(encoding="utf-8")
        mango = MANGO_CONFIG.read_text(encoding="utf-8")

        self.assertIn("init-install-autostart", hypr)
        self.assertIn("init-install-autostart", mango)
        self.assertNotIn("exec-once = waybar &", hypr)
        self.assertNotIn("exec-once=waybar", hypr)
        self.assertNotIn("exec-once=qs -c noctalia-shell", mango)

    def test_hyprland_configure_no_longer_hardcodes_tty1_session(self):
        source = HYPR_CONFIGURE.read_text(encoding="utf-8")

        self.assertNotIn('XDG_VTNR-}" = "1"', source)
        self.assertNotIn("exec start-hyprland", source)

    def test_session_scripts_exist_and_support_expected_values(self):
        installer = SESSION_INSTALLER.read_text(encoding="utf-8")
        session = SESSION_SCRIPT.read_text(encoding="utf-8")
        autostart = AUTOSTART_SCRIPT.read_text(encoding="utf-8")

        self.assertIn("# >>> init-install session", installer)
        self.assertIn("# >>> init-install tty profiles", installer)
        self.assertIn("TTY%s_DESKTOP=%s", installer)
        self.assertIn("TTY%s_BAR=%s", installer)
        self.assertIn("start-hyprland", session)
        self.assertIn("exec mango", session)
        self.assertIn("INIT_INSTALL_BAR", autostart)
        self.assertIn("waybar", autostart)
        self.assertIn("qs -c noctalia-shell", autostart)

    def test_installer_replaces_existing_tty_profile_without_duplicates(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            env = os.environ.copy()
            env["HOME"] = str(home)
            env["XDG_CONFIG_HOME"] = str(home / ".config")
            (home / ".zprofile").write_text(
                "export KEEP_ME=1\n\n"
                'if [ -z "${DISPLAY-}" ] && [ "${XDG_VTNR-}" = "1" ]; then\n'
                "  exec start-hyprland\n"
                "fi\n",
                encoding="utf-8",
            )

            subprocess.run(
                [
                    "bash",
                    str(SESSION_INSTALLER),
                    "--tty",
                    "3",
                    "--desktop",
                    "hyprland",
                    "--bar",
                    "waybar",
                ],
                check=True,
                cwd=ROOT,
                env=env,
                text=True,
                capture_output=True,
            )
            subprocess.run(
                [
                    "bash",
                    str(SESSION_INSTALLER),
                    "--tty",
                    "3",
                    "--desktop",
                    "mango",
                    "--bar",
                    "noctalia",
                ],
                check=True,
                cwd=ROOT,
                env=env,
                text=True,
                capture_output=True,
            )

            profile = home / ".config" / "init-install" / "tty-profiles.conf"
            zprofile = home / ".zprofile"
            assert profile.exists()
            assert zprofile.exists()
            profile_text = profile.read_text(encoding="utf-8")
            zprofile_text = zprofile.read_text(encoding="utf-8")

            self.assertEqual(profile_text.count("TTY3_DESKTOP="), 1)
            self.assertEqual(profile_text.count("TTY3_BAR="), 1)
            self.assertIn("TTY3_DESKTOP=mango", profile_text)
            self.assertIn("TTY3_BAR=noctalia", profile_text)
            self.assertNotIn("TTY3_DESKTOP=hyprland", profile_text)
            self.assertIn("export KEEP_ME=1", zprofile_text)
            self.assertNotIn("exec start-hyprland", zprofile_text)
            self.assertEqual(zprofile_text.count("# >>> init-install session"), 1)
            self.assertTrue((home / ".local" / "bin" / "init-install-session").exists())
            self.assertTrue((home / ".local" / "bin" / "init-install-autostart").exists())


if __name__ == "__main__":
    unittest.main()
