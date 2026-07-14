# Deploy: Dyscover on a Raspberry Pi via flutter-pi

This folder holds the files and steps that put the app on the Pi as a fullscreen
kiosk. The narrative background is in
[`../abc_learning_app_flutterpi_plan.md`](../abc_learning_app_flutterpi_plan.md);
this is the concrete, tested recipe (what actually runs on the device).

Files:
- `abc-kiosk.service` goes to `/etc/systemd/system/abc-kiosk.service`
- `asound.conf` goes to `/etc/asound.conf`
- `abc-update.sh` goes to `/usr/local/bin/abc-update.sh` (the OTA updater)
- `abc-update.service` / `abc-update.timer` go to `/etc/systemd/system/`
- `abc-update.sudoers` goes to `/etc/sudoers.d/abc-update` (mode 0440)
- `abc-desktop.sh` goes to `/usr/local/bin/abc-desktop.sh` (exit-to-desktop)
- `abc-desktop.service` goes to `/etc/systemd/system/`
- `abc-desktop.sudoers` goes to `/etc/sudoers.d/abc-desktop` (mode 0440)
- `release.sh` runs on the dev machine to publish a GitHub release

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

## 4. Over-the-air updates (GitHub Releases)

Once the Pi leaves your LAN you can no longer `rsync` over SSH. The updater lets
the device pull new releases itself over outbound HTTPS (works behind NAT), on a
timer and on demand from the app's **About** screen.

How it works: each release publishes two assets with **stable names** so the
`.../releases/latest/download/<asset>` URL is always the newest one:
`dyscover-abc-pi4-64.tar.gz` (the bundle, with a `VERSION` file) and
`version.json` (`{version, asset, sha256, notes}`). `abc-update.sh` compares the
installed `VERSION` to the manifest, and if newer downloads the tarball, checks
its SHA-256, swaps `/opt/abc-app` (keeping `.prev` for rollback) and restarts the
kiosk. If the new build fails its health check it rolls back automatically.

One-time install on the Pi:

```bash
sudo cp abc-update.sh /usr/local/bin/abc-update.sh
sudo chmod +x /usr/local/bin/abc-update.sh
sudo cp abc-update.service abc-update.timer /etc/systemd/system/
sudo install -m 0440 abc-update.sudoers /etc/sudoers.d/abc-update   # About-screen button
sudo systemctl daemon-reload
sudo systemctl enable --now abc-update.timer
# Stamp the currently-installed bundle so the first check has a baseline:
echo "1.0.0" | sudo tee /opt/abc-app/VERSION
```

Manual controls:

```bash
abc-update.sh --check                 # print installed/latest, change nothing
sudo systemctl start abc-update.service   # apply an update now (same as the app button)
journalctl -u abc-update.service -n 50    # see what happened
```

Cutting a release (dev machine, needs `gh` logged in):

```bash
# 1. bump kAppVersion in lib/version.dart AND version: in pubspec.yaml, commit
# 2. build + package + publish in one step:
deploy/release.sh "What changed in this release"
```

Every enrolled Pi picks it up within the hour (or immediately via the About
screen). Roll a release back by deleting it on GitHub or publishing a higher
version; roll a single device back with its `/opt/abc-app.prev`.

**Staying reachable for admin:** install [Tailscale](https://tailscale.com) on the
Pi while you still have local SSH (`curl -fsSL https://tailscale.com/install.sh |
sh && sudo tailscale up`). It gives SSH/`rsync` access from anywhere without port
forwarding, so the OTA path handles routine app updates and Tailscale covers
debugging and OS-level changes.

## 5. Exit to desktop (from the kiosk)

The Raspberry Pi desktop (labwc + LXDE, `lightdm` with `autologin-user=ubuntu`)
is still installed; kiosk mode just boots to `multi-user.target` instead of
`graphical.target`. The About screen has a PIN-gated **Exit to desktop** button
so an adult can reach the desktop on-site (Wi-Fi, settings, files) without SSH.

It is deliberately one-way: the kiosk stays the boot default, so **rebooting is
the way back** (self-recovering, nothing to get stuck in). The button starts
`abc-desktop.service`, which stops `abc-kiosk` and starts `lightdm`.

One-time install on the Pi:

```bash
sudo cp abc-desktop.sh /usr/local/bin/abc-desktop.sh
sudo chmod +x /usr/local/bin/abc-desktop.sh
sudo cp abc-desktop.service /etc/systemd/system/
sudo install -m 0440 abc-desktop.sudoers /etc/sudoers.d/abc-desktop
sudo systemctl daemon-reload
```

Change the PIN in `lib/version.dart` (`kAdminPin`). Test the switch itself with
`sudo systemctl --no-block start abc-desktop.service`; return with `sudo reboot`.

## Notes

- The app runs as `abc-kiosk.service` on tty1 (`Conflicts=getty@tty1` hands it the
  console). It boots straight into the app, no login, no desktop.
- With cloud-init disabled, boot-to-app is ~20s and a single clean start.
- `Restart=always` relaunches the app if it ever exits.
- The updater (`abc-update.service`) is a separate unit on purpose so it can
  restart `abc-kiosk` mid-update without killing itself.
- If you later add the overlayfs read-only lockdown, keep `/opt/abc-app` on a
  writable partition or OTA cannot swap the bundle.
