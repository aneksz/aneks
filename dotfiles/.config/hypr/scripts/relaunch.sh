#!/usr/bin/env bash
# Restart the bar (works on NixOS and Arch)
qs kill -p ~/.config/quickshell/bar2 2>/dev/null
sleep 0.2
qs -p ~/.config/quickshell/bar2 >/dev/null 2>&1 &
