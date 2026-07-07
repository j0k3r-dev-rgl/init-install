#!/usr/bin/env bash
set -euo pipefail

theme="$HOME/.config/rofi/productivity-menu.rasi"
selection="$(cliphist list | rofi -dmenu -i -p ' Clipboard' -mesg 'Pick an item to copy it back to clipboard' -theme "$theme" -theme-str 'window { width: 700px; } listview { lines: 8; }')"

if [[ -n "${selection:-}" ]]; then
  printf '%s' "$selection" | cliphist decode | wl-copy
fi
