# ABC Learning Kiosk — flutter-pi (native) Build & Ship Plan

Native alternative to the Chromium-kiosk plan. Flutter runs directly on the Pi's GPU via DRM/KMS — no browser, no X11, no Wayland compositor. Fast boot, low RAM, AOT-compiled native ARM code.

**Device:** Raspberry Pi 4B (2GB), 10.1" USB-HID capacitive touchscreen (EM101TP-C) over HDMI (video+audio) + USB-C (touch). Audio already defaulted to HDMI.
**Two machines are involved:** a **dev machine** (the computer Claude Code runs on — Linux/macOS x86_64 is fine) that builds the app, and the **Pi** that runs it. **You cannot build on the Pi.**

---

## 0. The shipping model (read first)

```
[dev machine]                                   [Raspberry Pi]
 flutter SDK + flutterpi_tool                    flutter-pi binary (built from source)
   │                                               │
   │  flutterpi_tool build --arch=arm64            │
   │      --cpu=pi4 --release                       │
   ▼                                               ▼
 build/flutter_assets/  ──── rsync over SSH ───▶  /opt/abc-app/
                                                    │
                                          systemd runs: flutter-pi --release /opt/abc-app
```

flutterpi_tool downloads the correct engine binaries for the target and cross-builds the Dart AOT snapshot + asset bundle on the dev machine — the Pi's CPU is never used for building. The Pi only needs the `flutter-pi` runtime binary and the bundle.

---

## 1. Prepare the Pi (one-time, over SSH)

**1.1 Boot to console (no desktop).** flutter-pi owns the display directly; a desktop compositor would fight it for KMS.
```bash
sudo raspi-config nonint do_boot_behaviour B1   # B1 = console, no autologin
```

**1.2 Install flutter-pi build dependencies — plus gstreamer BEFORE building** (so the built-in audio/video plugins compile into flutter-pi):
```bash
sudo apt update
sudo apt install -y cmake git build-essential pkg-config \
  libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev \
  fontconfig libsystemd-dev libinput-dev libudev-dev libxkbcommon-dev ttf-mscorefonts-installer \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  gstreamer1.0-alsa gstreamer1.0-libav
```

**1.3 Build and install the flutter-pi binary:**
```bash
cd ~ && git clone https://github.com/ardera/flutter-pi
cd flutter-pi && mkdir -p build && cd build
cmake ..
make -j"$(nproc)"
sudo make install          # -> /usr/local/bin/flutter-pi
flutter-pi --help          # sanity check
```

**1.4 Give the runtime user access to GPU + input devices:**
```bash
sudo usermod -aG video,input,render "$USER"     # log out/in (or reboot) to apply
```

**1.5 Point ALSA at HDMI** (console mode has no PipeWire; audioplayers/gstreamer talks straight to ALSA). Find the HDMI card name, then set it as default. Create `/etc/asound.conf`:
```bash
aplay -l    # note the vc4-hdmi card name, e.g. "vc4hdmi0"
```
```
# /etc/asound.conf
pcm.!default { type plug slave.pcm { type hw card vc4hdmi0 } }
ctl.!default { type hw card vc4hdmi0 }
```
Verify: `speaker-test -D default -c2 -t wav` should play through the panel. If HDMI audio doesn't appear at all, add `hdmi_force_edid_audio=1` to `/boot/firmware/config.txt` and reboot (cheap panels sometimes omit audio from their EDID).

> Do **not** install/keep classic `pulseaudio` — it can block the flutter-pi audio plugin. On Bookworm console mode it usually isn't running anyway.

---

## 2. Prepare the dev machine (one-time, where Claude Code runs)

```bash
# Install Flutter SDK (stable). https://docs.flutter.dev/get-started/install
flutter --version            # must be a recent stable (>= 3.29 recommended)
flutter pub global activate flutterpi_tool
# ensure the dart pub global bin dir is on PATH; then:
flutterpi_tool --help
```
Register the Pi as a target device (lets you use `flutterpi_tool run` for fast iteration):
```bash
flutterpi_tool devices add USER@PI_HOST --id=abc-pi --display-size=217x136
# display-size is the panel's physical size in mm (10.1" 16:10 ≈ 217×136); tune for correct DPI/scaling
```

---

## 3. The Flutter app (scaffold — extend, don't rewrite)

Same UX as the web plan: Home → Letters / Pictures; tap a letter to hear its name then phonic sound; tap a picture to hear the word. Data-driven from a bundled `content.json`.

