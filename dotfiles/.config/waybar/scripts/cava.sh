export PATH=$PATH:/usr/bin:/usr/local/bin
export XDG_RUNTIME_DIR=/run/user/$(id -u)

FIFO="/tmp/cava_fifo"
CONFIG="/tmp/cava_config"

# Consecutive genuinely-silent readings before reporting "not playing".
# A corked/paused sink-input can stay registered indefinitely with no
# real sound, which caused the old pactl-gated start/stop approach to
# flicker (relaunch cava the instant it detected silence and stopped).
# Running cava continuously and deciding "playing" purely from the
# actual values sidesteps that entirely. Tune this against your own
# track-to-track transition gaps.
SILENCE_THRESHOLD=60

cleanup() {
    pkill -f "cava -p $CONFIG" 2>/dev/null
    rm -f "$FIFO" "$CONFIG"
}
trap cleanup EXIT

rm -f "$FIFO" "$CONFIG"
mkfifo "$FIFO"

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

# Run once, continuously - no more start/stop cycling based on pactl
cava -p "$CONFIG" >/dev/null 2>&1 &

silence_count=0

while read -r line; do
    [ -z "$line" ] && continue

    values=${line%;}
    values=${values//;/,}

    # Sum the bar values to detect genuine silence
    IFS=',' read -ra vals <<< "$values"
    sum=0
    for v in "${vals[@]}"; do
        sum=$((sum + v))
    done

    if (( sum == 0 )); then
        ((silence_count++))
    else
        silence_count=0
    fi

    if (( silence_count >= SILENCE_THRESHOLD )); then
        printf '{"values": [%s], "playing": false}\n' "$values"
    else
        printf '{"values": [%s], "playing": true}\n' "$values"
    fi
done < "$FIFO"
