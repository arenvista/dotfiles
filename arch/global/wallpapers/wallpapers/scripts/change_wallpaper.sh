#!/bin/bash

# Read the contents of wallpaper_state into a variable
wallpaper_state=$(cat ~/wallpapers/scripts/wallpaper_state)

# If empty or greater than 1, set to 0
if [ -z "$wallpaper_state" ] || [ "$wallpaper_state" -gt 1 ]; then
    wallpaper_state=0
else
    # Otherwise, increment by 1
    wallpaper_state=$((wallpaper_state + 1))
fi

# Write the new value to the file
echo "$wallpaper_state" > ~/wallpapers/scripts/wallpaper_state


# echo "Wallpaper state is now $wallpaper_state"
echo "Wallpaper state is now $wallpaper_state"

# Set the wallpaper based on the new value
if [ "$wallpaper_state" -eq 0 ]; then
    cd ~/.dotfiles/arch/
    sh call_stow.sh orange
    cd ~/.config/waybar
    sh launch_waybar.sh
    swww img ~/wallpapers/orange_uw.png --transition-type center --resize fit --fill-color d2d0c4
elif [ "$wallpaper_state" -eq 1 ]; then
    echo "1"
fi

