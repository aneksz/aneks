#!/usr/bin/env bash


THEME="material-you"
WALL_DIR="$HOME/.config/themes/material-you/wallpapers"
LAST_WALL="$HOME/.config/.last_wallpaper"
WLOGOUT_DIR="$HOME/.config/wlogout"

GTK4_THEME_DIR="$HOME/.local/share/themes/Materia-dark/gtk-4.0"
GTK4_CONFIG="$HOME/.config/gtk-4.0"

# reload btop if running
if pgrep -x btop >/dev/null; then
  pkill -USR2 btop
fi

# ------------------------
# Pick wallpaper
# ------------------------
WALL=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) \
  ! -samefile "$LAST_WALL" 2>/dev/null | shuf -n 1)

echo "$WALL" > "$LAST_WALL"

# ------------------------
# Set wallpaper
# ------------------------
awww img "$WALL" --transition-type any

# ------------------------
# Hyprlock
# ------------------------
HYPR_BG_DIR="$HOME/.config/hypr/background"
mkdir -p "$HYPR_BG_DIR"
ln -sf "$WALL" "$HYPR_BG_DIR/current.png"
pkill hyprlock 2>/dev/null

# ------------------------
# Matugen
# ------------------------
CONFIG="$HOME/.config/matugen/config.toml"
sed -i "s|^image = .*|image = \"$WALL\"|" "$CONFIG"

matugen image --prefer saturation "$WALL"

# ------------------------
# Wlogout (handles its own wait)
# ------------------------
~/.config/matugen/scripts/wlogout.sh

# ensure correct theme LAST
ln -sfn "$WLOGOUT_DIR/icons/$THEME" "$WLOGOUT_DIR/icons/current"

# ------------------------
# Reload stuff
# ------------------------
killall -SIGUSR2 waybar 2>/dev/null || waybar &

swaync-client -rs
hyprctl reload

sed -i 's/^color_theme *= *.*/color_theme = "matugen"/' ~/.config/btop/btop.conf

(sleep 0.6 && notify-send -a "theme-switcher" "" "<b>Theme Updated</b>\nApplied Theme: $THEME") &

# ------------------------
# Kitty reload (Matugen colors)
# ------------------------
KITTY_COLORS="$HOME/.config/kitty/colors.conf"

if [ -f "$KITTY_COLORS" ]; then
    for SOCKET in ~/.config/kitty/kitty.sock-*; do
        if [ -S "$SOCKET" ] && kitty @ --to "unix:$SOCKET" ls >/dev/null 2>&1; then
            kitty @ --to "unix:$SOCKET" set-colors --all --config "$KITTY_COLORS" 2>/dev/null
        fi
    done
fi

# ------------------------
# GTK
# ------------------------
gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark"
gsettings set org.gnome.desktop.interface icon-theme "Blueberry-Numix-2021"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# ------------------------
# GTK4 / libadwaita
# ------------------------
if [ -d "$GTK4_THEME_DIR" ]; then
    rm -rf "$GTK4_CONFIG/assets" "$GTK4_CONFIG/gtk.css" "$GTK4_CONFIG/gtk-dark.css" 2>/dev/null
    ln -s "$GTK4_THEME_DIR/assets" "$GTK4_CONFIG/assets"
    ln -s "$GTK4_THEME_DIR/gtk.css" "$GTK4_CONFIG/gtk.css"
    ln -s "$GTK4_THEME_DIR/gtk-dark.css" "$GTK4_CONFIG/gtk-dark.css"
fi

killall xsettingsd 2>/dev/null
xsettingsd &

killall nautilus 2>/dev/null

# ------------------------
# Spotify (FIXED - no hang)
# ------------------------
spicetify config current_theme Sleek >/dev/null 2>&1
spicetify config color_scheme "" >/dev/null 2>&1

spicetify apply -n >/dev/null 2>&1

# ------------------------
# Save theme
# ------------------------
echo "$THEME" > "$HOME/.config/.current_theme"
