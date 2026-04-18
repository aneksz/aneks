#!/usr/bin/env bash

THEME="tokyo-night"
THEME_DIR="$HOME/.config/themes/$THEME"
QUICKSHELL_DIR="$HOME/.config/quickshell"
# ------------------------
#  Btop
# ------------------------

sed -i "s/^color_theme *= *.*/color_theme = \"$THEME\"/" ~/.config/btop/btop.conf

# reload btop if running
if pgrep -x btop >/dev/null; then
  pkill -x -USR2 btop
fi

(sleep 0.6 && notify-send -a "theme-switcher" "" "<b>Theme Updated</b>\nApplied Theme: $THEME") &

# ------------------------
# Paths
# ------------------------
WAYBAR_DIR="$HOME/.config/waybar"
SWAYNC_DIR="$HOME/.config/swaync"
WLOGOUT_DIR="$HOME/.config/wlogout"
HYPR_DIR="$HOME/.config/hypr"

KITTY_COLORS="$HOME/.config/kitty/colors.conf"
GTK4_THEME_DIR="$HOME/.local/share/themes/Tokyonight-BL-MB-Dark/gtk-4.0"
GTK4_CONFIG="$HOME/.config/gtk-4.0"

# ------------------------
# Shared colors
# ------------------------
cp "$THEME_DIR/colors.css" "$WAYBAR_DIR/colors.css"
cp "$THEME_DIR/colors.css" "$SWAYNC_DIR/colors.css"
cp "$THEME_DIR/colors.css" "$WLOGOUT_DIR/colors.css"

# ------------------------
#  QShell
# ------------------------
if [ -f "$THEME_DIR/quickshell_theme.qml" ]; then
    cp "$THEME_DIR/quickshell_theme.qml" "$QUICKSHELL_DIR/Colors.qml"
fi

# ------------------------
# Bar reload (Smart Logic)
# ------------------------
if pgrep -x "waybar" >/dev/null; then
    killall -SIGUSR2 waybar
fi
# ------------------------
# Waybar reload
# ------------------------
#killall -SIGUSR2 waybar 2>/dev/null || waybar &

# ------------------------
# SwayNC reload
# ------------------------
swaync-client -rs

# ------------------------
# Wlogout icons
# ------------------------
rm -f "$WLOGOUT_DIR/icons/current"
ln -s "$WLOGOUT_DIR/icons/$THEME" "$WLOGOUT_DIR/icons/current"

# ------------------------
# Hyprland colors
# ------------------------
cp "$THEME_DIR/hypr.conf" "$HYPR_DIR/colors.conf"
hyprctl reload

# ------------------------
# Kitty
# ------------------------
if [ -f "$THEME_DIR/kitty/tokyo.colors.conf" ]; then
    cp "$THEME_DIR/kitty/tokyo.colors.conf" "$KITTY_COLORS"

    for SOCKET in ~/.config/kitty/kitty.sock-*; do
        if [ -S "$SOCKET" ]; then
            export KITTY_LISTEN_ON="unix:$SOCKET"
            kitty @ set-colors --all --config "$THEME_DIR/kitty/tokyo.colors.conf"
        fi
    done
fi

# ------------------------
# GTK
# ------------------------
gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-BL-MB-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Tokyonight-Dark"
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
# Wallpaper
# ------------------------

awww img ~/.config/themes/tokyo-night/wallpapers/tokyo2.png --outputs DP-1 --transition-type any
awww img ~/.config/themes/tokyo-night/wallpapers/tokyo1.jpg --outputs DP-3 --transition-type any

# ------------------------
# Rofi
# ------------------------
cp "$THEME_DIR/colors.rasi" ~/.config/rofi/launchers/type-2/shared

# ------------------------
# VSCodium
# ------------------------
VSCODE_SETTINGS="$HOME/.config/VSCodium/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    sed -i 's/"workbench.colorTheme":[[:space:]]*"[^"]*"/"workbench.colorTheme": "Tokyo Night"/' "$VSCODE_SETTINGS"
fi

# ------------------------
# Spotify
# ------------------------

spicetify config current_theme Sleek
spicetify config color_scheme TokyoNight

if pgrep -x spotify >/dev/null; then
  (spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q") &
else 
  spicetify apply -n >/dev/null 2>&1
fi

# ------------------------
# Hyprlock
# ------------------------
ln -sf "$HYPR_DIR/background/tokyo2.png" "$HYPR_DIR/background/current.png"
pkill hyprlock 2>/dev/null

# ------------------------
# Save theme
# ------------------------
echo "$THEME" > "$HOME/.config/.current_theme"



