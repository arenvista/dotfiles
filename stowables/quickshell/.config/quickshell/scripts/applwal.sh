#!/usr/bin/env bash

WALLPAPER_PATH="$1"

# Ensure wallpaper path is provided and valid
if [ -z "$WALLPAPER_PATH" ] || [ ! -f "$WALLPAPER_PATH" ]; then
    exit 1
fi

# Display notification
notify-send "$WALLPAPER_PATH" ~/wallpapers/current

# Create symlink for the wallpaper
ln -sf "$WALLPAPER_PATH" ~/wallpapers/current
magick "$WALLPAPER_PATH" -gravity center -crop 1400x1600+0+0 +repage ~/wallpapers/current.jpg
magick "$WALLPAPER_PATH" -gravity center -crop 1400x1600+0+0 +repage ~/dotfiles/utils/firefox/current.jpg

# Run `swww` in the background with detachment
setsid swww img "$WALLPAPER_PATH" --transition-type any --transition-duration 2 >/dev/null 2>&1 &

# Run `wal` in the background with detachment
setsid wal -i "$WALLPAPER_PATH" -n -q >/dev/null 2>&1 &

# Sleep for 1 second to ensure processes complete
sleep 1

# Exit the script cleanly
exit 0
