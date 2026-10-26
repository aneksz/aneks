#!/usr/bin/env bash

killall -9 qs 2>/dev/null; sleep 0.2; qs -p ~/.config/quickshell/bar2 >/dev/null 2>&1 &
