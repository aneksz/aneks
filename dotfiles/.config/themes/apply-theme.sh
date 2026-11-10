#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.spicetify:$HOME/.local/bin:/usr/local/bin:$PATH"

THEME="${1:?Usage: apply-theme.sh <theme-name>}"
CFG="$HOME/.config"
THEME_DIR="$CFG/themes/$THEME"
WALL_DIR="$HOME/Pictures/Wallpapers/themes/$THEME"
TPL="$CFG/themes/templates"
QS="$CFG/quickshell"
HYPR="$CFG/hypr"
COLORS_FILE="$THEME_DIR/colors.toml"

[[ -d $THEME_DIR && -f $COLORS_FILE ]] || { echo "Missing theme dir or colors.toml for '$THEME'"; exit 1; }

# ---------- parse colors.toml into COLORS[] and a sed script ----------
hex_to_rgb() { local h="${1#\#}"; printf "%d,%d,%d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"; }

declare -A COLORS
sed_script=$(mktemp)
trap 'rm -f "$sed_script"' EXIT
while IFS='=' read -r key value || [[ -n "$key" ]]; do
  key="${key//[\"\' ]/}"
  [[ $key && $key != \#* ]] || continue
  value="${value#*[\"\']}"; value="${value%%[\"\']*}"
  COLORS[$key]="$value"
  printf 's|{{ %s }}|%s|g\n' "$key" "$value" >> "$sed_script"
  printf 's|{{ %s_strip }}|%s|g\n' "$key" "${value#\#}" >> "$sed_script"
  if [[ $value =~ ^# ]]; then
    printf 's|{{ %s_rgb }}|%s|g\n' "$key" "$(hex_to_rgb "$value")" >> "$sed_script"
    printf 's|{{ %s_argb }}|0xff%s|g\n' "$key" "${value#\#}" >> "$sed_script"
  fi
done < "$COLORS_FILE"

if [[ -z ${COLORS[border]:-} ]]; then
  COLORS[border]="${COLORS[color8]}"
  printf 's|{{ border }}|%s|g\n' "${COLORS[border]}" >> "$sed_script"
fi

sed -i 's/0xff[0-9A-Fa-f]\{6\}/\L&/' "$sed_script"

render() { sed -f "$sed_script" "$TPL/$1"; }   # render <template>  ->  stdout

SCHEME="${COLORS[color_scheme]:-prefer-dark}"
BRAVE_MODE=dark; [[ $SCHEME == prefer-light ]] && BRAVE_MODE=light

# ---------- templates -> theme dir ----------
render hypr.conf.tpl            > "$THEME_DIR/hypr.conf"
render hypr.lua.tpl             > "$THEME_DIR/hypr.lua"
render kitty.colors.conf.tpl    > "$THEME_DIR/kitty/${THEME}.colors.conf"
render quickshell_theme.qml.tpl > "$THEME_DIR/quickshell_theme.qml"

# ---------- simple installs ----------
if [[ -f "$CFG/btop/btop.conf" ]]; then
  sed -i "s/^color_theme *= *.*/color_theme = \"$THEME\"/" "$CFG/btop/btop.conf"
  pgrep -x btop >/dev/null && pkill -x -USR2 btop || true
fi

cp "$THEME_DIR/${THEME}.p10k.zsh" "$HOME/.p10k.zsh"
(sleep 0.6 && notify-send "Theme Updated" "Applied Theme: $THEME") &

for d in "$QS" "$QS/bar1" "$QS/bar2"; do cp "$THEME_DIR/quickshell_theme.qml" "$d/Colors.qml"; done
cp "$THEME_DIR/hypr.lua"  "$HYPR/modules/colors.lua"
cp "$THEME_DIR/hypr.conf" "$HYPR/colors.conf"


# ---------- kitty ----------
KITTY_CONF="$THEME_DIR/kitty/${THEME}.colors.conf"
cp "$KITTY_CONF" "$CFG/kitty/colors.conf"
for sock in "$CFG"/kitty/kitty.sock-*; do
  [[ -S $sock ]] || continue
  if kitty @ --to "unix:$sock" ls >/dev/null 2>&1; then
    kitty @ --to "unix:$sock" set-colors --all --config "$KITTY_CONF" || true
  else
    rm -f "$sock"
  fi
done

# ---------- brave ----------
#sudo /usr/local/bin/set-brave-theme "${COLORS[brave_accent]}" "$BRAVE_MODE"
#pgrep -x brave >/dev/null && brave --refresh-platform-policy --no-startup-window &>/dev/null &

# ---------- GTK4 (generated libadwaita colours) ----------
G="$CFG/gtk-4.0"
if [[ ${COLORS[gtk_theme]} == Adwaita* ]]; then
  mkdir -p "$G"; rm -rf "$G/gtk-dark.css" "$G/assets"
  render gtk4.css.tpl > "$G/.gtk.css.tmp" && mv -f "$G/.gtk.css.tmp" "$G/gtk.css"   # atomic: patched gtk4 reloads live
else
  : # TODO: symlink block for non-Adwaita themes
fi
gsettings set org.gnome.desktop.interface gtk-theme "${COLORS[gtk_theme]}"
gsettings set org.gnome.desktop.interface icon-theme "${COLORS[icon_theme]}"
gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"

# GTK3/portal dialogs (save/open) read settings.ini, not gtk.css
dark=1; [[ $SCHEME == prefer-light ]] && dark=0
for v in gtk-3.0 gtk-4.0; do
  ini="$CFG/$v/settings.ini"
  [[ -f $ini ]] || continue
  sed -i -e "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$dark/" \
         -e "s/^gtk-theme-name=.*/gtk-theme-name=${COLORS[gtk_theme]}/" \
         -e "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=${COLORS[icon_theme]}/" "$ini"
done

# Stock GTK4 only reads gtk.css at startup, and Nautilus keeps running in the
# background after its window closes. Without the live-reload patch (e.g. on
# NixOS), quit it so the next launch picks up the new colours.
if ! pacman -Q gtk4-live-css &>/dev/null; then
  command -v nautilus >/dev/null && nautilus -q 2>/dev/null || true
fi

# ---------- wallpapers ----------
for pair in DP-1:wallpaper_dp1 DP-3:wallpaper_dp3; do
  awww img "$WALL_DIR/${COLORS[${pair#*:}]}" --outputs "${pair%%:*}" --transition-type any
done
ln -sf "$WALL_DIR/${COLORS[wallpaper_dp1]}" "$HYPR/background/current.png"


# ---------- VSCodium ----------
VSC="$CFG/VSCodium/User/settings.json"
[[ -f $VSC ]] && sed -i "s/\"workbench.colorTheme\":[[:space:]]*\"[^\"]*\"/\"workbench.colorTheme\": \"${COLORS[vscode_theme]}\"/" "$VSC"

# ---------- Firefox (Pywalfox) ----------
if command -v pywalfox >/dev/null 2>&1; then
  WAL="$HOME/.cache/wal"; mkdir -p "$WAL"
  {
    printf '{\n  "wallpaper": "%s",\n  "alpha": "100",\n' "$WALL_DIR/${COLORS[wallpaper_dp1]:-}"
    printf '  "special": {\n    "background": "%s",\n    "foreground": "%s",\n    "cursor": "%s"\n  },\n' \
      "${COLORS[background]}" "${COLORS[foreground]}" "${COLORS[cursor]:-${COLORS[foreground]}}"
    printf '  "colors": {\n'
    for i in {0..15}; do
      val="${COLORS[color$i]:-#000000}"
      (( i == 10 )) && [[ -n ${COLORS[accent]:-} ]]     && val="${COLORS[accent]}"      # accent primary
      (( i == 13 )) && [[ -n ${COLORS[accent_alt]:-} ]] && val="${COLORS[accent_alt]}"  # accent secondary
      (( i == 8 ))  && [[ -n ${COLORS[bg1]:-} ]]        && val="${COLORS[bg1]}"         # URL bar surface
      printf '    "color%d": "%s"%s\n' "$i" "$val" "$( (( i == 15 )) || echo ,)"
    done
    printf '  }\n}\n'
  } > "$WAL/colors.json"
  pywalfox update >/dev/null 2>&1 || true
fi

# ---------- Spotify ----------
# Themes with their own Spicetify theme use it; everything else gets "aneks",
# Sleek's layout with colours generated from colors.toml.
if command -v spicetify >/dev/null; then
  SPICE_DIR="$CFG/spicetify/Themes"
  SPICE_THEME="${COLORS[spicetify_theme]:-aneks}"
  SPICE_SCHEME="${COLORS[spicetify_color_scheme]:-}"
  if [[ ! -d "$SPICE_DIR/$SPICE_THEME" || $SPICE_THEME == aneks ]]; then
    SPICE_THEME=aneks; SPICE_SCHEME=Base
  fi
  mkdir -p "$SPICE_DIR/aneks"
  render spicetify-color.ini.tpl > "$SPICE_DIR/aneks/color.ini"
  spicetify config current_theme "$SPICE_THEME" color_scheme "$SPICE_SCHEME" >/dev/null || true
  spicetify apply -n >/dev/null 2>&1 || true

  # Live-reload only once Spotify's debugger answers; never let spicetify kill/restart it
  if pgrep -x spotify >/dev/null; then
    (
      for _ in $(seq 10); do
        if curl -s localhost:9222/json/list | grep -q spotify; then
          spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q"
          exit
        fi
        sleep 1
      done
    ) &
  fi
fi


# ---------- Cursor (Bibata outlined in the accent colour) ----------
# Builds ~/.local/share/icons/Aneks-Accent from colors.toml and applies it live.
# Runs in the background: a first build for a theme takes a few seconds.
CURSOR_ACCENT="$HOME/.local/share/cursor-accent/recolor.py"
if [[ -f $CURSOR_ACCENT ]] && command -v rsvg-convert >/dev/null; then
  python3 "$CURSOR_ACCENT" "$COLORS_FILE" >/dev/null 2>&1 &
fi

# ---------- Starship (base + generated palette) ----------
if [[ -f "$CFG/starship/base.toml" ]]; then
  { cat "$CFG/starship/base.toml"; render starship-palette.tpl; } > "$CFG/starship.toml"
fi

# ---------- Vesktop (base layout + generated colours) ----------
VBASE="$CFG/vesktop/system24-base.css"
VOUT="$CFG/vesktop/themes/system24-themed.theme.css"
if [[ -f $VBASE ]]; then
  mkdir -p "${VOUT%/*}"
  { cat "$VBASE"; echo; render vesktop.css.tpl; } > "$VOUT.tmp" && mv "$VOUT.tmp" "$VOUT"
fi

echo "$THEME" > "$CFG/.current_theme"
