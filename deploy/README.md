# Deploy: Dyscover on a Raspberry Pi via flutter-pi

This folder holds the files and steps that put the app on the Pi as a fullscreen
kiosk. The narrative background is in
[`../abc_learning_app_flutterpi_plan.md`](../abc_learning_app_flutterpi_plan.md);
this is the concrete, tested recipe (what actually runs on the device).

Files:
- `abc-kiosk.service` goes to `/etc/systemd/system/abc-kiosk.service`
- `asound.conf` goes to `/etc/asound.conf`

## 1. Build the bundle (dev machine)

flutter-pi's prebuilt engine lags the newest Flutter stable, so **build with
Flutter 3.41.x** (3.44+ has no matching flutter-pi engine yet, and a release
build needs the engine to match the SDK exactly).

```bash
# with a Flutter 3.41.x on PATH:
flutter pub global activate flutterpi_tool
flutter pub get
flutterpi_tool build --arch=arm64 --cpu=pi4 --release   # -> build/flutter-pi/pi4-64/
```

## 2. One-time Pi setup

```bash
# build deps + gstreamer (Debian/Ubuntu), then build + install flutter-pi:
sudo apt update && sudo apt install -y cmake git build-essential pkg-config \
  libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev \
  fontconfig libsystemd-dev libinput-dev libudev-dev libxkbcommon-dev fonts-dejavu \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  gstreamer1.0-alsa gstreamer1.0-libav
git clone https://github.com/ardera/flutter-pi && cd flutter-pi
mkdir -p build && cd build && cmake .. && make -j"$(nproc)" && sudo make install

# HDMI audio, console boot, autostart:
sudo cp asound.conf /etc/asound.conf
sudo cp abc-kiosk.service /etc/systemd/system/abc-kiosk.service
sudo systemctl daemon-reload
sudo systemctl enable abc-kiosk
sudo systemctl set-default multi-user.target      # boot to console, no desktop

# IMPORTANT on cloud-init images (e.g. Ubuntu/Debian Pi server): disable
# cloud-init, or its late final stage steals the display back from flutter-pi on
# boot (app stays blank until a manual restart) and slows boot to minutes.
# Safe here because networking is NetworkManager, not cloud-init.
sudo touch /etc/cloud/cloud-init.disabled
```

## 3. Deploy / update

```bash
ssh USER@PI 'sudo mkdir -p /opt/abc-app && sudo chown "$USER":"$USER" /opt/abc-app'
rsync -a --delete build/flutter-pi/pi4-64/ USER@PI:/opt/abc-app/
ssh USER@PI sudo systemctl restart abc-kiosk
```

## Notes

- The app runs as `abc-kiosk.service` on tty1 (`Conflicts=getty@tty1` hands it the
  console). It boots straight into the app, no login, no desktop.
- With cloud-init disabled, boot-to-app is ~20s and a single clean start.
- `Restart=always` relaunches the app if it ever exits.
