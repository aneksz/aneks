#!/usr/bin/env bash
# ~/.config/waybar/scripts/volume_osd.sh

ACTION=$1  # "raise" or "lower"

swayosd-client --output-volume "$ACTION" \
    --radius 10 \
    --font "FiraCode Nerd Font 14" \
    --color "#ffffff" \
    --background "#1e1e2e" \
    --height 20 \
    --width 400 \
    --padding 10 \
    --icon \
    --timeout 1500
