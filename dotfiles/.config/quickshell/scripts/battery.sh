#!/usr/bin/env bash
# battery-status.sh — reports MOUSE:pct%|state|serial|path|timeleft
#                  and KEYBOARD:pct%|state|serial|path|timeleft
#
# Usage: battery-status.sh <mouse-codename> <keyboard-codename>
#   e.g. battery-status.sh "MX Master 2S" "MX Keys"
#
# Percentage/state come from `solaar show`: the kernel's hidpp_battery
# driver (and therefore UPower) only exposes a bucketed CAPACITY_LEVEL
# for these devices, but Solaar reads the same BATTERY STATUS {1000}
# HID++ feature more completely and gets the real mileage percentage
# ("Battery: 50%, BatteryStatus.DISCHARGING, next level 20%.").
#
# NOTE: devices on the older BATTERY_STATUS {1000} feature (both the
# MX Master 2S and MX Keys) only report a handful of discrete levels
# (e.g. 90/50/20/5), not a smoothly changing percentage - the value can
# sit unchanged for weeks at a time. A minute-by-minute drain-rate
# estimate structurally can't be computed from data like that, so for
# these devices we surface Solaar's own "next level" hint directly
# instead of trying to guess a time-remaining figure. The drain-rate
# estimator below is kept as a fallback for any device that DOES report
# a real granular percentage (no "next level" text in its Battery line).
#
# UPower also doesn't report "time to empty" for HID++ peripherals (no
# energy-rate data), so for granular devices this script tracks
# percentage over time itself and estimates days/hours remaining from
# the observed drain rate.
MOUSE_CODENAME="${1:-MX Master 2S}"
KEYBOARD_CODENAME="${2:-MX Keys}"

CACHE_DIR="$HOME/.cache/quickshell-battery"
mkdir -p "$CACHE_DIR"
MIN_WINDOW=3600  # seconds between rate recalculations — avoids noisy estimates

# Runs `solaar show <codename>` for one device (the detailed, per-device
# form — not bare `solaar show`, which prints a compact summary that
# doesn't include the "Battery: N%, BatteryStatus.X, ..." line we need).
# Solaar prints a harmless Wayland/modifier-key warning to stderr on
# every call — silenced since it isn't relevant to battery data.
solaar_device_output() {
    codename="$1"
    solaar show "$codename" 2>/dev/null
}

estimate_time_left() {
    tag="$1"; pct="$2"; state="$3"
    cache="$CACHE_DIR/$tag.state"
    now=$(date +%s)

    if echo "$state" | grep -qi 'charging' && ! echo "$state" | grep -qi 'discharging'; then
        # reset baseline while charging so the estimate is fresh once discharge resumes
        echo "$now|$pct" > "$cache"
        echo "Charging..."
        return
    fi

    if [ ! -f "$cache" ]; then
        echo "$now|$pct" > "$cache"
        echo "Learning..."
        return
    fi

    base_epoch=$(cut -d'|' -f1 "$cache")
    base_pct=$(cut -d'|' -f2 "$cache")
    elapsed=$((now - base_epoch))

    if [ "$elapsed" -lt "$MIN_WINDOW" ]; then
        echo "Learning..."
        return
    fi

    dropped=$(awk -v a="$base_pct" -v b="$pct" 'BEGIN{printf "%.4f", a-b}')
    is_positive=$(awk -v d="$dropped" 'BEGIN{print (d>0)?"1":"0"}')

    if [ "$is_positive" != "1" ]; then
        # no measurable drop yet (idle/plateau) — slide the window forward, keep learning
        echo "$now|$pct" > "$cache"
        echo "Learning..."
        return
    fi

    rate=$(awk -v d="$dropped" -v e="$elapsed" 'BEGIN{printf "%.8f", d/e}')
    seconds_left=$(awk -v p="$pct" -v r="$rate" 'BEGIN{printf "%.0f", p/r}')
    days=$((seconds_left / 86400))
    hours=$(((seconds_left % 86400) / 3600))

    echo "$now|$pct" > "$cache"
    echo "~${days}d ${hours}h"
}

emit() {
    codename="$1"; tag="$2"
    output=$(solaar_device_output "$codename")
    line=$(echo "$output" | grep -E '^ *Battery:' | head -n1)

    if [ -n "$line" ]; then
        # Line looks like either:
        #   Battery: 50%, BatteryStatus.DISCHARGING, next level 20%.   (bucketed device)
        #   Battery: 73%, BatteryStatus.DISCHARGING.                  (granular device)
        pct=$(echo "$line" | grep -oE '[0-9]+%' | head -n1 | tr -d '%')
        st=$(echo "$line" | grep -oE 'BatteryStatus\.[A-Z_]+' | cut -d. -f2)
        sn=$(echo "$output" | grep -E 'Serial number:' | head -n1 | awk '{print $NF}')
        next_level=$(echo "$line" | grep -oE 'next level [0-9]+%' | grep -oE '[0-9]+' | head -n1)
        pt="$tag"
        [ -z "$pct" ] && pct="0"
        [ -z "$st" ] && st="UNKNOWN"
        [ -z "$sn" ] && sn="Unknown"

        if [ -n "$next_level" ]; then
            # Bucketed device (BATTERY_STATUS {1000}) - the value can sit unchanged
            # for weeks, so a drain-rate estimate can never resolve. Surface the
            # threshold Solaar itself already reports instead of guessing.
            if echo "$st" | grep -qi 'charging' && ! echo "$st" | grep -qi 'discharging'; then
                tte="Charging..."
            else
                tte="Next: ${next_level}%"
            fi
        else
            tte=$(estimate_time_left "$tag" "$pct" "$st")
        fi

        echo "$pct%|$st|$sn|$pt|$tte"
    else
        echo "0%|OFFLINE|Unknown|unknown|--"
    fi
}

echo "MOUSE:$(emit "$MOUSE_CODENAME" mouse)"
echo "KEYBOARD:$(emit "$KEYBOARD_CODENAME" keyboard)"