#!/bin/bash
sudo apt-install git tmux zsh neofetch fzf ripgrep stow nvim 
cd ./stowables 
exec symlinks.sh
