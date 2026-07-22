#!/bin/bash

# ram compressor; reduces swaps
sudo pacman -S --needed zram-generator

# tlp setup
sudo pacman -S --needed tlp
sudo pacman -S --needed tlp-rdw
sudo systemctl enable tlp.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
sudo tlp start
wait 1
sudo nvim /etc/tlp.conf
sudo tlp-stat -s
wait 10

yay -S throttled
systemctl enable throttled

# stress test
sudo pacman -S --needed stress-ng
stress-ng --cpu 0 --cpu-method matrixprod -t 5m

