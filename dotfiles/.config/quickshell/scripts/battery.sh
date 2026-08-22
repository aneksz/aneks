#!/bin/bash

# Fetch Solaar's full status text
solaar_output=$(solaar show 2>/dev/null)

# Extract percentage using grep and awk, leave empty if not found
keyboard=$(echo "$solaar_output" | awk '/Keyboard/{flag=1;next}/Mouse/{flag=0} flag' | grep -oP 'Battery: \K[0-9]+' | tail -n 1)
mouse=$(echo "$solaar_output" | awk '/Mouse/{flag=1;next}/Keyboard/{flag=0} flag' | grep -oP 'Battery: \K[0-9]+' | tail -n 1)

# Fallback check: if specific block parsing failed, try global extraction
if [ -z "$keyboard" ]; then
    keyboard=$(echo "$solaar_output" | grep -A 5 -i "keyboard" | grep -oP 'Battery: \K[0-9]+' | tail -n 1)
fi

if [ -z "$mouse" ]; then
    mouse=$(echo "$solaar_output" | grep -A 5 -i "mouse" | grep -oP 'Battery: \K[0-9]+' | tail -n 1)
fi

# Ensure values are strictly numbers or null for valid JSON construction
# If empty, we output null so QML knows it is a missing/stale read instead of 0%
[ -z "$keyboard" ] && keyboard="null"
[ -z "$mouse" ] && mouse="null"

# Output the clean JSON string
echo "{\"keyboard\":$keyboard,\"mouse\":$mouse}"
