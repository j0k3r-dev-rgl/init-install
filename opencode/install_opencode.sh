#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_FILE="$SCRIPT_DIR/configs/opencode.json"
DST_DIR="$HOME/.config/opencode"
DST_FILE="$DST_DIR/opencode.json"

if ! command -v opencode >/dev/null 2>&1; then
    curl -fsSL https://opencode.ai/install | bash
fi

mkdir -p "$DST_DIR"
if [ ! -f "$DST_FILE" ]; then
    cp "$SRC_FILE" "$DST_FILE"
fi

if [ -f "$HOME/.zshrc" ] && ! grep -q '.opencode/bin' "$HOME/.zshrc"; then
    printf '\n# opencode\nexport PATH=/home/j0k3r/.opencode/bin:$PATH\n' >> "$HOME/.zshrc"
fi
