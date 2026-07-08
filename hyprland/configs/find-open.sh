#!/usr/bin/env bash
set -euo pipefail

root="$HOME"
theme="$HOME/.config/rofi/productivity-menu.rasi"
rofi_theme_str='window { width: 860px; } listview { lines: 11; }'
small_theme_str='window { width: 380px; } listview { lines: 8; }'
launch_terminal_app="$HOME/.config/hypr/launch-terminal-app"

modes=(files configs places projects)
mode_index=0
case "${1:-}" in
  --files) mode_index=0 ;;
  --configs) mode_index=1 ;;
  --places) mode_index=2 ;;
  --projects) mode_index=3 ;;
esac
filter=""
picked_scope=""
last_mode_index=0
last_filter=""

fd_excludes=(--exclude .git --exclude node_modules --exclude .cache --exclude .local/share --exclude .npm --exclude .cargo --exclude .rustup --exclude .m2 --exclude target --exclude build --exclude dist --exclude out --exclude coverage --exclude .next --exclude .gradle --exclude .mongodb --exclude .mozilla --exclude .pki --exclude '.zcompdump*' --exclude '*.log' --exclude '*.log.gz' --exclude '*.zwc')

home_label_one() {
  local item="$1"
  if [[ "$item" == "$HOME" ]]; then
    printf '~'
  elif [[ "$item" == "$HOME/"* ]]; then
    printf '~/%s' "${item#$HOME/}"
  else
    printf '%s' "$item"
  fi
}

expand_home() {
  local item="$1"
  printf '%s' "${item/#\~/$HOME}"
}

entry() {
  local label="$1"
  local path="$2"
  printf '%s  —  %s\n' "$label" "$(home_label_one "$path")"
}

path_from_entry() {
  local selected="$1"
  if [[ "$selected" == *"  —  "* ]]; then
    selected="${selected##*  —  }"
  fi
  expand_home "$selected"
}

list_projects() {
  fd --hidden --type d '^\.git$' "$root" \
    --exclude node_modules \
    --exclude .cache \
    --exclude .local/share/Trash \
    --exclude .npm \
    --exclude .cargo \
    --exclude .rustup \
    --exclude .local/share/nvim/lazy \
    --exclude .local/share/nvim/mason \
    --exclude .local/share/pnpm \
    2>/dev/null \
    | while IFS= read -r gitdir; do dirname "$gitdir"; done \
    | sort -u \
    | while IFS= read -r repo; do
        entry "${repo#$HOME/}" "$repo"
      done
}

list_configs() {
  local paths=(
    "$HOME/.config/hypr"
    "$HOME/.config/nvim"
    "$HOME/.config/rofi"
    "$HOME/.config/eww"
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.gitconfig"
  )

  for path in "${paths[@]}"; do
    [[ -e "$path" ]] || continue
    if [[ "$path" == "$HOME/.config/"* ]]; then
      entry "config/${path#$HOME/.config/}" "$path"
    else
      entry "$(basename "$path")" "$path"
    fi
  done

  if [[ -d "$HOME/.config" ]]; then
    fd --hidden --max-depth 1 --type d . "$HOME/.config" 2>/dev/null \
      | sort -u \
      | while IFS= read -r dir; do
          case "$dir" in
            "$HOME/.config/hypr"|"$HOME/.config/nvim"|"$HOME/.config/rofi"|"$HOME/.config/eww") continue ;;
          esac
          entry "config/${dir#$HOME/.config/}" "$dir"
        done
  fi
}

list_places() {
  local paths=(
    "$HOME"
    "$HOME/Downloads"
    "$HOME/Documents"
    "$HOME/Pictures"
    "$HOME/Videos"
    "$HOME/Music"
    "$HOME/.config"
    "$HOME/.local/bin"
    "/run/media/$USER"
  )

  for path in "${paths[@]}"; do
    [[ -e "$path" ]] && entry "$(home_label_one "$path")" "$path"
  done
}

