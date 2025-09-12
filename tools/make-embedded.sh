#!/bin/bash
for prog in cwebp base64; do
	if ! command -v $prog; then
		echo "Needed program not found: $prog"
		exit
	fi
done
srcdir=".."
outdir="./embedded"
mkdir -p "$outdir"
b64dir="./decks-b64-js"
mkdir -p "$b64dir"
deckpath=""
meanings=""

usage() {
	cat << EOF
Usage: ${0##*/} [-o OUTPUT_DIR] [-s SOURCE_DIR ] DECK_PATH
	DECK_PATH name contains "(MEANING)" to use.
    Will build a fully embedded html file containing specified
    layout, deck images, and meanings.
EOF
	exit 1
}

[[ "$#" -eq 0 ]] && usage

while getopts ":o:s:" opt; do
	case "$opt" in
		o) outdir="$OPTARG" ;;
		s) srcdir="$OPTARG" ;;
		*) usage;;
	esac
done
shift $(( OPTIND - 1 ))

deckpath="$1"
if [[ ! -d "$deckpath" ]]; then
	echo "Not a directory: $deckpath"
	usage
fi

deckpath="${deckpath%/}"

#deckname for cached b64 images
deckname="${deckpath##*/}"
deckname="${deckname%_(*}"

meanings="${deckpath##*(}" 
meanings="${meanings%)*}" 
# lower case, remove ben-dov hypen
meanings="${meanings@L}"
meanings="${meanings/-/}"

echo "Source Dir: $srcdir"
echo "Output Dir: $outdir"
echo "Deck Dir: $deckpath"
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

layout_files=$(find "$srcdir/resources/js/" \( -type f -o -type l \) -name "layout-*.js") 
if [[ -z "$layout_files" ]]; then
	echo "Error, no layout-*.js files in $srcdir/resources/js"
	exit
fi

if [[ ! -d "$outdir" ]]; then
	echo "Not a directory: $outdir"
	exit
fi

embedded_file="$outdir/${deckpath##*/}-embedded.html"
if [[ -e "$embedded_file" ]]; then
	echo "Error, file already exists: $embedded_file"
	exit
fi

# Find or create b64 card images
b64_file="$b64dir/$deckname-b64.js"
if [[ ! -e "$b64_file" ]]; then
	echo "Caching b64 images in file: $b64_file"
	printf "// $deckname images\n" >> "$b64_file"
	printf 'const cardImages = {\n' >> "$b64_file"
	for img in $(ls "$deckpath"); do
		echo "base64 encoding $img..."
		printf "\t${img%.webp}: '" >> "$b64_file"
		cwebp -quiet -m 6 -q 10 -o - "$deckpath/$img" | base64 -w 0 >> "$b64_file"
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
if [[ "$deckname" == *"Rider-Waite-Smith"* && "$meanings" == "mcelroy" ]]; then 
	echo "Waite with McElroy so Switching Justice and Strength cards..."
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
else
	# set default meanings to embedded ones 
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
			layoutInit(getRandomLayout(), "${deckpath##*/}");
		</script>
	</body>
</html>
EOF

# Clean trailing whitespace (and whitespace only lines)
sed -i 's/[ \t]\+$//' "$embedded_file"

echo "Created: $embedded_file"
