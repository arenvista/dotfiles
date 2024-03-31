#!/bin/bash

# Get the current volume level
current_volume=$(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }' | tr -d '%')

# Check if the volume is at 50%, 25%, or 0% and echo a message accordingly
if [ "$current_volume" -ge 50 ]; then
    echo "󰕾 $current_volume%"
elif [ "$current_volume" -ge 25 ]; then
    echo " $current_volume%"
elif [ "$current_volume" -eq 0 ]; then
    echo " $current_volume%"
else
    echo "The volume is not at 50%, 25%, or 0%."
fi

