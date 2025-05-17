#!/bin/bash
fname="$1"
oldcolor="$2"
if [ ! -e "$fname" ]; then
    echo "USAGE: ${0##*/} IMAGE_FILE OLD_COLOR"
fi

newcolor=$(magick xc:"$oldcolor" -depth 8 -modulate 60% txt: \
            | tail -n 1 \
            | cut -d " " -f 4)

echo $oldcolor $newcolor

# replace color and ajust contrast
magick "$fname" -fuzz 10% -fill "$newcolor" -opaque "$oldcolor" \
                -level 10% darken-"$fname"