### 3.1 `pubspec.yaml`
```yaml
name: abc_kiosk
description: ABC learning kiosk (flutter-pi)
publish_to: 'none'
environment:
  sdk: '>=3.4.0 <4.0.0'
dependencies:
  flutter: { sdk: flutter }
  audioplayers: ^6.1.0
flutter:
  uses-material-design: true
  assets:
    - assets/content.json
    - assets/audio/letters/
    - assets/audio/words/
    - assets/images/
```

### 3.2 `assets/content.json` (starter — extend to A–Z + more pictures)
Audio paths are relative to `assets/` (audioplayers `AssetSource` prepends it). Image paths include `images/`.
```json
{
  "letters": [
    {"id":"A","label":"A","color":"#E8563F","example_word":"Apple",
     "name_audio":"audio/letters/A_name.mp3","sound_audio":"audio/letters/A_sound.mp3",
     "word_audio":"audio/words/apple.mp3","image":"images/apple.png"},
    {"id":"B","label":"B","color":"#3FA34D","example_word":"Ball",
     "name_audio":"audio/letters/B_name.mp3","sound_audio":"audio/letters/B_sound.mp3",
     "word_audio":"audio/words/ball.mp3","image":"images/ball.png"},
    {"id":"C","label":"C","color":"#4C8BF5","example_word":"Cat",
     "name_audio":"audio/letters/C_name.mp3","sound_audio":"audio/letters/C_sound.mp3",
     "word_audio":"audio/words/cat.mp3","image":"images/cat.png"}
  ],
  "pictures": [
    {"id":"apple","label":"Apple","image":"images/apple.png","word_audio":"audio/words/apple.mp3"},
    {"id":"ball","label":"Ball","image":"images/ball.png","word_audio":"audio/words/ball.mp3"},
    {"id":"cat","label":"Cat","image":"images/cat.png","word_audio":"audio/words/cat.mp3"}
  ]
}
```

