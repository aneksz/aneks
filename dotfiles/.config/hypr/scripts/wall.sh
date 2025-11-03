#!/usr/bin/env bash

# Wallpaper directories
WALL_4K="$HOME/Pictures/Wallpapers/4K"
WALL_HD="$HOME/Pictures/Wallpapers/HD"

# Cache folder for last-used wallpapers
STATE_DIR="$HOME/.cache/swww_wallpapers"
mkdir -p "$STATE_DIR"

# Start fresh swww daemon
if pgrep -x swww-daemon >/dev/null; then
    pkill swww-daemon
fi
swww-daemon &
sleep 1  # allow daemon to start

# Detect monitors
MONITORS=$(swww query | grep ':' | awk -F ':' '{print $2}' | awk -F ',' '{print $1}' | xargs)
echo "Detected monitors: $MONITORS"

# Define valid transition effects for your swww version
TRANSITIONS=("fade" "left" "right" "top" "bottom" "wipe" "grow" "center" "outer" "random" "wave")

# Function to pick a wallpaper for a folder avoiding last-used
pick_wallpaper() {
    local folder=$1
    local last=$2
    find "$folder" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) ! -path "$last" | shuf -n 1
}

# Preload 4K monitor first (DP-1)
if [[ $MONITORS == *DP-1* ]]; then
    MON="DP-1"
    LAST_WALL=$(cat "$STATE_DIR/$MON" 2>/dev/null || echo "")
    WALLPAPER=$(pick_wallpaper "$WALL_4K" "$LAST_WALL")
    TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

    if [[ -f "$WALLPAPER" ]]; then
        echo "Preloading $MON with $WALLPAPER using $TRANSITION"
        swww img "$WALLPAPER" --outputs "$MON" --transition-type "$TRANSITION" --transition-duration 1
        echo "$WALLPAPER" > "$STATE_DIR/$MON"
    fi
fi

# Short cinematic delay before applying HD monitor wallpaper
DELAY=0.5  # seconds
sleep $DELAY

# Apply wallpapers to remaining monitors
for MON in $MONITORS; do
    MON=$(echo "$MON" | xargs)  # trim spaces
    [[ "$MON" == "DP-1" ]] && continue  # skip already applied

    case "$MON" in
        DP-3)
            FOLDER="$WALL_HD"
            ;;
        *)
            echo "No folder configured for monitor '$MON'"
            continue
            ;;
    esac

    LAST_WALL=$(cat "$STATE_DIR/$MON" 2>/dev/null || echo "")
    WALLPAPER=$(pick_wallpaper "$FOLDER" "$LAST_WALL")
    TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

    if [[ -f "$WALLPAPER" ]]; then
        echo "Applying wallpaper to $MON: $WALLPAPER using $TRANSITION"
        swww img "$WALLPAPER" --outputs "$MON" --transition-type "$TRANSITION" --transition-duration 1
        echo "$WALLPAPER" > "$STATE_DIR/$MON"
    fi
done
