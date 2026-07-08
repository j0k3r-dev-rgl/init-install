#!/usr/bin/env bash
set -euo pipefail

notes_dir="$HOME/.notes"
notes_file="$notes_dir/inbox.md"
mkdir -p "$notes_dir"

if [[ ! -f "$notes_file" ]]; then
  cat > "$notes_file" <<'EOF'
# Inbox

- 
EOF
fi

exec "$HOME/.config/hypr/launch-terminal-app" --class quick-notes -- nvim "$notes_file"
