#!/bin/bash

# =====================================================
# WEATHER
# =====================================================

LAT="-37.814"
LON="144.9633"

# =====================================================
# FETCH CURRENT WEATHER
# =====================================================

DATA=$(curl -s --max-time 4 \
    "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day&timezone=auto")

# =====================================================
# VALIDATE RESPONSE
# =====================================================

if [[ -z "$DATA" ]] || ! echo "$DATA" | jq -e '.current' >/dev/null 2>&1; then
    echo $'\ue312 --°C'
    exit 0
fi

# =====================================================
# GET CURRENT CONDITIONS
# =====================================================

TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m')
CODE=$(echo "$DATA" | jq -r '.current.weather_code')
IS_DAY=$(echo "$DATA" | jq -r '.current.is_day')

# =====================================================
# WEATHER ICON
#
# Open-Meteo WMO weather codes:
#
# 0       Clear sky
# 1       Mainly clear
# 2       Partly cloudy
# 3       Overcast
# 45/48   Fog
# 51-55   Drizzle
# 56/57   Freezing drizzle
# 61-65   Rain
# 66/67   Freezing rain
# 71-75   Snow
# 77      Snow grains
# 80-82   Rain showers
# 85/86   Snow showers
# 95      Thunderstorm
# 96/99   Thunderstorm + hail
#
# Weather Icons / Nerd Fonts:
#
# e30d = day_sunny
# e32b = night_clear
# e302 = day_cloudy
# e32e = night_cloudy
# e312 = cloudy
# e313 = fog
# e31b = sprinkle
# e318 = rain
# e319 = showers
# e31a = snow
# e31c = storm_showers
# e31d = thunderstorm
#
# =====================================================

case "$CODE" in

    # -------------------------------------------------
    # Clear sky
    # -------------------------------------------------

    0)
        if [[ "$IS_DAY" == "1" ]]; then
            ICON=$'\ue30d'        # nf-weather-day_sunny
        else
            ICON=$'\ue32b'        # nf-weather-night_clear
        fi
        ;;

    # -------------------------------------------------
    # Mainly clear
    # -------------------------------------------------

    1)
        if [[ "$IS_DAY" == "1" ]]; then
            ICON=$'\ue30c'        # nf-weather-day_sunny_overcast
        else
            ICON=$'\ue37e'        # nf-weather-night_alt_cloudy
        fi
        ;;

    # -------------------------------------------------
    # Partly cloudy
    # -------------------------------------------------

    2)
        if [[ "$IS_DAY" == "1" ]]; then
            ICON=$'\ue302'        # nf-weather-day_cloudy
        else
            ICON=$'\ue32e'        # nf-weather-night_cloudy
        fi
        ;;

    # -------------------------------------------------
    # Overcast
    # -------------------------------------------------

    3)
        ICON=$'\ue312'            # nf-weather-cloudy
        ;;

    # -------------------------------------------------
    # Fog
    # -------------------------------------------------

    45|48)
        ICON=$'\ue313'            # nf-weather-fog
        ;;

    # -------------------------------------------------
    # Drizzle
    # -------------------------------------------------

    51|53|55)
        ICON=$'\ue31b'            # nf-weather-sprinkle
        ;;

    # -------------------------------------------------
    # Freezing drizzle
    # -------------------------------------------------

    56|57)
        ICON=$'\ue31b'            # nf-weather-sprinkle
        ;;

    # -------------------------------------------------
    # Rain
    # -------------------------------------------------

    61|63|65)
        ICON=$'\ue318'            # nf-weather-rain
        ;;

    # -------------------------------------------------
    # Freezing rain
    # -------------------------------------------------

    66|67)
        ICON=$'\ue318'            # nf-weather-rain
        ;;

    # -------------------------------------------------
    # Snow
    # -------------------------------------------------

    71|73|75|77)
        ICON=$'\ue31a'            # nf-weather-snow
        ;;

    # -------------------------------------------------
    # Rain showers
    # -------------------------------------------------

    80|81|82)
        ICON=$'\ue319'            # nf-weather-showers
        ;;

    # -------------------------------------------------
    # Snow showers
    # -------------------------------------------------

    85|86)
        ICON=$'\ue31a'            # nf-weather-snow
        ;;

    # -------------------------------------------------
    # Thunderstorm
    # -------------------------------------------------

    95)
        ICON=$'\ue31d'            # nf-weather-thunderstorm
        ;;

    # -------------------------------------------------
    # Thunderstorm + hail
    # -------------------------------------------------

    96|99)
        ICON=$'\ue31d'            # nf-weather-thunderstorm
        ;;

    # -------------------------------------------------
    # Unknown condition
    # -------------------------------------------------

    *)
        ICON=$'\ue312'            # nf-weather-cloudy
        ;;

esac

# =====================================================
# FORMAT TEMPERATURE
# =====================================================

TEMP_INT=$(printf "%.0f" "$TEMP")

# =====================================================
# OUTPUT
# =====================================================

echo "${ICON} ${TEMP_INT}°C"