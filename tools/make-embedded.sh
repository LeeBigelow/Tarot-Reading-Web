#!/bin/bash
for prog in cwebp base64; do
    if ! command -v $prog; then
        echo "Needed program not found: $prog"
        exit
    fi
done
srcdir=".."
outdir="."
layout="celtic-cross"
deck="2010"
meanings="mcelroy"

usage() {
    cat << EOF
Usage: ${0##*/} [-d DECK] [-l LAYOUT] [-m MEANINGS] [-o OUTPUT_DIR] [-s SOURCE_DIR ] 
    At least one option must be specified, eg -d 1880
    Will build a fully embedded html file containing specified 
    layout, deck images, and meanings.

## Defaults
Source Directory: $srcdir
Layout: $layout
Deck: $deck
Meanings: $meanings

EOF
    layout_opts=$(find "$srcdir" -maxdepth 1 -type f -name "*.html" -printf "%f\n"|sort)
    layout_opts="${layout_opts//.html/}"
    printf "## -l Layout Options:\n$layout_opts\n\n"
    
    deck_opts=$(find "$srcdir"/resources/images/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)
    printf "## -d Deck Options (Just use the year):\n$deck_opts\n\n"

    meanings_opts=$(find "$srcdir"/resources/js/ -type f -name "meanings-*.js" -printf "%f\n")
    meanings_opts="${meanings_opts//meanings-/}"
    meanings_opts="${meanings_opts//.js/}"
    printf "## -m Meanings Options:\n$meanings_opts\n\n"

    exit
}

[[ "$#" -eq 0 ]] && usage

while getopts ":d:l:m:o:s:" opt; do
    case "$opt" in
        d) deck="$OPTARG" ;;
        l) layout="$OPTARG" ;;
        m) meanings="$OPTARG" ;;
        o) outdir="$OPTARG" ;;
        s) srcdir="$OPTARG" ;;
        *) usage;;
    esac
done
shift $(( OPTIND - 1 ))

echo "Source Dir: $srcdir"
echo "Output Dir: $outdir"
echo "Layout: $layout"
echo "Deck: $deck"
echo "Meanings: $meanings"

layout_file="$srcdir/$layout.html"
default_css_file="$srcdir/resources/css/default.css" 
layout_css_file="$srcdir/resources/css/${layout##*-}.css"
meanings_file="$srcdir/resources/js/meanings-$meanings.js"
deal_file="$srcdir/resources/js/deal.js"
for f in $layout_file $default_css_file $layout_css_file $meanings_file $deal_file; do
    if [[ ! -e "$f" ]]; then
        echo "Error, file doesn't exist: $f"
        exit
    fi
done

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

embedded_file="$outdir/$layout-$deck_name-$meanings-embedded.html"
if [[ -e "$embedded_file" ]]; then
    echo "Error, file already exists: $embedded_file"
    exit
fi

sed '/<title>/q' "$layout_file" > "$embedded_file"
printf '    <style>\n'  >> "$embedded_file"
printf '/* default.css */\n' >> "$embedded_file"
sed '/^\/\* vim:/d' "$default_css_file" >> "$embedded_file"
printf "/* ${layout##*-}.css */\n" >> "$embedded_file"
sed '/^\/\* vim:/d' "$layout_css_file" >> "$embedded_file"
cat << EOF >> "$embedded_file"
    </style>
  </head>
  <body>
    <div class="content">
EOF

sed -n '/EMBEDDED START/,/EMBEDDED END/p' "$layout_file" | head -n -1 >> "$embedded_file"

printf '    <script>\n' >> "$embedded_file"

# Card Images
printf "// $deck_name images\n" >> "$embedded_file"
printf 'const cardImages = {\n' >> "$embedded_file"
for img in $(ls "$deck_dir"); do
    echo "base64 encoding $img..."
    printf "    ${img%.webp}: '" >> "$embedded_file"
    cwebp -quiet -m 6 -q 10 -o - "$deck_dir/$img" | base64 -w 0 >> "$embedded_file"
    printf "',\n" >> "$embedded_file"
done
printf '};\n' >> "$embedded_file"

# Meanings
printf "// meanings-$meanings.js\n" >> "$embedded_file"
sed -e 's/\/\/ var meaningsAuthor/var meaningsAuthor/' \
    -e "s/${meanings}Meanings/cardMeanings/"  "$meanings_file" >> "$embedded_file" 

# Deal
printf "// deal.js\n" >> "$embedded_file"
sed -e '/EMBEDDED IGNORE START/,/EMBEDDED IGNORE END/d' \
    -e '/imageFront.src =/c\
    imageFront.src = "data:image/webp;base64," + cardImages[cardCode];' \
    -e '/MEANINGS START/q' "$deal_file" >> "$embedded_file" 
cat << EOF >> "$embedded_file"
        default:
            cardBackDiv.innerHTML += cardMeanings[cardCode];
            cardBackDiv.innerHTML += '<p class="author">-- '+meaningsAuthor+'</p>'; 
            break;
EOF
sed -n -e '/^changeDeck(getRandomDeck/d; /MEANINGS END/,$p' "$deal_file" >> "$embedded_file"
cat << EOF >> "$embedded_file"
var selectedDeck = "$deck_name";
deckTitle.innerHTML = selectedDeck.replace(/_/g,' ');

backingImage.src = "data:image/webp;base64," + cardImages['XBA'];
backingImage.alt = backingImage.src;
    </script>
  </body>
</html>
EOF
