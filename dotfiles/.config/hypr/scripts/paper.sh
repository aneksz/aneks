#!/bin/bash

killall -9 hyprpaper 2>/dev/null; sleep 0.2; /usr/bin/hyprpaper >/dev/null 2>&1 &
