#!/bin/bash
# Note cardDeck end ]; needs to be first one in file/
imgd="../resources/images/"
oldf="../resources/js/deal.js"
newf="new-deal.js"
sed -e '/DECKS START/q' $oldf > $newf
find $imgd -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -printf "\t'%f',\n" \
	| sort >> $newf
sed -n '/DECKS END/,$p' $oldf >> $newf
mv $oldf $newf.$EPOCHSECONDS.bak
mv $newf $oldf

echo "UPDATED..."
sed -n '/const cardDeck/,/];/p' $oldf
