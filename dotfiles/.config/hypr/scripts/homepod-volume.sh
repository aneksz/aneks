#!/usr/bin/env bash
# Remembers the Study (HomePod) volume across reboots
f="$HOME/.local/state/homepod-volume"
is_study() { wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q 'node.description = "Study"'; }

sleep 10
is_study && [ -f "$f" ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ "$(cat "$f")"

while sleep 30; do
  if is_study; then
    v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    [ -n "$v" ] && echo "$v" > "$f"
  fi
done
