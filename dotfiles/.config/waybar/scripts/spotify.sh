#!/bin/bash

escape_markup() {
    sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g'
}

metadata=$(playerctl --player=spotify metadata \
    --format '{{status}}|{{artist}}|{{title}}|{{mpris:artUrl}}|{{position}}|{{mpris:length}}' 2>/dev/null)

# Spotify not running
if [ -z "$metadata" ]; then
    echo '{"text":"","art":"","position":0,"length":0,"class":"custom-spotify"}'
    exit 0
fi

IFS='|' read -r status artist title art position length <<< "$metadata"

# Escape text for QML
artist=$(printf '%s' "$artist" | escape_markup)
title=$(printf '%s' "$title" | escape_markup)

# Playback icon
icon=""
[ "$status" = "Playing" ] && icon=""

# Safety fallbacks
position=${position:-0}
length=${length:-0}

# Convert microseconds -> seconds safely
position_sec=$(awk "BEGIN {printf \"%d\", $position / 1000000}")
length_sec=$(awk "BEGIN {printf \"%d\", $length / 1000000}")

# Output JSON
printf '{
    "text":"%s %s - %s",
    "art":"%s",
    "position":%s,
    "length":%s,
    "status":"%s",
    "class":"custom-spotify"
}\n' \
"$icon" \
"$artist" \
"$title" \
"$art" \
"$position_sec" \
"$length_sec" \
"$status"
