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
bars = 16
autosens = 1
overshoot = 14
sensitivity = 149
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

# 3. Main Loop
while true; do
    if audio_playing; then
        # Start CAVA
        cava -p "$CONFIG" >/dev/null 2>&1 &
        CAVA_PID=$!

        count=0

        # Read directly from FIFO (no cat)
        while read -r line; do
            if [ -n "$line" ]; then
                # Remove trailing ';'
                values=${line%;}
                # Replace ';' with ','
                values=${values//;/,}

                printf '{"values": [%s]}\n' "$values"
            fi

            ((count++))
            if (( count % 20 == 0 )); then
                if ! audio_playing; then
                    echo "{\"values\": [$ZEROS]}"
                    kill $CAVA_PID 2>/dev/null
                    break
                fi
            fi
        done < "$FIFO"

    else
        # Silent state
        echo "{\"values\": [$ZEROS]}"
        sleep 1
    fi
done