list_file_scopes() {
  fd --hidden --type d '^\.git$' "$HOME" \
    --exclude node_modules \
    --exclude .cache \
    --exclude .local/share/Trash \
    --exclude .npm \
    --exclude .cargo \
    --exclude .rustup \
    --exclude .local/share/nvim/lazy \
    --exclude .local/share/nvim/mason \
    --exclude .local/share/pnpm \
    2>/dev/null \
    | while IFS= read -r gitdir; do dirname "$gitdir"; done \
    | sort -u \
    | while IFS= read -r scope; do
        [[ -d "$scope" ]] || continue
        case "$scope" in
          "$HOME"/.*) continue ;;
          "$HOME"/Downloads|"$HOME"/Documents|"$HOME"/Pictures|"$HOME"/Videos|"$HOME"/Music) continue ;;
        esac
        printf '%s\n' "$scope"
      done

  for scope in "$HOME/Documents" "$HOME/Downloads" "$HOME/.config"; do
    [[ -d "$scope" ]] && printf '%s\n' "$scope"
  done
}

list_global_files() {
  list_file_scopes \
    | while IFS= read -r scope; do
        (cd "$scope" && rg --files --hidden \
          -g '!.git' \
          -g '!node_modules' \
          -g '!.cache' \
          -g '!.local/share' \
          -g '!.npm' \
          -g '!.cargo' \
          -g '!.rustup' \
          -g '!.m2' \
          -g '!target' \
          -g '!build' \
          -g '!dist' \
          -g '!out' \
          -g '!coverage' \
          -g '!.next' \
          -g '!.gradle' \
          -g '!.mongodb' \
          -g '!.mozilla' \
          -g '!.pki' \
          -g '!.zcompdump*' \
          -g '!*.log' \
          -g '!*.log.gz' \
          -g '!*.zwc' \
          2>/dev/null) \
          | while IFS= read -r file; do
              entry "${scope#$HOME/}/$file" "$scope/$file"
            done
      done \
    | awk 'NF && !seen[$0]++'
}

entries_for_mode() {
  case "$1" in
    projects) list_projects ;;
    configs) list_configs ;;
    places) list_places ;;
    files) list_global_files ;;
  esac
}

mode_label() {
  case "$1" in
    projects) printf 'Projects' ;;
    configs) printf 'Configs' ;;
    places) printf 'Places' ;;
    files) printf 'Files' ;;
  esac
}

