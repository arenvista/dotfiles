#Run this file w/ sudo 

#install rofi
echo "Installing rofi..."
pacman -S rofi

#install yay ---
echo "Installing yay..."
pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

#tmux steup ---
echo "Tmux setup..."
pacman -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# zsh install
echo "Zsh setup..."
pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# wallpaaper setup
echo "Wallpaper setup..."
pacman -S sww imagemagick jq viu
mkdir ../wallpapers/favorites
mkdir ../wallpapers/imgs

# audio setup
echo "Audio keyshortcut setup..."
pacman -S alsa-utils playerctl

# screenshot
echo "Screenshot setup..."
pacman -S grim

# lockscreen
echo "Lockscreen setup..."
pacman -S swaylock

# mouseless-kb movement
echo "mouseless-kb setup..."
yay -S wlrctl wl-kbptr

# npm
echo "misc depend..."
pacman -S npm clang firefox

echo "Finished install rebooting system; ctl-c to cancel reboot; rebooting in 10s..."
sleep 10
systemctl reboot
