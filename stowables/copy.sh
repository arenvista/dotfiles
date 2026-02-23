#!/bin/bash

# Read all directories in the current directory into an array
pkg=$(ls | fzf)
echo "Unstowing $pkg..."
stow -D "$pkg" -t ~ 2>/dev/null || true
rm -rf ~/.config/$pkg

path="/home/sybil/dotfiles-Hyprland/.config/$pkg"
echo "Creating symlink $path"
ln -s $path "/home/sybil/.config/$pkg"

ls /home/sybil/.config
echo "Done!"

