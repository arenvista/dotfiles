#!/bin/bash
# Read all directories in the current directory into an array
dirs=(*/)

# call stow -D dir -t ~ for each directory
for dir in "${dirs[@]}"; do
    echo "Stowing $dir"
    stow -D "$dir" -t ~
    stow "$dir" -t ~ --adopt
done
