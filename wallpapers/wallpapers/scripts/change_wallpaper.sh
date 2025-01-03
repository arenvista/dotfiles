#!/bin/bash

# Create an array of all image files in favorites directory
images=($(ls -p ~/wallpapers/favorites | rg -v /))
# Get the number of images in the array
num_images=$((${#images[@]} - 1))
# Get the current wallpaper state
wallpaper_state=$(cat ~/wallpapers/scripts/wallpaper_state)
# If empty or greater than the number of images, set to 0
if [ -z "$wallpaper_state" ] || [ "$wallpaper_state" -ge "$num_images" ]; then
	wallpaper_state=0
else
	# Otherwise, increment by 1
	wallpaper_state=$((wallpaper_state + 1))
fi
selected_image=${images[$wallpaper_state]}
# Write the new value to the file
echo "$wallpaper_state" > ~/wallpapers/scripts/wallpaper_state
# Set the wallpaper based on the new value
swww img ~/wallpapers/favorites/${selected_image} --transition-type center --resize fit --fill-color 080808

# wal -i ~/wallpapers/favorites/${selected_image} # Generate colorscheme

sed -i "s/favorites.*/favorites\/${selected_image}/g" ~/.bashrc
kill -SIGUSR1 $(pidof kitty) # Reload kitty colorscheme

echo "${selected_image}"

echo "*********** Wallpaper changed to ${selected_image} | Wallpaper state: ${wallpaper_state} ***********"

