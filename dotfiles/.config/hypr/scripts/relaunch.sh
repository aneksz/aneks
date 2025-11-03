#!/usr/bin/env bash
set -eu

# Optional notify (may not always show if compositor dies quickly)
notify-send "Omarchy" "Relaunching Hyprland…"

# stop the current uwsm-managed session (graceful)
uwsm stop || true

# short pause to let units settle
sleep 1

# start the hyprland desktop entry again (use the same desktop id Omarchy's session uses)
# most installs use hyprland.desktop — adjust if yours differs
uwsm start hyprland.desktop