### 3.3 `lib/main.dart`
```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

late final Content content;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  content = await Content.load();
  runApp(const AbcApp());
}

/// ---- Data ----
class Content {
  final List<Letter> letters; final List<Picture> pictures;
  Content(this.letters, this.pictures);
  static Future<Content> load() async {
    final j = json.decode(await rootBundle.loadString('assets/content.json'));
    return Content(
      (j['letters'] as List).map((e) => Letter.fromJson(e)).toList(),
      (j['pictures'] as List).map((e) => Picture.fromJson(e)).toList(),
    );
  }
}
class Letter {
  final String id,label,exampleWord,nameAudio,soundAudio,wordAudio,image; final Color color;
  Letter.fromJson(Map j)
    : id=j['id'], label=j['label'], exampleWord=j['example_word']??'',
      nameAudio=j['name_audio'], soundAudio=j['sound_audio'],
      wordAudio=j['word_audio']??'', image=j['image']??'',
      color=Color(int.parse((j['color'] as String).replaceFirst('#','0xFF')));
}
class Picture {
  final String id,label,image,wordAudio;
  Picture.fromJson(Map j): id=j['id'], label=j['label'], image=j['image'], wordAudio=j['word_audio'];
}

/// ---- Audio: ONE reused player (flutter-pi guidance) ----
class Audio {
  static final AudioPlayer _p = AudioPlayer(playerId: 'main')
    ..setReleaseMode(ReleaseMode.stop);
  static Future<void> play(String path) async {
    if (path.isEmpty) return;
    await _p.stop();
    await _p.play(AssetSource(path));           // resolves assets/<path>
  }
  static Future<void> sequence(List<String> paths) async {
    for (final p in paths) { await play(p); await _p.onPlayerComplete.first;
      await Future.delayed(const Duration(milliseconds: 120)); }
  }
}

/// ---- UI ----
class AbcApp extends StatelessWidget {
  const AbcApp({super.key});
  @override Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFF8EE)),
    home: const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext c) => Scaffold(body: Center(
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _bigButton(c, '🔤', 'Letters', () => _go(c, const LettersScreen())),
      const SizedBox(width: 40),
      _bigButton(c, '🖼️', 'Pictures', () => _go(c, const PicturesScreen())),
    ])));
  void _go(BuildContext c, Widget w) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => w));
  Widget _bigButton(BuildContext c, String emoji, String label, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      width: 320, height: 320,
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(blurRadius: 24, color: Colors.black26, offset: Offset(0,10))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 120)),
        Text(label, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
      ])));
}

/// A tile that scales on tap for immediate feedback.
class TapTile extends StatefulWidget {
  final Widget child; final VoidCallback onTap; final Color color;
  const TapTile({super.key, required this.child, required this.onTap, this.color = Colors.white});
  @override State<TapTile> createState() => _TapTileState();
}
class _TapTileState extends State<TapTile> {
  double s = 1;
  @override Widget build(BuildContext c) => GestureDetector(
    onTapDown: (_) => setState(() => s = 1.12),
    onTapUp: (_) { setState(() => s = 1); widget.onTap(); },
    onTapCancel: () => setState(() => s = 1),
    child: AnimatedScale(scale: s, duration: const Duration(milliseconds: 120),
      child: Container(decoration: BoxDecoration(color: widget.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26, offset: Offset(0,8))]),
        child: Center(child: widget.child))));
}

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});
  @override State<LettersScreen> createState() => _LettersScreenState();
}
class _LettersScreenState extends State<LettersScreen> {
  Letter? stage;
  @override Widget build(BuildContext c) => Scaffold(
    appBar: _bar(c, 'Letters'),
    body: Column(children: [
      Expanded(child: GridView.count(crossAxisCount: 4, padding: const EdgeInsets.all(20),
        mainAxisSpacing: 20, crossAxisSpacing: 20,
        children: content.letters.map((l) => TapTile(color: l.color,
          onTap: () { setState(() => stage = l);
            Audio.sequence([l.nameAudio, l.soundAudio]); },
          child: Text(l.label, style: const TextStyle(fontSize: 100,
            fontWeight: FontWeight.w900, color: Colors.white)))).toList())),
      if (stage != null) Padding(padding: const EdgeInsets.all(16),
        child: GestureDetector(onTap: () => Audio.play(stage!.wordAudio),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(stage!.label, style: TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: stage!.color)),
            const SizedBox(width: 24),
            if (stage!.image.isNotEmpty) Image.asset('assets/${stage!.image}', height: 140),
            const SizedBox(width: 24),
            Text(stage!.exampleWord, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800)),
          ]))),
    ]));
}

class PicturesScreen extends StatelessWidget {
  const PicturesScreen({super.key});
  @override Widget build(BuildContext c) => Scaffold(
    appBar: _bar(c, 'Pictures'),
    body: GridView.count(crossAxisCount: 4, padding: const EdgeInsets.all(20),
      mainAxisSpacing: 20, crossAxisSpacing: 20,
      children: content.pictures.map((p) => TapTile(
        onTap: () => Audio.play(p.wordAudio),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/${p.image}', height: 120),
          Text(p.label, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        ]))).toList()));
}

PreferredSizeWidget _bar(BuildContext c, String title) => AppBar(
  backgroundColor: Colors.transparent, elevation: 0,
  leadingWidth: 96,
  leading: Padding(padding: const EdgeInsets.all(8), child: TapTile(
    onTap: () => Navigator.pop(c), child: const Text('⬅', style: TextStyle(fontSize: 40)))),
  title: Text(title, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black87)));
```

Assets (audio + images): identical requirements to the web plan §4 — pre-recorded human voice is the goal; generate placeholders with `espeak-ng`/`pico2wave` + `ffmpeg` so the app runs before real recordings exist.

---

## 4. Build the release bundle (dev machine)

```bash
cd abc_kiosk
flutter pub get
flutterpi_tool build --arch=arm64 --cpu=pi4 --release
# output: build/flutter_assets/
```
`--release` = AOT-compiled native ARM, no JIT — this is what gives you the smooth, non-laggy result. Never ship debug mode.

---

## 5. Ship it to the Pi

```bash
ssh USER@PI_HOST 'sudo mkdir -p /opt/abc-app && sudo chown $USER /opt/abc-app'
rsync -a --delete --info=progress2 ./build/flutter_assets/ USER@PI_HOST:/opt/abc-app/
```
Smoke test from the Pi's **physical console** (not over SSH — flutter-pi needs to become DRM master on the VT):
```bash
flutter-pi --release /opt/abc-app
```
For fast dev iteration instead, from the dev machine: `flutterpi_tool run -d abc-pi` (builds, deploys, runs, with hot-restart-style workflow).

---

