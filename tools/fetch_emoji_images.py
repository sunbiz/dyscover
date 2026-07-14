#!/usr/bin/env python3
"""Fetch real picture artwork for the Dyscover ABC kiosk.

Replaces the placeholder letter-tiles (see gen_placeholder_assets.py) with
recognizable emoji artwork from Google's Noto Emoji, which is Apache-2.0
licensed (permissive, attribution in NOTICE). Each word maps to a Unicode
emoji; we download the 512x512 colour PNG to assets/images/<word>.png.

A few phonics words have no emoji (igloo, xylophone, yak); those keep their
generated placeholder tile. Re-run any time; it overwrites in place.

Run order: gen_placeholder_assets.py first (audio + content + fallback tiles),
then this script to upgrade the images.
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IMAGES = ROOT / "assets" / "images"
BASE = "https://raw.githubusercontent.com/googlefonts/noto-emoji/main/png/512"

# word -> Unicode code point(s) for the Noto file name (lowercase, no FE0F).
EMOJI = {
    "apple": "1f34e",
    "ball": "26bd",       # soccer ball
    "cat": "1f431",
    "dog": "1f436",
    "elephant": "1f418",
    "fish": "1f41f",
    "goat": "1f410",
    "hat": "1f3a9",       # top hat
    "jug": "1f3fa",       # amphora (jug-like vessel)
    "kite": "1fa81",
    "lion": "1f981",
    "monkey": "1f435",
    "nest": "1faba",      # nest with eggs
    "orange": "1f34a",    # tangerine
    "pig": "1f437",
    "queen": "1f451",     # crown
    "rabbit": "1f430",
    "sun": "2600",
    "tree": "1f333",
    "umbrella": "2602",
    "van": "1f690",       # minibus
    "watch": "231a",
    "yak": "1f402",       # ox (closest bovine; no yak emoji exists)
    "zebra": "1f993",
}

# No emoji at all: these use hand-drawn SVGs in tools/custom/, rendered by
# tools/render_custom_images.sh.
NO_EMOJI = ["igloo", "xylophone"]


def fetch(word: str, code: str) -> bool:
    out = IMAGES / f"{word}.png"
    url = f"{BASE}/emoji_u{code}.png"
    r = subprocess.run(
        ["curl", "-fsSL", "--retry", "3", url, "-o", str(out)],
        capture_output=True,
    )
    if r.returncode != 0:
        return False
    # sanity: a PNG starts with the 8-byte signature
    with open(out, "rb") as f:
        return f.read(8) == b"\x89PNG\r\n\x1a\n"


def main() -> int:
    IMAGES.mkdir(parents=True, exist_ok=True)
    ok, bad = 0, []
    for word, code in EMOJI.items():
        if fetch(word, code):
            ok += 1
            print(f"  {word:10s} <- U+{code.upper()}")
        else:
            bad.append(word)
            print(f"  {word:10s} FAILED (U+{code.upper()})")
    print(f"fetched {ok}/{len(EMOJI)} emoji images")
    print(f"custom SVG illustrations for: {', '.join(NO_EMOJI)} "
          f"(run tools/render_custom_images.sh)")
    if bad:
        print(f"WARNING: failed: {', '.join(bad)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
