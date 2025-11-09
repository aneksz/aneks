#!/usr/bin/env bash

count=$(swaync-client -c 2>/dev/null)

if [[ "$count" -gt 0 ]]; then
    echo "󱅫 $count"
else
    echo "󰂚"
fi
