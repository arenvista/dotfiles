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


OUTPUT_PATH_SWWW="$HOME/wallpapers/current"
OUTPUT_PATH_FIREFOX="$HOME/dotfiles/utils/firefox/current.jpg"

# Extract monitor data and read it directly into 5 variables
read -r MON_NAME MON_WIDTH MON_HEIGHT ASP_W ASP_H < <(
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.name) \(.width) \(.height)"' | awk '{
        w=$2; h=$3;
        a=w; b=h;
        while(b!=0) { t=b; b=a%b; a=t; }
        # Print space-separated raw values for bash to read
        print $1, w, h, w/a, h/a 
    }'
)

# Format the resolution into a clean string
MON_RES="${MON_WIDTH}x${MON_HEIGHT}"

echo "Scaling wallpaper to fit $MON_NAME ($MON_RES)..."

OUTPUT_PATH_SWWW="$HOME/wallpapers/current.jpg"
OUTPUT_PATH_FIREFOX="$HOME/dotfiles/utils/firefox/current.jpg"

# Scale and crop the image to perfectly cover the monitor's resolution
magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_SWWW"
magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_FIREFOX"

echo "magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_SWWW""

# Run `swww` in the background with detachment
setsid awww img "$OUTPUT_PATH_SWWW" --transition-type any --transition-duration 2 >/dev/null 2>&1 &

# Run `wal` in the background with detachment
setsid wal -i "$WALLPAPER_PATH" -n -q >/dev/null 2>&1 &

# Sleep for 1 second to ensure processes complete
sleep 1

python ~/.config/zathura/templater.py
python ~/.config/quickshell/scripts/ghosty-colorizer.py

# Exit the script cleanly
exit 0
