#!/bin/bash
sleep 2
# Location and coordinates
LOCATION="Melbourne"
LAT="-37.814"
LON="144.9633"
THEME=$(cat ~/.config/.current_theme 2>/dev/null)
# Fetch current temperature and weather code
DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&timezone=auto")

# Extract values
TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m')
CODE=$(echo "$DATA" | jq -r '.current.weather_code')

# Simple mapping for weather condition icons

if [[ "$THEME" == "graphite-dark" ]]; then
  # Monochrome (Nerd Font)
  case "$CODE" in
    0) ICON="󰖙" ;;
    1|2|3) ICON="󰖕" ;;
    45|48) ICON="󰖑" ;;
    51|53|55) ICON="󰖗" ;;
    61|63|65) ICON="󰖖" ;;
    71|73|75) ICON="󰖘" ;;
    80|81|82) ICON="󰖖" ;;
    95|96|99) ICON="󰖓" ;;
    *) ICON="󰖐" ;;
  esac
else
  # Colour emoji
  case "$CODE" in
    0) ICON="☀️" ;;
    1|2|3) ICON="🌤️" ;;
    45|48) ICON="🌫️" ;;
    51|53|55) ICON="🌦️" ;;
    61|63|65) ICON="🌧️" ;;
    71|73|75) ICON="❄️" ;;
    80|81|82) ICON="🌧️" ;;
    95|96|99) ICON="⛈️" ;;
    *) ICON="❔" ;;
  esac
fi

# Main text for Waybar (icon + temperature)
TEXT="${ICON} ${TEMP}°C"

# Tooltip with location and temp
TOOLTIP="${LOCATION} ${ICON} ${TEMP}°C"

# Output JSON for Waybar
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
