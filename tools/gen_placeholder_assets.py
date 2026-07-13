#!/usr/bin/env python3
"""Generate placeholder content + media for the Dyscover ABC kiosk.

This produces *placeholders* so the app runs before real recordings and
artwork exist (see the build plan, section 3). It writes:

  assets/content.json          A-Z letters + a picture set
  assets/audio/letters/*.wav   letter name + phonic sound clips
  assets/audio/words/*.wav     example-word clips
  assets/images/*.png          simple labelled tiles per word

Requirements (macOS dev machine):
  - `say`   (built-in TTS)      -> WAV clips
  - `magick`(ImageMagick)       -> PNG tiles

Real, pre-recorded human voice and real artwork should replace these later;
gstreamer on the Pi plays any common format, so recordings can be wav/mp3/m4a.
Re-run this script any time to regenerate; it overwrites in place.
"""

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
FONT = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
VOICE = "Samantha"          # clear en_US voice
DATA_FORMAT = "LEI16@22050"  # 16-bit PCM, 22.05kHz mono WAV

# letter, example word, phonic sound (spelled for TTS), tile colour (white text)
LETTERS = [
    ("A", "Apple",     "ah",   "#E8563F"),
    ("B", "Ball",      "buh",  "#3FA34D"),
    ("C", "Cat",       "kuh",  "#4C8BF5"),
    ("D", "Dog",       "duh",  "#E28413"),
    ("E", "Elephant",  "eh",   "#9B59B6"),
    ("F", "Fish",      "fuh",  "#1ABC9C"),
    ("G", "Goat",      "guh",  "#E74C3C"),
    ("H", "Hat",       "huh",  "#2E9E5B"),
    ("I", "Igloo",     "ih",   "#3498DB"),
    ("J", "Jug",       "juh",  "#E67E22"),
    ("K", "Kite",      "kuh",  "#16A085"),
    ("L", "Lion",      "luh",  "#D35400"),
    ("M", "Monkey",    "muh",  "#8E44AD"),
    ("N", "Nest",      "nuh",  "#27AE60"),
    ("O", "Orange",    "oh",   "#E8912D"),
    ("P", "Pig",       "puh",  "#C0392B"),
    ("Q", "Queen",     "kwuh", "#2980B9"),
    ("R", "Rabbit",    "ruh",  "#D6336C"),
    ("S", "Sun",       "sss",  "#C99700"),
    ("T", "Tree",      "tuh",  "#00A884"),
    ("U", "Umbrella",  "uh",   "#6C5CE7"),
    ("V", "Van",       "vuh",  "#D63031"),
    ("W", "Watch",     "wuh",  "#0984E3"),
    ("X", "Xylophone", "ks",   "#7C6CE0"),
    ("Y", "Yak",       "yuh",  "#E0A020"),
    ("Z", "Zebra",     "zzz",  "#566573"),
]

# words that also appear as their own tappable pictures (reuse letter media)
PICTURE_WORDS = [
    "Apple", "Ball", "Cat", "Dog", "Elephant", "Fish",
    "Kite", "Lion", "Orange", "Sun", "Tree", "Zebra",
]


def word_key(word: str) -> str:
    return word.lower()


def say_wav(text: str, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["say", "-v", VOICE, "--data-format", DATA_FORMAT, "-o", str(out), text],
        check=True,
    )


def tile_png(letter: str, word: str, color: str, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "magick", "-size", "480x480", f"xc:{color}",
            "-gravity", "center", "-fill", "white", "-font", FONT,
            "-pointsize", "210", "-annotate", "+0-40", letter,
            "-pointsize", "64", "-annotate", "+0+150", word,
            str(out),
        ],
        check=True,
    )


def build_content() -> dict:
    letters = []
    for letter, word, _sound, color in LETTERS:
        wk = word_key(word)
        letters.append({
            "id": letter,
            "label": letter,
            "color": color,
            "example_word": word,
            "name_audio": f"audio/letters/{letter}_name.wav",
            "sound_audio": f"audio/letters/{letter}_sound.wav",
            "word_audio": f"audio/words/{wk}.wav",
            "image": f"images/{wk}.png",
        })

    # index colours by word so pictures reuse the letter tile's colour
    color_by_word = {word_key(w): c for _l, w, _s, c in LETTERS}
    pictures = []
    for word in PICTURE_WORDS:
        wk = word_key(word)
        pictures.append({
            "id": wk,
            "label": word,
            "image": f"images/{wk}.png",
            "word_audio": f"audio/words/{wk}.wav",
        })
        _ = color_by_word  # (colours already baked into the shared images)

    return {"letters": letters, "pictures": pictures}


def main() -> int:
    content = build_content()
    (ASSETS).mkdir(parents=True, exist_ok=True)
    (ASSETS / "content.json").write_text(json.dumps(content, indent=2) + "\n")
    print(f"wrote {ASSETS/'content.json'}")

    for letter, word, sound, color in LETTERS:
        say_wav(letter, ASSETS / f"audio/letters/{letter}_name.wav")
        say_wav(sound, ASSETS / f"audio/letters/{letter}_sound.wav")
        wk = word_key(word)
        say_wav(word, ASSETS / f"audio/words/{wk}.wav")
        tile_png(letter, word, color, ASSETS / f"images/{wk}.png")
        print(f"  {letter} -> name/sound + {wk}.wav + {wk}.png")

    print("done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
