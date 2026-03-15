#!/usr/bin/env bash

# Only check Spotify
PLAYER="spotify"
MAX_LENGTH=40  # Maximum number of characters to display

# Function to truncate text
truncate() {
    local text="$1"
    local max="$2"
    if [ "${#text}" -gt "$max" ]; then
        echo "${text:0:max-1}…"
    else
        echo "$text"
    fi
}

# Check if Spotify is running
if ! playerctl --player=$PLAYER status &>/dev/null; then
    echo ""
    exit 0
fi

# Get playback status
STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)

# Get current song info (artist - title)
SONG=$(playerctl --player=$PLAYER metadata --format '{{artist}} - {{title}}' 2>/dev/null)
SONG=$(truncate "$SONG" "$MAX_LENGTH")

# Display formatted text
case "$STATUS" in
    "Playing")
        echo " $SONG"
        ;;
    "Paused")
        echo "  $SONG"
        ;;
    *)
        echo ""
        ;;
esac
