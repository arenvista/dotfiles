#!/bin/bash

# Read all directories in the current directory into an array
dirs=(*/)

echo "--- PHASE 1: Breaking existing links (Unstowing) ---"
for dir in "${dirs[@]}"; do
    # ${dir%/} removes the trailing slash (e.g., "nvim/" becomes "nvim")
    pkg="${dir%/}"
    
    echo "Unstowing $pkg..."
    # We suppress errors (2>/dev/null) in case the directory 
    # wasn't previously stowed, so the script doesn't stop or complain.
    stow -D "$pkg" -t ~ 2>/dev/null || true
    rm -rf ~/.config/$pkg
done

echo "Done!"
