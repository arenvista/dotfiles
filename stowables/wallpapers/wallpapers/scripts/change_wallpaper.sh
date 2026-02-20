#!/bin/zsh

# --- 1. Base Variables ---
scrDir="$(dirname "$(realpath "$0")")"
rofiConf="$HOME/.config/rofi/selector.rasi"

# Provide defaults in case these aren't exported in the environment
rofiScale="${rofiScale:-10}"
hypr_border="${hypr_border:-2}" 

r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 5 ))
icon_border=$(( elem_border - 5 ))

# --- 2. Monitor Scale Logic ---
# Single jq pass for accurate calculation
mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | (.width / .scale) | floor')

# --- 3. Generate Config ---
case "${themeSelect}" in
    2) # Adapt to style 2
        elm_width=$(( (20 + 12) * rofiScale * 2 ))
        max_avail=$(( mon_x_res - (4 * rofiScale) ))
        col_count=$(( max_avail / elm_width ))
        r_override="window{width:100%;background-color:#00000003;} listview{columns:${col_count};} element{border-radius:${elem_border}px;background-color:@main-bg;} element-icon{size:20em;border-radius:${icon_border}px 0px 0px ${icon_border}px;}"
        thmbExtn="quad" 
        ;;
    *) # Default to style 1
        elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
        max_avail=$(( mon_x_res - (4 * rofiScale) ))
        col_count=$(( max_avail / elm_width ))
        r_override="window{width:100%;} listview{columns:${col_count};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"
        thmbExtn="sqre" 
        ;;
esac

# --- 4. Rofi Item Generation & Selection ---

# Pipe directly to rofi using printf to avoid zsh string/null-byte mangling
selected_base=$(
    for file in ~/wallpapers/favorites/*.{png,jpg,jpeg,gif,PNG,JPG,JPEG,GIF}(N); do
        printf "%s\0icon\x1f%s\n" "${file:t:r}" "$file"
    done | rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}"
)

# Exit cleanly if the user closes rofi without selecting anything (pressing ESC)
[[ -z "$selected_base" ]] && exit 0

# Safely retrieve the absolute path back from the filesystem.
# Double quotes around ${selected_base} prevent globbing errors if filenames contain [ ] or *.
matches=( ~/wallpapers/favorites/"${selected_base}".*(N) )
WALLPAPER="${matches[1]}"
export WALLPAPER

# --- 5. Application & Execution ---
if [[ -n "$WALLPAPER" ]]; then
    # Create Cropped Images (Quotes ensure paths with spaces don't break magick)
    magick "$WALLPAPER" -gravity center -crop 1400x1600+0+0 +repage ~/wallpapers/imgs/temp.png
    magick "$WALLPAPER" -gravity center -crop 2400x1600+0+0 +repage ~/wallpapers/imgs/temp_sddm.png
    
    # Set as environment variable
    sed -i "s|export WALLPAPER=\".*\"|export WALLPAPER=\"$WALLPAPER\"|" ~/wallpapers/scripts/wallpaper_state.env
    
    # Set as image to be rendered for swww background
    swww img "$WALLPAPER" --transition-type center --resize crop --fill-color 080808
fi

rm -f ~/dotfiles/utils/firefox/temp.png
cp ~/wallpapers/imgs/temp.png ~/dotfiles/utils/firefox/

wal -i "$WALLPAPER" 
neofetch --clean 

pkill miniserve
pkill -USR1 kitty 

source ~/wallpapers/scripts/wallpaper_state.env

./firefoxcolors.sh

"$HOME/dotfiles/stowables/waybar/.config/waybar/launch_waybar"

miniserve "$HOME/dotfiles/utils/firefox/" --index home.html --header "Cache-Control: no-cache, no-store, must-revalidate"&

echo "serving"
