#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/local/bin
export XDG_RUNTIME_DIR=/run/user/$(id -u)

FIFO="/tmp/cava_fifo"
CONFIG="/tmp/cava_config"
ZEROS="0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"

# Function to check for active audio streams
audio_playing() {
    pactl list sink-inputs short | grep -q .
}

cleanup() {
    pkill -P $$ cava 2>/dev/null
    rm -f "$FIFO" "$CONFIG"
}
trap cleanup EXIT

# 1. Initial Setup
rm -f "$FIFO" "$CONFIG"
mkfifo "$FIFO"

# 2. Create the CAVA config
cat > "$CONFIG" <<EOF
[general]
bars = 20
autosens = 1
overshoot = 10
sensitivity = 100
[input]
method = pulse
source = auto
[output]
method = raw
raw_target = $FIFO
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
EOF

# 3. The Main Loop
while true; do
    if audio_playing; then
        # Start CAVA
        cava -p "$CONFIG" >/dev/null 2>&1 &
        CAVA_PID=$!

        # Process the FIFO data
        # We use a counter to only check pactl every ~20 lines to save CPU
        count=0
        stdbuf -oL cat "$FIFO" | while read -r line; do
            if [ -n "$line" ]; then
                values=$(echo "${line%;}" | tr ';' ',')
                printf '{"values": [%s]}\n' "$values"
            fi
            
            ((count++))
            if [ $((count % 20)) -eq 0 ]; then
                if ! audio_playing; then
                    echo "{\"values\": [$ZEROS]}"
                    kill $CAVA_PID 2>/dev/null
                    break 2 # Break out of both the 'while read' and return to main loop
                fi
            fi
        done
    else
        # Silent state: Send zeros and wait before checking again
        echo "{\"values\": [$ZEROS]}"
        sleep 1
    fi
done
