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

if [ -z "$metadata" ]; then
    echo '{"text":"","icon":"","art":"","position":0,"length":0,"class":"custom-spotify"}'
    exit 0
fi

IFS='|' read -r status artist title art position length <<< "$metadata"

artist=$(printf '%s' "$artist" | escape_markup)
title=$(printf '%s' "$title" | escape_markup)

icon="󰏥"
[ "$status" = "Playing" ] && icon=""

position=${position:-0}
length=${length:-0}

position_sec=$(awk "BEGIN {printf \"%d\", $position / 1000000}")
length_sec=$(awk "BEGIN {printf \"%d\", $length / 1000000}")

printf '{
    "text":"%s - %s",
    "icon":"%s",
    "art":"%s",
    "position":%s,
    "length":%s,
    "status":"%s",
    "class":"custom-spotify"
}\n' \
"$artist" \
"$title" \
"$icon" \
"$art" \
"$position_sec" \
"$length_sec" \
"$status"
