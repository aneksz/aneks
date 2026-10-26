#!/usr/bin/env bash

THEME_DIR="$HOME/.config/themes"
CURRENT_THEME_FILE="$HOME/.config/.current_theme"

current="$(cat "$CURRENT_THEME_FILE" 2>/dev/null | tr -d '[:space:]')"

options=$(find "$THEME_DIR" -maxdepth 1 -name "*.sh" -exec basename {} .sh \; | sort | awk -v cur="$current" '
$0 == cur { active="✔ " $0 }
$0 != cur { others[++i]=$0 }
END {
    if (active) print active
    for (j=1; j<=i; j++) print others[j]
}')

choice=$(echo "$options" | rofi -dmenu -p "Select Theme" -theme "$ROFI_THEME")

choice=$(echo "$choice" | sed 's/^✔ //')

[ -n "$choice" ] && bash "$THEME_DIR/$choice.sh"