pick_scope() {
  while true; do
    local mode="${modes[$mode_index]}"
    local result code selected typed fifo producer_pid

    set +e
    set +o pipefail
    if [[ "$mode" == files ]]; then
      fifo="$(mktemp -u)"
      mkfifo "$fifo"
      entries_for_mode "$mode" > "$fifo" &
      producer_pid=$!

      result="$(rofi \
        -dmenu \
        -i \
        -input "$fifo" \
        -format 's|||f' \
        -filter "$filter" \
        -p "󰱼 $(mode_label "$mode")" \
        -mesg 'Type to filter files live · Enter: open submenu · Tab: Files / Configs / Places / Projects' \
        -kb-element-next '' \
        -kb-custom-1 'Tab' \
        -theme "$theme" \
        -theme-str "$rofi_theme_str")"
      code=$?

      kill "$producer_pid" 2>/dev/null || true
      wait "$producer_pid" 2>/dev/null || true
      rm -f "$fifo"
    else
      result="$(entries_for_mode "$mode" | rofi \
        -dmenu \
        -i \
        -no-custom \
        -format 's|||f' \
        -filter "$filter" \
        -p "󰱼 $(mode_label "$mode")" \
        -mesg 'Tab: Files / Configs / Places / Projects · Enter: choose scope' \
        -kb-element-next '' \
        -kb-custom-1 'Tab' \
        -theme "$theme" \
        -theme-str "$rofi_theme_str")"
      code=$?
    fi
    set -o pipefail
    set -e

    selected="${result%%|||*}"
    if [[ "$result" == *'|||'* ]]; then
      typed="${result#*|||}"
    else
      typed=""
    fi

    if [[ $code -eq 10 ]]; then
      filter="$typed"
      mode_index=$(( (mode_index + 1) % ${#modes[@]} ))
      continue
    fi

    [[ $code -eq 0 && -n "${selected:-}" ]] || exit 0

    filter="$typed"
    last_filter="$filter"
    last_mode_index="$mode_index"
    picked_scope="$(path_from_entry "$selected")"
    return
  done
}

pick_from_scope() {
  local scope="$1"
  local type="$2"
  local prompt="$3"
  local result code selected

  set +e
  result="$(cd "$scope" && fd --hidden --type "$type" "${fd_excludes[@]}" . . 2>/dev/null \
    | sed 's#^./##' \
    | rofi -dmenu -i -no-custom -p "$prompt" -mesg "Searching inside $(home_label_one "$scope")" -theme "$theme" -theme-str "$rofi_theme_str")"
  code=$?
  set -e

  [[ $code -eq 0 && -n "${result:-}" ]] || return 1
  selected="$scope/$result"
  [[ -e "$selected" ]] || return 1
  printf '%s\n' "$selected"
}

repo_root_for() {
  local dir="$1"
  git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true
}

open_project_workspace() {
  local dir="$1"

  "$launch_terminal_app" --class project-pi --working-directory "$dir" -- pi >/dev/null 2>&1 &
  sleep 0.35
  hyprctl dispatch layoutmsg preselect r >/dev/null 2>&1 || true
  "$launch_terminal_app" --class project-nvim --working-directory "$dir" -- nvim . >/dev/null 2>&1 &
  sleep 0.15
  hyprctl dispatch layoutmsg preselect none >/dev/null 2>&1 || true
}

open_actions() {
  local path="$1"
  local workdir target repo_root choice choice_code

  if [[ -d "$path" ]]; then
    workdir="$path"
    target="$path"
  else
    workdir="$(dirname "$path")"
    target="$path"
  fi

  repo_root="$(repo_root_for "$workdir")"

  local choices=("back" "terminal" "nvim" "pi" "yazi" "find files" "find folders")
  if [[ -n "$repo_root" && "$workdir" == "$repo_root" ]]; then
    choices=("back" "project: pi + nvim" "terminal" "nvim" "pi" "yazi" "find files" "find folders")
  fi

  set +e
  choice="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p '󰏌 Open with' -theme "$theme" -theme-str "$small_theme_str")"
  choice_code=$?
  set -e
  [[ $choice_code -eq 0 && -n "${choice:-}" ]] || exit 0

  case "$choice" in
    back)
      printf '__BACK__\n'
      return 0
      ;;
    "project: pi + nvim")
      open_project_workspace "${repo_root:-$workdir}"
      ;;
    terminal)
      exec "$launch_terminal_app" --working-directory "$workdir"
      ;;
    nvim)
      exec "$launch_terminal_app" --class finder-nvim --working-directory "$workdir" -- nvim "$target"
      ;;
    pi)
      exec "$launch_terminal_app" --class finder-pi --working-directory "$workdir" -- pi
      ;;
    yazi)
      exec "$launch_terminal_app" --class finder-yazi --working-directory "$workdir" -- yazi "$target"
      ;;
    "find files")
      local found_file
      found_file="$(pick_from_scope "$workdir" f '󰱼 Files in scope')" || exit 0
      exec "$launch_terminal_app" --class finder-nvim --working-directory "$workdir" -- nvim "$found_file"
      ;;
    "find folders")
      local found_dir
      found_dir="$(pick_from_scope "$workdir" d '󰉋 Folders in scope')" || exit 0
      open_actions "$found_dir"
      ;;
  esac
}

while true; do
  pick_scope
  scope="$picked_scope"
  [[ -e "$scope" ]] || exit 0

  set +e
  action_result="$(open_actions "$scope")"
  status=$?
  set -e

  if [[ "$action_result" == "__BACK__" ]]; then
    mode_index="$last_mode_index"
    filter="$last_filter"
    continue
  fi
  exit "$status"
done
