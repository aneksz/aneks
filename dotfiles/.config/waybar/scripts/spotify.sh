#!/bin/bash
# Waybar Spotify module

escape_markup() {
    echo "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

output_json() {
    local icon="$1"
    local artist="$2"
    local title="$3"
    echo "{\"text\": \"$icon $artist - $title\", \"class\": \"custom-spotify\"}"
}

player_status=$(playerctl --player=spotify status 2>/dev/null)

if [[ "$player_status" == "Playing" ]]; then
    artist=$(playerctl --player=spotify metadata artist)
    title=$(playerctl --player=spotify metadata title)
    artist=$(escape_markup "$artist")
    title=$(escape_markup "$title")
    output_json "" "$artist" "$title"

elif [[ "$player_status" == "Paused" ]]; then
    artist=$(playerctl --player=spotify metadata artist)
    title=$(playerctl --player=spotify metadata title)
    artist=$(escape_markup "$artist")
    title=$(escape_markup "$title")
    output_json "" "$artist" "$title"

else
    echo "{\"text\": \"\", \"class\": \"custom-spotify\"}"
fi
