#!/usr/bin/env bash
# Picks a random image from the current theme's 4K wallpaper folder and
# splits it across both monitors:
#   DP-1: 3840x2160 physical, scale 1.5 -> logical 2560x1440, at (1080,0)
#   DP-3: 1920x1080 physical, rotated 270 (transform=3) -> logical 1080x1920, at (0,0)
#
# Combined logical canvas: 3640 wide x 1920 tall.
#   DP-3 fills the full-height left column: (0,0) to (1080,1920)
#   DP-1 fills only the TOP portion of the remaining width: (1080,0) to (3640,1440)
# The bottom 480px on the right is never shown on either monitor.
#
# Requires: imagemagick (pacman -S imagemagick)
#
# Usage:
#   ./wall.sh            - current theme
#   ./wall.sh <theme>    - forced theme

THEME="${1:-$(cat "$HOME/.config/.current_theme" 2>/dev/null)}"

if [[ -z "$THEME" ]]; then
    echo "No theme specified and no current theme found. Usage: wall.sh [theme-name]"
    exit 1
fi

WALL_4K="$HOME/Pictures/Wallpapers/4K/$THEME/span"
STATE_DIR="$HOME/.cache/awww_wallpapers"
mkdir -p "$STATE_DIR"

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
DP1_LOGICAL_H=1600
DP1_PHYSICAL_W=3840
DP1_PHYSICAL_H=2160

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

MAGICK=$(command -v magick || command -v convert)
if [[ -z "$MAGICK" ]]; then
    echo "imagemagick not found - install it first (pacman -S imagemagick)"
    exit 1
fi

# Resize+crop the source to exactly fill the combined canvas.
# -filter Triangle trades a small amount of sharpness for speed on the
# resample step - not noticeable on a wallpaper. JPEG output (vs PNG)
# skips PNG's heavier lossless compression, which was most of the delay.
CANVAS="$TMP_DIR/canvas.jpg"
"$MAGICK" "$SOURCE_IMG" -filter Triangle -resize "${CANVAS_W}x${CANVAS_H}^" -gravity center -extent "${CANVAS_W}x${CANVAS_H}" -quality 90 "$CANVAS"

# DP-3 slice: left column, full height
DP3_CROP="$TMP_DIR/dp3_crop.jpg"
"$MAGICK" "$CANVAS" -crop "${DP3_W}x${DP3_H}+0+0" +repage -quality 90 "$DP3_CROP"
# If this displays sideways on the real monitor, uncomment whichever fixes it:
# "$MAGICK" "$DP3_CROP" -rotate 90 "$DP3_CROP"
# "$MAGICK" "$DP3_CROP" -rotate 270 "$DP3_CROP"

OUT_DP3="$STATE_DIR/span_${THEME}_dp3.jpg"
cp "$DP3_CROP" "$OUT_DP3"

# DP-1 slice: top portion of the remaining width, upscaled to native res
DP1_CROP="$TMP_DIR/dp1_crop.jpg"
"$MAGICK" "$CANVAS" -crop "${DP1_LOGICAL_W}x${DP1_LOGICAL_H}+${DP3_W}+0" +repage "$DP1_CROP"
OUT_DP1="$STATE_DIR/span_${THEME}_dp1.jpg"
"$MAGICK" "$DP1_CROP" -filter Triangle -resize "${DP1_PHYSICAL_W}x${DP1_PHYSICAL_H}!" -quality 90 "$OUT_DP1"

echo "Generated:"
echo "  DP-3: $OUT_DP3"
echo "  DP-1: $OUT_DP1"

if pgrep -x awww-daemon >/dev/null; then
    pkill awww-daemon
fi
awww-daemon &
sleep 1

awww img "$OUT_DP1" --outputs "DP-1" --transition-type any --transition-duration 1 --transition-fps="60"
awww img "$OUT_DP3" --outputs "DP-3" --transition-type any --transition-duration 1 --transition-fps="60"