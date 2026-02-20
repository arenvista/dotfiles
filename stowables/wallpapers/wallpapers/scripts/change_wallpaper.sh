#!/bin/zsh
scrDir="$(dirname "$(realpath "$0")")"
rofiConf="~/.config/rofi/selector.rasi"
# Set rofi scaling
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 5 ))
icon_border=$(( elem_border - 5 ))
# Scale for monitor
mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed "s/\.//")
mon_x_res=$(( mon_x_res * 100 / mon_scale ))
# Generate config
case "${themeSelect}" in
2) # Adapt to style 2
    elm_width=$(( (20 + 12) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;background-color:#00000003;} listview{columns:${col_count};} element{border-radius:${elem_border}px;background-color:@main-bg;} element-icon{size:20em;border-radius:${icon_border}px 0px 0px ${icon_border}px;}"
    thmbExtn="quad" ;;
*) # Default to style 1
    elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;} listview{columns:${col_count};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"
    thmbExtn="sqre" ;;
esac
# Launch rofi menu
WALLPAPER=$(find ~/wallpapers/favorites -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.gif" -o -name "*.jpeg" \) -print0 | xargs -0 -I {} echo -en "$(basename '{}' .png)\x00icon\x1f{}\n"  | rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}")
export WALLPAPER
if [[ -n "$WALLPAPER" ]]; then
    # Create Cropped Images
    magick convert $WALLPAPER -gravity center -crop 1400x1600+0+0 +repage ~/wallpapers/imgs/temp.png
    magick convert $WALLPAPER -gravity center -crop 2400x1600+0+0 +repage ~/wallpapers/imgs/temp_sddm.png
    # Set as enviorment variable
    sed -i "s|export WALLPAPER=\".*\"|export WALLPAPER=\"$WALLPAPER\"|" ~/wallpapers/scripts/wallpaper_state.env
    # Define as image to be used in catnap 
    # sed -i "s|path   = \".*\"|path   = \"$WALLPAPER\"|" ~/.config/catnap/config.toml
    # Set as image to be rendered for swww background
    swww img ${WALLPAPER} --transition-type center --resize crop --fill-color 080808
fi

wal -i $WALLPAPER
rm ~/dotfiles/imgs/utils/firefox/temp.png
cp ~/wallpapers/imgs/temp.png ~/dotfiles/utils/firefox/
exec ~/dotfiles/stowables/waybar/.config/waybar/launch_waybar
kill -SIGUSR1 $(pgrep kitty)
source wallpaper_state.env
