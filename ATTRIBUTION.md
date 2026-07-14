# Third-party assets

## Picture artwork: Noto Emoji

The picture tiles (`assets/images/*.png`, except the generated placeholder tiles
for igloo, xylophone, and yak) are colour emoji from Google's **Noto Emoji**.

- Source: https://github.com/googlefonts/noto-emoji
- License: Apache License 2.0
- Fetched by `tools/fetch_emoji_images.py`

Noto Emoji is licensed under the Apache License, Version 2.0. You may obtain a
copy of the license at http://www.apache.org/licenses/LICENSE-2.0

## Placeholder tiles and audio

`assets/images/{igloo,xylophone,yak}.png` and all clips under `assets/audio/`
are generated locally by `tools/gen_placeholder_assets.py` (macOS `say` +
ImageMagick) as placeholders pending real recordings and artwork.
