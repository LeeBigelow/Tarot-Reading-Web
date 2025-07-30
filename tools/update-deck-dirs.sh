#!/bin/bash
# Note cardDeck end ]; needs to be first one in file/
deck_dir="../resources/images/"
if [[ ! -d $deck_dir ]]; then
	echo "Not a directory: $deck_dir"
	exit
fi
js_dir="../resources/js/"
deal_file="$js_dir/deal.js"
if [[ ! -e $deal_file ]]; then
	echo "File not found: $deal_file"
	exit
fi
bak_file="$deal_file.$EPOCHSECONDS.bak"

mv -v $deal_file $bak_file

sed -e '/DECKS START/q' $bak_file > $deal_file
find $deck_dir -mindepth 1 -maxdepth 1 \( -type d -o -type l \) \
	-printf "\t'%f',\n" | sort >> $deal_file
sed -n '/DECKS END/,$p' $bak_file >> $deal_file

sed -n '/const cardDeck/,/];/p' $deal_file
