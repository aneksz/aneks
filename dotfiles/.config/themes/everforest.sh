#!/usr/bin/env bash

# ------------------------
# Paths
# ------------------------
THEME_DIR="$HOME/.config/themes/everforest"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
KITTY_COLORS="$HOME/.config/kitty/colors.conf"
GTK4_THEME_DIR="$HOME/.local/share/themes/Everforest-BL-MB-Dark/gtk-4.0"
GTK4_CONFIG="$HOME/.config/gtk-4.0"
WAYBAR_CONF="$THEME_DIR/waybar/style.css"

# ------------------------
# Apply Waybar
# ------------------------
if [ -f "$WAYBAR_CONF" ]; then
    cp "$WAYBAR_CONF" "$HOME/.config/waybar/style.css"
    pkill waybar
    sleep 1
    hyprctl dispatch exec waybar
fi

# ------------------------
# Apply Kitty colors persistently
# ------------------------
if [ -f "$THEME_DIR/kitty/everforest.colors.conf" ]; then
    cp "$THEME_DIR/kitty/everforest.colors.conf" "$KITTY_COLORS"

    # Update all running kitty windows
    for SOCKET in ~/.config/kitty/kitty.sock-*; do
        if [ -S "$SOCKET" ]; then
            export KITTY_LISTEN_ON="unix:$SOCKET"
            kitty @ set-colors --all --config "$THEME_DIR/kitty/everforest.colors.conf"
        fi
    done
fi

# ------------------------
# GTK3 / legacy apps
# ------------------------
gsettings set org.gnome.desktop.interface gtk-theme "Everforest-BL-MB-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Everforest-Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# -----------------------
# GTK4 / libadwaita apps
# -----------------------
if [ -d "$GTK4_THEME_DIR" ]; then
    rm -rf "$GTK4_CONFIG/assets" "$GTK4_CONFIG/gtk.css" "$GTK4_CONFIG/gtk-dark.css" 2>/dev/null
    ln -s "$GTK4_THEME_DIR/assets" "$GTK4_CONFIG/assets"
    ln -s "$GTK4_THEME_DIR/gtk.css" "$GTK4_CONFIG/gtk.css"
    ln -s "$GTK4_THEME_DIR/gtk-dark.css" "$GTK4_CONFIG/gtk-dark.css"
fi

# Reload xsettingsd for GTK3/X11 apps
killall xsettingsd 2>/dev/null
xsettingsd &

killall nautilus

# ------------------------
# Wallpaper Set
# ------------------------

swww img ~/.config/themes/everforest/wallpapers/forest1.png --outputs DP-1 --transition-type fade
swww img ~/.config/themes/everforest/wallpapers/forest2.png --outputs DP-3 --transition-type fade

# ------------------------
#  Rofi Theme
# ------------------------

cp ~/.config/themes/everforest/colors.rasi ~/.config/rofi/launchers/type-2/shared

# ------------------------
# VSCodium Theme
# ------------------------

VSCODE_SETTINGS="$HOME/.config/VSCodium/User/settings.json"

if [ -f "$VSCODE_SETTINGS" ]; then
    sed -i 's/"workbench.colorTheme":[[:space:]]*"[^"]*"/"workbench.colorTheme": "Everforest Night Hard"/' "$VSCODE_SETTINGS"
fi

# ------------------------
# Spotify Theme
# ------------------------

spicetify config current_theme Everforest
spicetify apply -n

# ------------------------
# Save current theme
# ------------------------
echo "everforest" > "$HOME/.config/.current_theme"


# ------------------------
#  Hyprlock Theme
# ------------------------

cp "$HOME/.config/themes/everforest/everforest.conf" "$HOME/.config/hypr/colors.conf"

ln -sf "$HOME/.config/hypr/background/forest1.png" \
       "$HOME/.config/hypr/background/current.png"

pkill hyprlock 2>/dev/null

# ------------------------
# Hyprland Colours
# ------------------------

cp "$HOME/.config/themes/everforest/everforest.conf" \
   "$HOME/.config/hypr/colors.conf"


# ------------------------
# NZXT Colours
# ------------------------

liquidctl set ring color fixed dbbc7f
liquidctl set logo color fixed e69875y