## 6. Autostart on boot (systemd) — the "ship" part

`/etc/systemd/system/abc-kiosk.service`:
```ini
[Unit]
Description=ABC Flutter-Pi Kiosk
After=systemd-user-sessions.service getty@tty1.service
Conflicts=getty@tty1.service

[Service]
Type=simple
User=USER
WorkingDirectory=/opt/abc-app
ExecStart=/usr/local/bin/flutter-pi --release /opt/abc-app
Restart=always
RestartSec=2
StandardInput=tty
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now abc-kiosk
sudo systemctl status abc-kiosk         # watch the screen; check journal on errors
journalctl -u abc-kiosk -b -f
```
The `Conflicts=getty@tty1` line hands tty1 to the app so no login prompt flickers underneath. `Restart=always` relaunches the app if it ever exits — important for an unattended device.

---

## 7. Lock down (do this LAST)

- **Screen never sleeps:** flutter-pi holds the display, but to be safe disable console blanking — add `consoleblank=0` to the kernel cmdline (`/boot/firmware/cmdline.txt`) or `setterm --blank 0`.
- **Read-only / overlay filesystem** (survives the kid pulling the power):
  ```bash
  sudo raspi-config nonint enable_overlayfs      # menu: Performance Options → Overlay File System
  sudo reboot
  ```
  To update later: `sudo raspi-config nonint disable_overlayfs && sudo reboot`, deploy, re-enable.

---

## 8. Updating the app later

```bash
# dev machine
flutterpi_tool build --arch=arm64 --cpu=pi4 --release
# (on Pi: disable overlayfs + reboot first if it's enabled)
rsync -a --delete ./build/flutter_assets/ USER@PI_HOST:/opt/abc-app/
ssh USER@PI_HOST sudo systemctl restart abc-kiosk
```
Content-only changes (new picture/letter): drop the asset + edit `content.json`, then rebuild the bundle (assets are baked into the bundle at build time — unlike the web version, you can't hot-swap files on the Pi).

---

## 9. Why this won't lag (and the one thing to watch)

- **AOT release build** runs as native ARM machine code; flutter-pi renders straight through KMS/GLES on the VideoCore GPU — reported ~50–60fps for typical apps, with none of Chromium's memory/compositor overhead. Comfortable within 2GB.
- **Boot is fast:** no desktop, no browser to start — just the systemd service on tty1.
- **Touch latency:** the flutter-pi author documents a Raspbian kernel bug that polls the *official DSI 7" touchscreen* at only 25Hz, making touch feel laggy — but that affects the DSI display's firmware polling path. Your EM101TP-C is a **USB-HID** touch panel (touch over the USB-C cable), which is event-driven and not subject to that specific bug, so touch should feel responsive out of the box. If you ever do see touch lag, that userspace-driver note is where to look.

---

## 10. Acceptance criteria

1. `flutter-pi --release /opt/abc-app` from the console renders the Home screen fullscreen.
2. Letters → A bounces the tile and plays "A" then its phonic sound with no perceptible lag; the stage card appears and speaks the word when tapped.
3. Pictures → tap speaks the word.
4. Back button returns to Home; there is no visible way to exit to a shell.
5. Reboot: device boots straight into the app fullscreen via systemd; audio plays over HDMI.
6. Pull power mid-use, power back: app returns clean (overlay FS + Restart=always).

---

## 11. Ordered task list for Claude Code

1. **Pi one-time:** run §1 (console boot, deps incl. gstreamer, build+install flutter-pi, user groups, ALSA→HDMI, verify with `speaker-test`).
2. **Dev machine one-time:** install Flutter SDK + flutterpi_tool (§2); `flutterpi_tool devices add` the Pi.
3. Scaffold the Flutter project per §3 (pubspec, main.dart, content.json); generate placeholder audio (A–Z names + sounds, word clips) and placeholder images; extend content.json to A–Z + ≥8 pictures.
4. `flutterpi_tool run -d abc-pi` to verify the app live on the panel (§4–5 dev loop). Fix scaling via `--display-size` if the UI looks wrong.
5. Build release (§4); rsync to `/opt/abc-app` (§5).
6. Install and enable the systemd service (§6); reboot; confirm acceptance §10.1–5.
7. Lock down (§7): console blanking off, then overlay FS; reboot; confirm §10.6.
8. Report back: OS version, chosen `--cpu`/`--arch`, HDMI ALSA card name, and any deviations.
```
