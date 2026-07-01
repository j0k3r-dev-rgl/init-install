import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INSTALL_PY = ROOT / "install.py"
BOOTSTRAP = ROOT / "install.sh"
README = ROOT / "README.md"
INSTALLER = ROOT / "zsh" / "install_zsh.sh"


class ZshInstallerTests(unittest.TestCase):
    def test_zsh_menu_points_to_existing_zsh_module(self):
        source = INSTALL_PY.read_text(encoding="utf-8")

        self.assertIn('Category("zsh", "Zsh"', source)
        self.assertIn('scripts("zsh/install_zsh.sh")', source)
        self.assertIn("Oh My Zsh", source)
        self.assertNotIn('scripts("pre_install.sh")', source)
        self.assertTrue(INSTALLER.exists())

    def test_zsh_installer_installs_and_activates_oh_my_zsh_plugins(self):
        script = INSTALLER.read_text(encoding="utf-8")

        self.assertIn("sudo pacman -S --needed --noconfirm zsh git eza", script)
        self.assertIn("ohmyzsh/ohmyzsh.git", script)
        for plugin in [
            "zsh-users/zsh-autosuggestions.git",
            "zsh-users/zsh-syntax-highlighting.git",
            "zsh-users/zsh-completions.git",
        ]:
            with self.subTest(plugin=plugin):
                self.assertIn(plugin, script)
        self.assertIn("${HOME}/.zshrc", script)
        self.assertIn(".backup.", script)
        self.assertIn("Backup de .zshrc", script)
        self.assertIn("# >>> init-install zsh", script)
        self.assertIn("plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)", script)
        self.assertIn('source "$ZSH/oh-my-zsh.sh"', script)
        for alias in [
            "alias ls='eza --icons --group-directories-first'",
            "alias ll='eza -lh --icons --group-directories-first'",
            "alias la='eza -aH --icons --group-directories-first'",
            "alias h='cat ~/COMANDOS.md | less'",
        ]:
            with self.subTest(alias=alias):
                self.assertIn(alias, script)
        self.assertIn("current_block", script)
        self.assertIn("managed_block", script)
        self.assertIn('if [ "$current_block" = "$managed_block" ]; then', script)
        self.assertIn("Bloque Zsh ya está actualizado", script)
        self.assertNotIn("chsh", script)

    def test_docs_and_bootstrap_reference_zsh_module_not_setup(self):
        bootstrap = BOOTSTRAP.read_text(encoding="utf-8")
        readme = README.read_text(encoding="utf-8")

        self.assertIn("Install software -> Zsh", bootstrap)
        self.assertNotIn("Install software -> Zsh setup", bootstrap)
        self.assertIn("Zsh", readme)
        self.assertNotIn("Zsh setup", readme)


if __name__ == "__main__":
    unittest.main()
