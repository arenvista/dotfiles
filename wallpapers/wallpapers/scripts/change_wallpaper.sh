#!/usr/bin/env sh


#// set variables

scrDir="$(dirname "$(realpath "$0")")"
# source "${scrDir}/globalcontrol.sh"
rofiConf="~/.config/rofi/selector.rasi"


#// set rofi scaling

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 5 ))
icon_border=$(( elem_border - 5 ))


#// scale for monitor

mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed "s/\.//")
mon_x_res=$(( mon_x_res * 100 / mon_scale ))


#// generate config

case "${themeSelect}" in
2) # adapt to style 2
    elm_width=$(( (20 + 12) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;background-color:#00000003;} listview{columns:${col_count};} element{border-radius:${elem_border}px;background-color:@main-bg;} element-icon{size:20em;border-radius:${icon_border}px 0px 0px ${icon_border}px;}"
    thmbExtn="quad" ;;
*) # default to style 1
    elm_width=$(( (23 + 12 + 1) * rofiScale * 2 ))
    max_avail=$(( mon_x_res - (4 * rofiScale) ))
    col_count=$(( max_avail / elm_width ))
    r_override="window{width:100%;} listview{columns:${col_count};} element{border-radius:${elem_border}px;padding:0.5em;} element-icon{size:23em;border-radius:${icon_border}px;}"
    thmbExtn="sqre" ;;
esac
#// launch rofi menu
wallpaper_selection=$(find ~/wallpapers/favorites -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.gif" -o -name "*.jpeg" \) -print0 | xargs -0 -I {} echo -en "$(basename '{}' .png)\x00icon\x1f{}\n"  | rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}")

# crop selection 
magick convert $wallpaper_selection -gravity center -crop 1400x1600+0+0 +repage ~/wallpapers/imgs/temp.png

sed -i "s|export WALLPAPER=\".*\"|export WALLPAPER=\"$wallpaper_selection\"|" ~/wallpapers/scripts/wallpaper_state.env
sed -i "s|path   = \".*\"|path   = \"$wallpaper_selection\"|" ~/.config/catnap/config.toml
swww img ${wallpaper_selection} --transition-type center --resize crop --fill-color 080808

#// apply theme

# if [ ! -z "${rofiSel}" ] ; then
#     "${scrDir}/themeswitch.sh" -s "${rofiSel}"
#     notify-send -a "t1" -i "$HOME/.config/dunst/icons/hyprdots.png" " ${rofiSel}"
# fi

# find ~/wallpapers/favorites -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.gif" \) -print0 | xargs -0 -I {} echo -en "$(basename '{}' .png)\x00icon\x1f{}\n" | rofi -dmenu -theme selector.rasi -theme-str "${r_scale}" -config "${rofiConf}"
