#!/usr/bin/env bash

DND=$(swaync-client -D 2>/dev/null)
count=$(swaync-client -c 2>/dev/null)

# If DND is enabled, always show the DND icon
if [[ "$DND" == "true" ]]; then
    echo "󰂛"
    exit 0
fi

# Normal behaviour when DND is off
if [[ "$count" -gt 0 ]]; then
    echo "󱅫 $count"
else
    echo "󰂚"
fi
