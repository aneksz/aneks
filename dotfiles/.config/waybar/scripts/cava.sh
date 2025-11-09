#!/bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# create dictionary to replace numbers with bar chars
i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done

config_file="/tmp/polybar_cava_config"

# write Cava config
echo "
[general]
bars = 8

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" > "$config_file"

# function to check if any audio is playing
audio_playing() {
    # returns 1 if at least one sink input is active
    pactl list sink-inputs short | grep -q .
}

# loop to dynamically run Cava only when audio is present
while true; do
    if audio_playing; then
        # start Cava in background, capture PID
        cava -p "$config_file" | while read -r line; do
            echo "{\"text\": \"$(echo $line | sed $dict)\", \"class\": \"custom-cava\"}"
        done &
        CAVA_PID=$!

        # wait until audio stops
        while audio_playing; do
            sleep 0.2
        done

        # audio stopped, kill Cava
        kill $CAVA_PID 2>/dev/null
    else
        # output nothing so Waybar hides the module
        echo ""
        sleep 0.5
    fi
done
