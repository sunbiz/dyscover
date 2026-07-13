# Dyscover: ABC Learning Kiosk

A touch-first learning app for young children: tap a **letter** to hear its
name and phonic sound, or tap a **picture** to hear the word. It's built to run
fullscreen and native on a Raspberry Pi via
[**flutter-pi**](https://github.com/ardera/flutter-pi) (DRM/KMS, no browser, no
desktop), but also runs on any normal Flutter target for development.

All content is data-driven from [`assets/content.json`](assets/content.json)
plus bundled audio and images.

## Project layout

```
lib/main.dart                    the whole app (Home -> Letters / Pictures)
assets/content.json              A-Z letters + the picture set
assets/audio/letters/*.wav       letter name + phonic sound clips
assets/audio/words/*.wav         example-word clips
assets/images/*.png              per-word tiles
tools/gen_placeholder_assets.py  regenerates the placeholder media
abc_learning_app_flutterpi_plan.md   full build/ship plan for the Pi
```

## Run it (dev machine)

```bash
flutter pub get
flutter run                      # on a connected device / desktop
flutter test                     # smoke tests
flutter analyze                  # lints
```

## Ship it to the Raspberry Pi

The concrete, tested deploy recipe plus the systemd unit and ALSA config live in
[`deploy/`](deploy/). The narrative background (why each step) is in
[`abc_learning_app_flutterpi_plan.md`](abc_learning_app_flutterpi_plan.md).
In short, from the dev machine:

```bash
# IMPORTANT: flutter-pi's prebuilt engine lags the newest Flutter stable.
# Build with Flutter 3.41.x. Newer stables (3.44+) have no matching flutter-pi
# engine yet, so flutterpi_tool reports "engine not yet available".
flutter pub global activate flutterpi_tool
flutterpi_tool build --arch=arm64 --cpu=pi4 --release   # -> build/flutter-pi/pi4-64/
rsync -a --delete ./build/flutter-pi/pi4-64/ USER@PI_HOST:/opt/abc-app/
ssh USER@PI_HOST sudo systemctl restart abc-kiosk
```

The Pi runs the app via a systemd service (`abc-kiosk`) on tty1 and boots
straight into it (console default target, no desktop). Audio goes out HDMI via
`/etc/asound.conf` pointing at the vc4hdmi card the panel is on.

## Content & media

The checked-in audio/images are **placeholders** generated on macOS (`say` +
ImageMagick) so the app runs before real recordings and artwork exist:

```bash
python3 tools/gen_placeholder_assets.py
```

Replace them with pre-recorded human voice and real artwork when available.
Gstreamer on the Pi plays any common format (wav/mp3/m4a). To add a letter or
picture, drop the media in `assets/` and add an entry to `content.json`, then
rebuild the bundle (assets are baked in at build time).

> Note: `.env` (e.g. Pi SSH credentials) is git-ignored and must never be
> committed.
