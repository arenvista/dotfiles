#!/bin/bash

# 1. Define the starting search path
search_path="$HOME/Documents"

# 2. Check if the provided path is valid
if [ ! -d "$search_path" ]; then
    echo "Error: The directory '$search_path' does not exist."
    exit 1
fi

echo "Searching for Obsidian vaults in: $search_path"
echo "---------------------------------"

# 3. Use fd to find the .obsidian folder and return its parent directory
# -H: Search hidden files/folders (required to see .obsidian)
# -t d: Look for directories only
# -p: Match against the full path
# --base-directory: Sets the context for the search
# dirname: Strips the "/.obsidian" part to give you the vault root
fd -H -t d -p "/\.obsidian$" "$search_path" --exec dirname > vaults.md

# 4. Feedback for the user
if [ -s vaults.md ]; then
    echo "Success! Vaults found and saved to vaults.md:"
    cat vaults.md
else
    echo "No Obsidian vaults found."
    rm vaults.md
fi
