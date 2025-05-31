# Compress and encode images for embedding
cwebp -m 6 -q 10 -o small.webp orig.webp
base64 -w 0 small.webp > small.webp.b64

# Combine 5 parts to make a complete embedded html
cat \
  tarot-embedded-1-default-css.html \
  tarot-embedded-2-cross-css-body.html \
  tarot-embedded-3-avondo-images.js \
  tarot-embedded-4-mcelroy.js \
  tarot-embedded-5-deal.js \
  > celtic-cross-1880-avondo-dellarocca-embedded.html 
