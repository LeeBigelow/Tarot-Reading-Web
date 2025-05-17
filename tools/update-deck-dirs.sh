#!/bin/bash
# Note cardDeck end ]; needs to be first one in file
oldf="../resources/js/tarot-deal.js"
newf="../resources/js/new-tarot-deal.js"
sed -e '/const cardDeck/q' $oldf > $newf
echo "$(ls ../resources/images/)" | sed "s/^/  '/; s/$/',/" >> $newf
sed -n '/];/,$p' $oldf >> $newf
mv $oldf $oldf.$EPOCHSECONDS.bak
mv $newf $oldf

echo "UPDATED..."
sed -n '/const cardDeck/,/];/p' $oldf
