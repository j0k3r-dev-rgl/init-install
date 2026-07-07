#!/usr/bin/env bash
set -euo pipefail

floating="$(hyprctl activewindow -j | jq -r '.floating // false')"

if [[ "$floating" == "true" ]]; then
  hyprctl dispatch togglefloating
else
  hyprctl dispatch togglefloating
  hyprctl dispatch resizeactive exact 1000 700
  hyprctl dispatch centerwindow
fi
