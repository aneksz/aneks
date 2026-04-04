#!/bin/bash
sleep 2
# Location and coordinates
LOCATION="Melbourne"
LAT="-37.814"
LON="144.9633"

# Fetch current temperature and weather code
DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&timezone=auto")

# Extract values
TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m')
CODE=$(echo "$DATA" | jq -r '.current.weather_code')

# Simple mapping for weather condition icons
case "$CODE" in
  0) ICON="☀️" ;;        # Clear sky
  1|2|3) ICON="🌤️" ;;    # Mainly clear, partly cloudy, overcast
  45|48) ICON="🌫️" ;;    # Fog
  51|53|55) ICON="🌦️" ;; # Drizzle
  61|63|65) ICON="🌧️" ;; # Rain
  71|73|75) ICON="❄️" ;; # Snow
  80|81|82) ICON="🌧️" ;; # Rain showers
  95|96|99) ICON="⛈️" ;; # Thunderstorm
  *) ICON="❔" ;;         # Unknown
esac

# Main text for Waybar (icon + temperature)
TEXT="${ICON} ${TEMP}°C"

# Tooltip with location and temp
TOOLTIP="${LOCATION} ${ICON} ${TEMP}°C"

# Output JSON for Waybar
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
