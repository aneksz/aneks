#!/usr/bin/env bash
# Splits a single source image across two monitors of different size/orientation:
#   DP-1: 3840x2160 physical, scale 1.5 -> logical 2560x1440, positioned at (1080,0)
#   DP-3: 1920x1080 physical, rotated 270 (transform=3) -> logical 1080x1920, at (0,0)
#
# Combined logical canvas: 3640 wide x 1920 tall.
#   DP-3 fills the full-height left column: (0,0) to (1080,1920)
#   DP-1 fills only the TOP portion of the remaining width: (1080,0) to (3640,1440)
# The bottom 480px on the right is never shown on either monitor - a real gap,
# not a bug. Pick source images where nothing important sits there.
#
# Requires: imagemagick (the `magick` or `convert` command)
#
# Usage: wall-span.sh <theme-name> <source-image>

set -euo pipefail

THEME="${1:-$(cat "$HOME/.config/.current_theme" 2>/dev/null)}"

if [[ -z "$THEME" ]]; then
    echo "No theme specified and no current theme found. Usage: wall-span.sh <theme-name>"
    exit 1
fi

WALL_4K="$HOME/Pictures/Wallpapers/4K/$THEME"

if [[ ! -d "$WALL_4K" ]]; then
    echo "No 4K wallpaper folder for theme '$THEME' at $WALL_4K"
    exit 1
fi

SOURCE_IMG=$(find "$WALL_4K" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [[ -z "$SOURCE_IMG" ]]; then
    echo "No image files found in $WALL_4K"
    exit 1
fi

echo "Using source image: $SOURCE_IMG"

CANVAS_W=3640
CANVAS_H=1920

DP3_W=1080
DP3_H=1920

DP1_LOGICAL_W=2560
DP1_LOGICAL_H=1440
DP1_PHYSICAL_W=3840
DP1_PHYSICAL_H=2160

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

MAGICK=$(command -v magick || command -v convert)
if [[ -z "$MAGICK" ]]; then
    echo "imagemagick not found - install it first (pacman -S imagemagick)"
    exit 1
fi

# Resize+crop the source to exactly fill the combined canvas (crops any excess
# rather than distorting aspect ratio - same behavior as most wallpaper tools).
CANVAS="$TMP_DIR/canvas.png"
"$MAGICK" "$SOURCE_IMG" -resize "${CANVAS_W}x${CANVAS_H}^" -gravity center -extent "${CANVAS_W}x${CANVAS_H}" "$CANVAS"

# --- DP-3 slice: left column, full height ---
DP3_CROP="$TMP_DIR/dp3_crop.png"
"$MAGICK" "$CANVAS" -crop "${DP3_W}x${DP3_H}+0+0" +repage "$DP3_CROP"
# Left as-is (portrait) for now - TEST on the real monitor before trusting this.
# If it displays sideways, awww does not auto-rotate for the output's transform;
# uncomment whichever rotation actually corrects it:
# "$MAGICK" "$DP3_CROP" -rotate 90 "$DP3_CROP"
# "$MAGICK" "$DP3_CROP" -rotate 270 "$DP3_CROP"

OUT_DP3="$HOME/.cache/awww_wallpapers/span_${THEME}_dp3.png"
cp "$DP3_CROP" "$OUT_DP3"

# --- DP-1 slice: top portion of the remaining width, upscaled to native res ---
DP1_CROP="$TMP_DIR/dp1_crop.png"
"$MAGICK" "$CANVAS" -crop "${DP1_LOGICAL_W}x${DP1_LOGICAL_H}+${DP3_W}+0" +repage "$DP1_CROP"
# Upscale the logical-size crop up to DP-1's actual native pixel resolution
# (1.5x, matching its scale factor) so the wallpaper isn't rendered soft.
OUT_DP1="$HOME/.cache/awww_wallpapers/span_${THEME}_dp1.png"
"$MAGICK" "$DP1_CROP" -resize "${DP1_PHYSICAL_W}x${DP1_PHYSICAL_H}!" "$OUT_DP1"

echo "Generated:"
echo "  DP-3: $OUT_DP3"
echo "  DP-1: $OUT_DP1"

if pgrep -x awww-daemon >/dev/null; then
    pkill awww-daemon
fi
awww-daemon &
sleep 1

awww img "$OUT_DP1" --outputs "DP-1" --transition-type fade
awww img "$OUT_DP3" --outputs "DP-3" --transition-type fade
