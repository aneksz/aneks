#!/bin/bash

USER_NAME=$(whoami | tr '[:upper:]' '[:lower:]')
HOST_NAME=$(hostname)
ICON_USER=""
ICON_CLOCK=""
ICON_WINDOW_DEFAULT="󱂬"

# -------------------------
# Helper functions
# -------------------------

escape_markup() {
    echo "$1" | sed -e 's/&/\&amp;/g' \
                     -e 's/</\&lt;/g' \
                     -e 's/>/\&gt;/g'
}

truncate_title() {
    local text="$1"
    local max_len=30
    if [ ${#text} -gt $max_len ]; then
        text="${text:0:$max_len}…"
    fi
    echo "$text"
}

get_icon_for_app() {
    case "$1" in
        "brave-browser") echo "" ;;
        "kitty"|"Alacritty") echo "" ;;
        "org.gnome.Nautilus") echo "" ;;
        "steam") echo "" ;;
        "spotify") echo "" ;;
        "thunderbird") echo "" ;;
        "discord") echo "" ;;
        "org.qbittorrent.qBittorrent") echo "" ;;
        *"whatsapp.com"*) echo "󰖣" ;;  # WhatsApp icon
        *"music.apple.com"*) echo "󰝚" ;; # Apple Music icon
        *) echo "$ICON_WINDOW_DEFAULT" ;;
    esac
}

get_friendly_name() {
    local class="$1"
    local title="$2"

    # WhatsApp web
    if [[ "$title" == *"WhatsApp"* ]] || [[ "$title" == *"web.whatsapp.com"* ]]; then
        echo "WhatsApp"
    # Apple Music web
    elif [[ "$title" == *"Apple Music"* ]] || [[ "$title" == *"Apple Music - Web Player"* ]] || [[ "$class" == *"music.apple.com"* ]]; then
        echo "Apple Music"
    else
        echo "$title"
    fi
}

# -------------------------
# Uptime
# -------------------------
UPTIME_RAW=$(uptime -p 2>/dev/null)
UPTIME=$(echo "$UPTIME_RAW" | sed -e 's/^up //' -e 's/ hours\?/h/' -e 's/ minutes\?/m/')
UPTIME=$(escape_markup "$UPTIME")

# -------------------------
# Active window
# -------------------------
ACTIVE_JSON=$(hyprctl activewindow -j 2>/dev/null)
APP_CLASS=$(echo "$ACTIVE_JSON" | jq -r '.class // empty')
ACTIVE_WIN=$(echo "$ACTIVE_JSON" | jq -r '.title // empty')

if [ -z "$ACTIVE_WIN" ]; then
    APP_CLASS="empty"
    ACTIVE_WIN=""
fi

# -------------------------
# Apply friendly names
# -------------------------
ACTIVE_WIN=$(get_friendly_name "$APP_CLASS" "$ACTIVE_WIN")

# -------------------------
# Build display
# -------------------------
ICON_WINDOW=$(get_icon_for_app "$APP_CLASS")
TRUNC_TITLE=$(truncate_title "$ACTIVE_WIN")
SAFE_TITLE=$(escape_markup "$TRUNC_TITLE")

TEXT="${ICON_USER} ${USER_NAME}@${HOST_NAME} ${ICON_CLOCK} ${UPTIME} ${ICON_WINDOW}"
if [ -n "$TRUNC_TITLE" ]; then
    TEXT+=" ${SAFE_TITLE}"
fi

# Output JSON
printf '{"text":"%s"}\n' "$TEXT"
