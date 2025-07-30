#!/bin/bash
cd ../
layout_files=$(find . -mindepth 1 -maxdepth 1 -type f -name "*.html" \
	-printf "%f\n" | sort)

# build layout block
layout_block="\t\t\t\t\t<!-- LAYOUTS START -->\n"
for layout in $layout_files; do
	layout_title=$(xmllint --html --xpath '//h1/text()' $layout)
	layout_block+="\t\t\t\t\t<div><a href=\"$layout\">"
	layout_block+="$layout_title</a></div>\n"
done
layout_block+="\t\t\t\t\t<!-- LAYOUTS END -->"

for layout in $layout_files; do
	mv $layout $layout.bak
	sed "/LAYOUTS START/,/LAYOUTS END/c\\$layout_block" $layout.bak > $layout 
done

