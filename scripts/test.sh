#!/bin/bash

# This sets up the environment for the test
pacman -Syu --noconfirm neovim sudo
useradd -m -G wheel testuser
echo "testuser ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/testuser
echo "testuser:nsth" | chpasswd
mv /.dotfiles /home/testuser
cd /home/testuser/.dotfiles
su testuser
sh setup.sh
