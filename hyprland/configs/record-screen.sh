#!/usr/bin/env bash
set -u

PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-screen-recording.pid"
OUTPUT_DIR="$HOME/Videos/Screencasts"

notify() {
  notify-send "$1"
}

if [[ -f "$PID_FILE" ]]; then
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${pid:-}" ]] && kill -0 "$pid" 2>/dev/null; then
    kill -INT "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    notify "Recording stopped"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
  notify "Install wf-recorder to record the screen"
  exit 1
fi

if ! command -v slurp >/dev/null 2>&1; then
  notify "Install slurp to select an area"
  exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
  notify "Install rofi to choose the recording mode"
  exit 1
fi

theme="$HOME/.config/rofi/productivity-menu.rasi"
choice="$(printf 'Area\nFull screen\nCancel\n' | rofi -dmenu -p '󰑋 Record' -mesg 'Choose recording mode · running again stops current recording' -theme "$theme" -theme-str 'window { width: 420px; } listview { lines: 3; }')"

case "$choice" in
  "Area")
    geometry="$(slurp 2>/dev/null || true)"
    [[ -n "$geometry" ]] || exit 0
    args=(-g "$geometry")
    ;;
  "Full screen")
    args=()
    ;;
  *)
    exit 0
    ;;
esac

mkdir -p "$OUTPUT_DIR"
output="$OUTPUT_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"

for seconds in 3 2 1; do
  notify "Recording starts in $seconds"
  sleep 1
done

wf-recorder "${args[@]}" -f "$output" >/tmp/hypr-screen-recording.log 2>&1 &
pid=$!
echo "$pid" > "$PID_FILE"

notify "Recording started"
