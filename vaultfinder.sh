#!/bin/bash

# 1. Define the directory string "path"
# Change this to your actual starting directory (e.g., /home/user or .)
search_path="$HOME/Documents"

# 2. Check if the provided path is valid before running
if [ ! -d "$search_path" ]; then
    echo "Error: The directory '$search_path' does not exist."
    exit 1
fi

echo "Searching in: $search_path"
echo "---------------------------------"

# 3. Find directories named "Notes" and print the full path to "vaults.md"
# -type d: looks for directories only
# -name "Notes": looks for folders with this exact name
# -exec echo ...: appends /vaults.md to the found path and prints it
search_term="Vault"
find "$search_path" -type d -name $search_term -exec echo "{}/vaults.md" \;
