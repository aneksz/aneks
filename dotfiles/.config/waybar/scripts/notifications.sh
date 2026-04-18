#!/usr/bin/env bash

get_status() {
    local DND count

    DND=$(swaync-client -D 2>/dev/null)
    count=$(swaync-client -c 2>/dev/null)

    if [[ "$DND" == "true" ]]; then
        printf "󰂛\n"
    elif [[ "$count" -gt 0 ]]; then
        printf "󱅫 %s\n" "$count"
    else
        printf "󰂚\n"
    fi
}

# Initial state
get_status

# Update on events
swaync-client -swb | while read -r _; do
    get_status
done
