#!/bin/bash

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)

# safer icon
echo "{\"text\": \" $temp°C\", \"tooltip\": \"NVIDIA GPU Temp: $temp°C\"}"
