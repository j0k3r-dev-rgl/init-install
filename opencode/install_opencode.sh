#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_CONFIG_DIR="$SCRIPT_DIR/configs"
DST_DIR="$HOME/.config/opencode"

if ! command -v opencode >/dev/null 2>&1; then
    curl -fsSL https://opencode.ai/install | bash
fi

mkdir -p "$DST_DIR"
cp -an "$SRC_CONFIG_DIR"/. "$DST_DIR"/

if [ -f "$HOME/.zshrc" ] && ! grep -q '.opencode/bin' "$HOME/.zshrc"; then
    printf '\n# opencode\nexport PATH=$HOME/.opencode/bin:$PATH\n' >> "$HOME/.zshrc"
fi
