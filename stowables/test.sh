#!/usr/bin/env bash

mkdir -p "$HOME/.cache/wallpaper-thumbs"
cd "$HOME/.cache/wallpaper-thumbs" || exit 1

if command -v vipsthumbnail >/dev/null 2>&1; then
    SRC="$HOME/wallpapers"
else
    SRC="/home/sybil/dotfiles/stowables/wallpapers/wallpapers/favorites"
fi

find "$SRC" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \) \
    ! -name '.*' |
while IFS= read -r f; do
    hash=$(printf '%s' "$f" | md5sum | cut -d' ' -f1)
    thumb="$HOME/.cache/wallpaper-thumbs/${hash}.jpg"

    if [ ! -f "$thumb" ] || [ "$f" -nt "$thumb" ]; then
        case "$f" in
            *.gif)
                convert "${f}[0]" \
                    -define jpeg:size=400x300 \
                    -thumbnail 180x120^ \
                    -gravity center -extent 180x120 \
                    -strip -interlace none -quality 85 \
                    "$thumb" 2>/dev/null &
                ;;
            *)
                if command -v vipsthumbnail >/dev/null 2>&1; then
                    vipsthumbnail "$f" -s 180x120 \
                        --crop centre \
                        -o "$thumb[Q=85,strip]" 2>/dev/null ||
                    convert "$f" \
                        -define jpeg:size=400x300 \
                        -thumbnail 180x120^ \
                        -gravity center -extent 180x120 \
                        -strip -interlace none -quality 85 \
                        "$thumb" 2>/dev/null &
                else
                    convert "$f" \
                        -define jpeg:size=400x300 \
                        -thumbnail 180x120^ \
                        -gravity center -extent 180x120 \
                        -strip -interlace none -quality 85 \
                        "$thumb" 2>/dev/null &
                fi
                ;;
        esac
    fi
done

wait
