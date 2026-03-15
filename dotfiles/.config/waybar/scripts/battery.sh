#!/usr/bin/env bash

keyboard_dev="/org/freedesktop/UPower/devices/battery_hidpp_battery_0"
mouse_dev="/org/freedesktop/UPower/devices/battery_hidpp_battery_1"

keyboard=$(upower -i "$keyboard_dev" 2>/dev/null | awk '/percentage:/ {print $2}')
mouse=$(upower -i "$mouse_dev" 2>/dev/null | awk '/percentage:/ {print $2}')

# --- Default to N/A if not found ---
keyboard="${keyboard:-N/A}"
mouse="${mouse:-N/A}"

# --- Output plain text with % sign ---
echo "⌨️ ${keyboard} 🖱️ ${mouse}"
