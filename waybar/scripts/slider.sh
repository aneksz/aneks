#!/usr/bin/env bash
export LANG=en_US.UTF-8

VOLUME=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)

if [ "$MUTED" = "true" ]; then
    ICON="󰝟"
else
    if [ "$VOLUME" -le 30 ]; then
        ICON=""
    elif [ "$VOLUME" -le 70 ]; then
        ICON=""
    else
        ICON=""
    fi
fi

echo "$ICON $VOLUME%"
