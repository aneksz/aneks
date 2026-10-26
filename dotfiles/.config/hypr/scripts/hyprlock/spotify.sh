
#!/usr/bin/env bash

PLAYER="spotify"
MAX_LENGTH=40
MODE="$1"   # <-- new (info / prev / playpause / next)

# Check if player exists (handles weird instance names too)
if ! playerctl --player="$PLAYER" status 2>/dev/null | grep -q Playing; then
    exit 0
fi

STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)

ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)

# -------- CONTROLS MODE --------
case "$MODE" in
    prev)
        echo "󰒮"
        exit 0
        ;;
    playpause)
        if [ "$STATUS" = "Playing" ]; then
            echo "󰏤"
        else
            echo "󰐊"
        fi
        exit 0
        ;;
    next)
        echo "󰒭"
        exit 0
        ;;
esac

# -------- INFO MODE (default) --------

# Fallback if metadata missing
[ -z "$TITLE" ] && exit 0

SONG="$ARTIST - $TITLE"

# Truncate safely
if [ "${#SONG}" -gt "$MAX_LENGTH" ]; then
    SONG="${SONG:0:$((MAX_LENGTH-1))}…"
fi

case "$STATUS" in
    Playing)
        echo " $SONG"
        ;;
    Paused)
        echo "  $SONG"
        ;;
    *)
        echo ""
        ;;
esac