#!/bin/bash

cd "$(dirname "$0")"

[[ ! -f /etc/arch-release ]] && echo "this is for arch btw" && exit 1
[[ ! -d .config ]] && echo "cant find .config" && exit 1

install_deps() {
  sudo pacman -S --needed hyprland hyprlock hypridle kitty thunar waybar swww swaync cava fastfetch starship python-pywal kdeconnect grim slurp mpd mpc gnuplot ttf-jetbrains-mono-nerd alsa-utils networkmanager bluez bluez-utils wireplumber brightnessctl playerctl imagemagick || exit 1

  if command -v yay &>/dev/null; then
    yay -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git
  elif command -v paru &>/dev/null; then
    paru -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git
  else
    echo "no aur helper, skipping aur packages"
    echo "run: yay -S gpu-screen-recorder rmpc mpd-mpris quickshell-git pokemon-colorscripts-go"
  fi

  sudo systemctl enable --now NetworkManager 2>/dev/null
  sudo systemctl enable --now bluetooth 2>/dev/null
}
