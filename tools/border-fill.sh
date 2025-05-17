#!/bin/bash
fname="$1"
fillcolor="$2"
fuzz="$3"
if [ ! -e "$fname" ]; then
    echo "USAGE: ${0##*/} IMAGE_FILE FILL_COLOR"
    exit
fi
[ -z "$fillcolor" ] && fillcolor="$(magick "$fname" -resize 1x1 txt: \
                                    | tail -n 1 | cut -d ' ' -f 4)"
[ -z "$fuzz" ] && fuzz="5"

magick "$fname" -fuzz ${fuzz}% -fill "$fillcolor" -draw 'color 0,0 floodfill' fill-"$fname"
