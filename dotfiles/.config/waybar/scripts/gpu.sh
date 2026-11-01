#!/usr/bin/env bash

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)

if [ "$temp" -lt 55 ]; then
    class="normal"
elif [ "$temp" -lt 70 ]; then
    class="warm"
elif [ "$temp" -lt 85 ]; then
    class="hot"
else
    class="critical"
fi

echo "{\"text\": \" $temp°C\", \"tooltip\": \"NVIDIA GPU Temp: $temp°C\", \"class\": \"$class\"}"
