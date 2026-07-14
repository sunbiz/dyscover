#!/usr/bin/env bash
# Render the hand-drawn SVG illustrations (for words with no emoji) to the
# 512x512 transparent PNGs the app bundles. Run after fetch_emoji_images.py.
set -euo pipefail
cd "$(dirname "$0")/.."
for n in igloo xylophone; do
  magick -background none "tools/custom/$n.svg" -resize 512x512 "assets/images/$n.png"
  echo "  rendered assets/images/$n.png"
done
