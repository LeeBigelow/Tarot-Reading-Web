#!/bin/bash
js_dir="../resources/js"
htmld="../resources/html"
cssd="../resources/css"

layouts=$(find $htmld -type f -name "*.html" -printf "%f\n" | sed 's/.html$//')

for layout in $layouts; do
	echo "-- $layout --"
	js_file="$js_dir/layout-$layout.js"
	# get number layout cards from "card" lines
	num_cards=$(grep 'class="card"' "$htmld/$layout.html" | wc -l)

	# page title with number of cards for layout
	printf "${layout}_title = \'Tarot Reading Web - ${layout^} - $num_cards\';\n\n" > $js_file

	# html for layout
	printf "${layout}_html = \`\n" >> $js_file
	sed 's/^/\t/' "$htmld/${layout}.html" >> $js_file
	printf "\`;\n\n" >> $js_file

	# css for layout
	printf "${layout}_css = \`\n" >> $js_file
	sed 's/^/\t/' "$cssd/${layout}.css" >> $js_file
	printf "\`;\n\n" >> $js_file
done
