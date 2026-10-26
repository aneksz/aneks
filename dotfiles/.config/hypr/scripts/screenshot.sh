#!/bin/bash
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
TS=$(date +%Y-%m-%d_%H-%M-%S)
OUT="$DIR/$TS.png"

# pipe uncompressed ppm into satty and specify where to save the edited image
grim -g "$(slurp -d)" -t ppm - | satty --filename - --output-filename "$OUT" --early-exit
