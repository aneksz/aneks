#!/bin/bash

LAST=""
START_TIME=$(date +%s)
FIRST_LAUNCH_FLAG="/tmp/.spotify_first_launch_done"

# Ensure clean workspace on boot
rm -f /tmp/spotify-*.jpg
rm -f "$FIRST_LAUNCH_FLAG"

playerctl --follow --player=spotify metadata \
  --format '{{status}}|{{artist}}|{{title}}|{{mpris:artUrl}}' |
while IFS='|' read -r status artist title art; do

    # 1. Block "Spotify Closing" empty pipe updates
    if [ -z "${status// }" ] && [ -z "${title// }" ] && [ -z "${artist// }" ]; then
        continue
    fi

    # 2. Skip Stopped/Paused system loopbacks securely
    [ "$status" = "Stopped" ] && continue
    [ -z "$title" ] && continue

    CURRENT="$artist - $title"
    NOW=$(date +%s)

    # Ignore replay triggers exactly at script startup
    if [ $((NOW - START_TIME)) -lt 3 ]; then
        if [ -n "$title" ]; then
            LAST="$CURRENT"
            touch "$FIRST_LAUNCH_FLAG"
        fi
        continue
    fi

    # 3. Block uninitialized layout states
    if [ -z "$CURRENT" ] || [ "$CURRENT" = " - " ]; then
        continue
    fi

    # 4. FIX: Block historical cache replay on the absolute first launch after a reboot
    if [ ! -f "$FIRST_LAUNCH_FLAG" ]; then
        LAST="$CURRENT"
        touch "$FIRST_LAUNCH_FLAG"
        continue
    fi

    [ "$CURRENT" = "$LAST" ] && continue
    LAST="$CURRENT"

    # Define unique asset path rules
    IMG="/tmp/spotify-$(date +%s).jpg"
    ICON_FLAG="spotify-client"

    # Album Art Extraction Pipeline
    if [ -n "$art" ]; then
        RAW_URL=$(echo "$art" | sed 's/open\.spotify\.com\/image/i.scdn.co\/image/')
        if curl -sL --max-time 3 "$RAW_URL" -o "$IMG"; then
            if [ -s "$IMG" ]; then
                ICON_FLAG="$IMG"
                sleep 0.05
            fi
        fi
    fi

    # Fire notification to Quickshell
    notify-send \
      --transient \
      -a "Spotify" \
      -i "$ICON_FLAG" \
      -h string:x-canonical-private-synchronous:spotify \
      "$title" \
      "$artist"

    # Clean up previous temporary album art assets cleanly in the background
    find /tmp -name "spotify-*.jpg" ! -name "$(basename "$IMG")" -delete 2>/dev/null &
done
