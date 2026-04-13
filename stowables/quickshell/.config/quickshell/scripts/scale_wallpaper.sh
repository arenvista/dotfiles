#!/bin/bash

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

OUTPUT_PATH_SWWW="$HOME/wallpapers/current"
OUTPUT_PATH_FIREFOX="$HOME/dotfiles/utils/firefox/current.jpg"

# Scale and crop the image to perfectly cover the monitor's resolution
magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_SWWW"
magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_FIREFOX"


echo "magick "$WALLPAPER_PATH" -resize "${MON_RES}^" -gravity center -extent "$MON_RES" "$OUTPUT_PATH_SWWW""
