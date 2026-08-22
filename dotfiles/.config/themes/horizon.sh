#!/usr/bin/env bash

THEME="horizon"
THEME_DIR="$HOME/.config/themes/$THEME"
QUICKSHELL_DIR="$HOME/.config/quickshell"

(sleep 0.6 && notify-send "Theme Updated" "Applied Theme: $THEME") &&

# ------------------------
#  Btop
# ------------------------

sed -i "s/^color_theme *= *.*/color_theme = \"$THEME\"/" ~/.config/btop/btop.conf

# reload btop if running
if pgrep -x btop >/dev/null; then
  pkill -x -USR2 btop
fi

# ------------------------
# P10k prompt
# ------------------------

cp "$THEME_DIR/${THEME}.p10k.zsh" "$HOME/.p10k.zsh"



# ------------------------
# Paths
# ------------------------
WAYBAR_DIR="$HOME/.config/waybar"
WLOGOUT_DIR="$HOME/.config/wlogout"
HYPR_DIR="$HOME/.config/hypr"


KITTY_COLORS="$HOME/.config/kitty/colors.conf"
GTK4_THEME_DIR="$HOME/.local/share/themes/Material-BL-MB-Dark-Darker/gtk-4.0"
GTK4_CONFIG="$HOME/.config/gtk-4.0"

# ------------------------
# Shared colors
# ------------------------
cp "$THEME_DIR/colors.css" "$WAYBAR_DIR/colors.css"
cp "$THEME_DIR/colors.css" "$WLOGOUT_DIR/colors.css"

# ------------------------
#  QShell - Main Bar
# ------------------------
if [ -f "$THEME_DIR/quickshell_theme.qml" ]; then
    cp "$THEME_DIR/quickshell_theme.qml" "$QUICKSHELL_DIR/Colors.qml"
fi

# ------------------------
#  QShell - Bar 1
# ------------------------
if [ -f "$THEME_DIR/quickshell_theme.qml" ]; then
    cp "$THEME_DIR/quickshell_theme.qml" "$QUICKSHELL_DIR/bar1/Colors.qml"
fi

# ------------------------
#  QShell - Bar 2
# ------------------------
if [ -f "$THEME_DIR/quickshell_theme.qml" ]; then
    cp "$THEME_DIR/quickshell_theme.qml" "$QUICKSHELL_DIR/bar2/Colors.qml"
fi

# ------------------------
# qBittorrent
# ------------------------
QBIT_CONF="$HOME/.config/qBittorrent/qBittorrent.conf"
QBIT_THEME="/home/igor/.config/themes/${THEME}/qbittorrent/${THEME}.qbtheme"

QBIT_WAS_RUNNING=false

if pgrep -x qbittorrent >/dev/null; then
    QBIT_WAS_RUNNING=true
    pkill -x qbittorrent
    sleep 1
fi

# theme modifications here

if [ "$QBIT_WAS_RUNNING" = true ]; then
    nohup qbittorrent >/dev/null 2>&1 &
fi

sed -i \
"s|CustomUIThemePath=.*|CustomUIThemePath=${QBIT_THEME}|" \
"$QBIT_CONF"

sed -i \
"s|UseCustomUITheme=.*|UseCustomUITheme=true|" \
"$QBIT_CONF"

# ------------------------
# Bar reload (Smart Logic)
# ------------------------
if pgrep -x "waybar" >/dev/null; then
    killall -SIGUSR2 waybar
fi
# ------------------------
# Waybar reload
# ------------------------
#killall -SIGUSR2 waybar 2>/dev/null || waybar 

# ------------------------
# Wlogout icons
# ------------------------
rm -f "$WLOGOUT_DIR/icons/current"
ln -s "$WLOGOUT_DIR/icons/$THEME" "$WLOGOUT_DIR/icons/current"

# ------------------------
# Hyprland colors
# ------------------------
cp "$THEME_DIR/hypr.lua" "$HYPR_DIR/colors.lua"
cp "$THEME_DIR/hypr.conf" "$HYPR_DIR/colors.conf"

# ------------------------
# Kitty
# ------------------------
if [ -f "$THEME_DIR/kitty/horizon.colors.conf" ]; then
    cp "$THEME_DIR/kitty/horizon.colors.conf" "$KITTY_COLORS"

    for SOCKET in ~/.config/kitty/kitty.sock-*; do
    [ -S "$SOCKET" ] || continue

    if kitty @ --to "unix:$SOCKET" ls >/dev/null 2>&1; then
        kitty @ --to "unix:$SOCKET" set-colors --all --config "$THEME_DIR/kitty/horizon.colors.conf"
    else
        rm -f "$SOCKET"  # clean up dead socket
    fi
done
fi

# ------------------------
# GTK3 / legacy apps
# ------------------------

gsettings set org.gnome.desktop.interface gtk-theme "Material-BL-MB-Dark-Darker"
gsettings set org.gnome.desktop.interface icon-theme "Tela-red"
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
# Wallpaper
# ------------------------

awww img ~/.config/themes/horizon/wallpapers/horizon.png --outputs DP-1 --transition-type any
awww img ~/.config/themes/horizon/wallpapers/horizon3.png --outputs DP-3 --transition-type any

# ------------------------
# Rofi
# ------------------------
cp "$THEME_DIR/colors.rasi" ~/.config/rofi/launchers/type-2/shared

# ------------------------
# VSCodium
# ------------------------
VSCODE_SETTINGS="$HOME/.config/VSCodium/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    sed -i 's/"workbench.colorTheme":[[:space:]]*"[^"]*"/"workbench.colorTheme": "Horizon"/' "$VSCODE_SETTINGS"
fi

# ------------------------
# Spotify
# ------------------------
spicetify config current_theme Horizon

if pgrep -x spotify >/dev/null; then
  (spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q") &
else 
  spicetify apply -n >/dev/null 2>&1
fi

# ------------------------
# Hyprlock
# ------------------------
ln -sf "$HYPR_DIR/background/horizon.png" "$HYPR_DIR/background/current.png"
pkill hyprlock 2>/dev/null

# ------------------------
# Save theme
# ------------------------
echo "$THEME" > "$HOME/.config/.current_theme"



