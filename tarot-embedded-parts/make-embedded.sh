#!/bin/bash
prefix="tarot-embedded"
outdir="$HOME/src/Tarot-Reading-Embedded"
for layout in "cross" "story"; do
    for deck in "avondo" "ben-dov" "conver" "gumppenberg" "madenie"; do
        cat "$prefix"-1-default-css.html \
            "$prefix"-2-"$layout"-css-body.html \
            "$prefix"-3-"$deck"-images.js \
            "$prefix"-4-mcelroy-meanings.js \
            "$prefix"-5-deal.js \
            > "$outdir"/"$layout"-"$deck"-embedded.html
    done
    cat "$prefix"-1-default-css.html \
        "$prefix"-2-"$layout"-css-body.html \
        "$prefix"-3-etteilla-images.js \
        "$prefix"-4-etteilla-meanings.js \
        "$prefix"-5-deal.js \
        > "$outdir"/"$layout"-etteilla-embedded.html
    cat "$prefix"-1-default-css.html \
        "$prefix"-2-"$layout"-css-body.html \
        "$prefix"-3-waite-images.js \
        "$prefix"-4-waite-meanings.js \
        "$prefix"-5-deal.js \
        > "$outdir"/"$layout"-waite-embedded.html
done

