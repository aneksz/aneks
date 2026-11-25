#!/usr/bin/env bash
# Makes a small wallpaper thumbnail for each theme (for the theme switcher's cards)
# and prints one "name<TAB>thumbnail path" line per theme that has one.
# Thumbnails are only (re)made when missing or older than the wallpaper, so reruns are cheap.

themes="$HOME/.config/themes"
walls="$HOME/Pictures/Wallpapers/themes"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/theme-thumbs"
mkdir -p "$cache"

have_magick=0
command -v magick >/dev/null 2>&1 && have_magick=1

for dir in "$themes"/*/; do
    name=$(basename "$dir")
    toml="$dir/colors.toml"
    [ -f "$toml" ] || continue

    wall=$(sed -n 's/^wallpaper_dp1[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$toml" | head -n1)
    [ -n "$wall" ] || continue

    src="$walls/$name/$wall"
    [ -f "$src" ] || src="$dir/wallpapers/$wall"     # older per-theme layout
    out="$cache/$name.jpg"

    if [ -f "$src" ] && [ "$have_magick" = 1 ] && { [ ! -f "$out" ] || [ "$src" -nt "$out" ]; }; then
        # first frame only, cropped to 16:9 around the centre
        magick "${src}[0]" -resize 640x360^ -gravity center -extent 640x360 -quality 85 "$out" 2>/dev/null
    fi

    [ -f "$out" ] && printf '%s\t%s\n' "$name" "$out"
done
exit 0
