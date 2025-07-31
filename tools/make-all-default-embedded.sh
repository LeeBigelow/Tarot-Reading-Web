#!/bin/bash
#mcelroy meanings
for deck in 1709 1760 1835 1880 1909 2010; do
	./make-embedded.sh -d $deck -m "mcelroy"
done

#etteilla
./make-embedded.sh -d 1789 -m "etteilla"

#waite
./make-embedded.sh -d 1909 -m "waite"

./make-embedded.sh -d 2010 -m "bendov"
