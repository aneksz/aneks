#!/bin/bash

# Get a list of all client addresses
CLIENT_ADDRESSES=$(hyprctl clients -j | jq -r '.[].address')

# Check if any clients were found
if [ -z "$CLIENT_ADDRESSES" ]; then
    echo "No active windows found to close."
    exit 0
fi

COMMAND_BATCH=""

# Iterate over each address and build the batch command string
for ADDR in $CLIENT_ADDRESSES; do
    COMMAND_BATCH="${COMMAND_BATCH}dispatch killwindow address:$ADDR;"
done

# Execute the batch command with hyprctl
echo "Executing batch command: $COMMAND_BATCH"
hyprctl --batch "$COMMAND_BATCH"
