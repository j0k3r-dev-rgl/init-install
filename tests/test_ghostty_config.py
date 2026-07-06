import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GHOSTTY_CONFIG = ROOT / "ghostty" / "configs" / "config"


class GhosttyConfigTests(unittest.TestCase):
    def test_ghostty_config_exists_with_arch_electric_style_and_opacity(self):
        self.assertTrue(GHOSTTY_CONFIG.exists())
        source = GHOSTTY_CONFIG.read_text(encoding="utf-8")

        for expected in [
            "background-opacity = 0.85",
            "background = 000000",
            "foreground = 8be9fd",
            "palette = 4=#00bfff",
            "palette = 7=#8be9fd",
            "font-family = JetBrainsMono Nerd Font",
            "font-size = 10",
            "window-padding-x = 15",
            "window-padding-y = 15",
        ]:
            with self.subTest(expected=expected):
                self.assertIn(expected, source)


if __name__ == "__main__":
    unittest.main()
