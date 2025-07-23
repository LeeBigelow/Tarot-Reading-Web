#!/bin/bash
tmpdir=$(mktemp -d "8color.XXXX")
outf=color-sep-$(basename "${1%.???}").jpg
img="$1"
numc="$2"
[ -z "$numc" ] && numc=8

magick "$1" -colors $numc -unique-colors txt: \
| cut -d " " -f 4 \
| tail -n +2 \
| parallel "magick "$1" -colors $numc -depth 8 +transparent {} -flatten $tmpdir/{}.jpg"

magick montage -geometry 200x353 -font 'FreeSans' -label '%t' "$1" "$tmpdir/*.jpg" "$outf"

rm -fr "$tmpdir"
pqiv "$outf" &

