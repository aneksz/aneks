#!/usr/bin/env bash

# Get Solaar output
solaar_output=$(solaar show 2>/dev/null)

# Extract battery for keyboard (MX Keys)
keyboard=$(echo "$solaar_output" | awk '/MX Keys/{f=1} f && /Battery:/ {print $2; exit}' | tr -d ',')
# Extract battery for mouse (MX Master 2S)
mouse=$(echo "$solaar_output" | awk '/MX Master 2S/{f=1} f && /Battery:/ {print $2; exit}' | tr -d ',')

# Fallbacks
keyboard="${keyboard:-N/A}"
mouse="${mouse:-N/A}"

# Output for Waybar
echo "  $keyboard  $mouse"

