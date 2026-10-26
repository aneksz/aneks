#!/bin/bash

# 1. Save the current window address
PREV_ADDR=$(hyprctl activewindow -j | jq -r '.address')

# 2. Disable animations and cursor warping temporarily
hyprctl keyword animations:enabled 0
hyprctl keyword cursor:no_warps 1

# 3. Focus Spotify instantly (no sliding)
hyprctl dispatch focuswindow class:spotify

# 4. Small delay for XWayland to catch up (even without animations)
sleep 0.1

# 5. Send the reload (use wtype if sendshortcut still fails)
hyprctl dispatch sendshortcut CTRL_SHIFT, R, class:spotify
# OR: wtype -M ctrl -M shift r

# 6. Jump back immediately
hyprctl dispatch focuswindow address:$PREV_ADDR

# 7. Re-enable animations and warping
hyprctl keyword animations:enabled 1
hyprctl keyword cursor:no_warps 0
