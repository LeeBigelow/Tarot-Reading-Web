#!/bin/bash
layout_opts=$(find ../ -maxdepth 1 -type f -name "*.html" -printf "%f\n" \
	| sed 's/\.html$//')

#mcelroy
for deck in 1709 1760 1835 1880 2010; do
	for layout in $layout_opts; do
		./make-embedded.sh -d $deck -l $layout -m "mcelroy"
	done
done

#etteilla
for layout in $layout_opts; do 
	./make-embedded.sh -d 1789 -l $layout -m "etteilla"
done

#waite
for layout in $layout_opts; do
	./make-embedded.sh -d 1909 -l $layout -m "waite"
done

#bendov
for layout in $layout_opts; do
	./make-embedded.sh -d 2010 -l $layout -m "bendov"
done
