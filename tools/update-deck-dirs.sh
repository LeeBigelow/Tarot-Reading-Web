#!/bin/bash
# Note cardDeck end ]; needs to be first one in file
oldf="../resources/js/deal.js"
newf="../resources/js/new-deal.js"
sed -e '/DECKS START/q' $oldf > $newf
echo "$(ls ../resources/images/)" | sed "s/^/    '/; s/$/',/" >> $newf
sed -n '/DECKS END/,$p' $oldf >> $newf
mv $oldf $oldf.$EPOCHSECONDS.bak
mv $newf $oldf

echo "UPDATED..."
sed -n '/const cardDeck/,/];/p' $oldf
