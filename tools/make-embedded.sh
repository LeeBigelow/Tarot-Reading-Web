#!/bin/bash
for prog in cwebp base64; do
	if ! command -v $prog; then
		echo "Needed program not found: $prog"
		exit
	fi
done
srcdir=".."
outdir="."
deck="2010"
meanings="mcelroy"

usage() {
	cat << EOF
Usage: ${0##*/} [-d DECK] [-m MEANINGS] [-o OUTPUT_DIR] [-s SOURCE_DIR ]
    At least one option must be specified, eg -d 1880
    Will build a fully embedded html file containing specified
    layout, deck images, and meanings.

## Defaults
Source Directory: $srcdir
Deck: $deck
Meanings: $meanings

EOF
	deck_opts=$(find "$srcdir"/resources/images/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)
	printf "## -d Deck Options (Just use the year):\n$deck_opts\n\n"

	meanings_opts=$(find "$srcdir"/resources/js/ -type f -name "meanings-*.js" -printf "%f\n" | sed 's/meanings-//; s/\.js//')
	printf "## -m Meanings Options:\n$meanings_opts\n\n"

	exit
}

[[ "$#" -eq 0 ]] && usage

while getopts ":d:l:m:o:s:" opt; do
	case "$opt" in
		d) deck="$OPTARG" ;;
		m) meanings="$OPTARG" ;;
		o) outdir="$OPTARG" ;;
		s) srcdir="$OPTARG" ;;
		*) usage;;
	esac
done
shift $(( OPTIND - 1 ))

echo "Source Dir: $srcdir"
echo "Output Dir: $outdir"
echo "Deck: $deck"
echo "Meanings: $meanings"

default_css_file="$srcdir/resources/css/default.css"
meanings_file="$srcdir/resources/js/meanings-$meanings.js"
deal_file="$srcdir/resources/js/deal.js"
index_file="$srcdir/index.html"

# check for files
for f in $index_file $default_css_file $meanings_file $deal_file; do
	if [[ ! -e "$f" ]]; then
		echo "Error, file doesn't exist: $f"
		exit
	fi
done

layout_files=$(find "$srcdir/resources/js/" -type f -name "layout-*.js") 
if [[ -z "$layout_files" ]]; then
	echo "Error, no layout-*.js files in $srcdir/resources/js"
	exit
fi

deck_name=$(find "$srcdir/resources/images/" -type d -name "$deck*" -printf "%f")
if [[ -z "$deck_name" ]]; then
	echo "Error, not a valid deck year: $deck"
	exit
fi

deck_dir="$srcdir/resources/images/$deck_name"
if [[ ! -d "$outdir" ]]; then
	echo "Not a directory: $outdir"
	exit
fi

embedded_file="$outdir/$deck_name-$meanings-embedded.html"
if [[ -e "$embedded_file" ]]; then
	echo "Error, file already exists: $embedded_file"
	exit
fi

# Find or create b64 card images
b64_file="$deck_name-b64.js"
if [[ ! -e "$b64_file" ]]; then
	echo "Caching b64 images in file: $b64_file"
	printf "// $deck_name images\n" >> "$b64_file"
	printf 'const cardImages = {\n' >> "$b64_file"
	for img in $(ls "$deck_dir"); do
		echo "base64 encoding $img..."
		printf "\t${img%.webp}: '" >> "$b64_file"
		cwebp -quiet -m 6 -q 10 -o - "$deck_dir/$img" | base64 -w 0 >> "$b64_file"
		printf "',\n" >> "$b64_file"
	done
	printf '};\n' >> "$b64_file"
fi
if [[ ! -e "$b64_file" ]]; then
	echo "Error, not found and couldn't create: $b64_file"
	exit
fi

# Add default style sheet to head
sed '/<title>/q' "$index_file" > "$embedded_file"
printf '\t\t<style>\n' >> "$embedded_file"
printf '\t\t\t/* default.css */\n' >> "$embedded_file"
sed 's/^/\t\t\t/' "$default_css_file" >> "$embedded_file"
printf '\t\t</style>\n' >> "$embedded_file"

sed -n -e '/DECKS MENU START/,/DECKS MENU END/d' \
	-e '/<style/,/SCRIPTS START/p' "$index_file" >> "$embedded_file" 

# Add Javascript files 
printf '\t\t<script>\n' >> "$embedded_file"

# Add layout js files
for layout_js in $layout_files; do
	printf "\t\t\t// $layout_js\n" >> "$embedded_file"
	sed 's/^/\t\t\t/' "$layout_js" >> "$embedded_file"
done

# Add b64 card Images
sed 's/^/\t\t\t/' "$b64_file" >> "$embedded_file"

# Meanings, uncomment author and set default meanings 
printf "\n\t\t\t// meanings-$meanings.js\n" >> "$embedded_file"
sed -e 's/\/\/ var meaningsAuthor/var meaningsAuthor/' \
	-e "s/${meanings}Meanings/cardMeanings/"  \
	-e 's/^/\t\t\t/' "$meanings_file" >> "$embedded_file"

# Deal.js switch to base64 images
printf "\t\t\t// deal.js\n" >> "$embedded_file"
sed -e '/EMBEDDED IGNORE START/,/EMBEDDED IGNORE END/d' \
	-e 's/^/\t\t\t/' \
	-e '/deckImage.src =/c\\t\t\t\tdeckImage.src = "data:image/webp;base64," + cardImages["XBA"];' \
	-e '/imageFront.src =/c\\t\t\t\timageFront.src = "data:image/webp;base64," + cardImages[cardCode];' \
	-e '/MEANINGS START/q' "$deal_file" >> "$embedded_file"

# Waite deck with McElroy meanings
if [[ "$deck" == "1909" && "$meanings" == "mcelroy" ]]; then 
	cat << EOF | sed 's/^/\t\t\t/' >> "$embedded_file"
	default:
		// Waite deck with McElroy meanings
		// swap Justice and Strength cards
		if (cardCode == 'T08') {
			cardCode='T11';
			cardBackDiv.innerHTML += cardMeanings[cardCode].replace('11','8');
		} else if (cardCode == 'T11') {
			cardCode='T08';
			cardBackDiv.innerHTML += cardMeanings[cardCode].replace('8','11');
		} else {
			cardBackDiv.innerHTML += cardMeanings[cardCode];
		}
		cardBackDiv.innerHTML += '<p class="author">-- '+meaningsAuthor+'</p>';
		break;
EOF
# Deal.js selected meanings option
else
	cat << EOF | sed 's/^/\t\t\t/' >> "$embedded_file"
	default:
		cardBackDiv.innerHTML += cardMeanings[cardCode];
		cardBackDiv.innerHTML += '<p class="author">-- '+meaningsAuthor+'</p>';
		break;
EOF
fi

# Deal.js tail end without setting random deck
sed -n -e 's/^/\t\t\t/' \
	-e '/layoutInit(getRandom/d' \
	-e '/MEANINGS END/,$p' "$deal_file" >> "$embedded_file"

# Deal.js set specified deck, close script and html
cat << EOF >> "$embedded_file"
			layoutInit(getRandomLayout(), "$deck_name");
		</script>
	</body>
</html>
EOF

# Clean trailing whitespace (and whitespace only lines)
sed -i 's/[ \t]\+$//' "$embedded_file"

