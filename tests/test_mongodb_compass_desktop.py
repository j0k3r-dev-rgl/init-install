import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_EXEC_LINE = 'Exec=env ELECTRON_OZONE_PLATFORM_HINT=auto "$INSTALL_DIR/MongoDB Compass" --ignore-additional-command-line-flags --password-store=gnome-libsecret'


class MongoDBCompassDesktopTests(unittest.TestCase):
    def test_install_and_update_desktop_entries_use_libsecret_password_store(self):
        for relative_path in (
            "mongodb_compass/install_compass.sh",
            "mongodb_compass/update_compass.sh",
        ):
            with self.subTest(script=relative_path):
                script = (ROOT / relative_path).read_text(encoding="utf-8")
                self.assertIn(REQUIRED_EXEC_LINE, script)


if __name__ == "__main__":
    unittest.main()
