#!/usr/bin/env bash
# FINAL STEP of the read-only lockdown: make the root filesystem read-only via
# an overlay. Writes to / then go to a tmpfs in RAM and are discarded on reboot,
# so an unclean power-off (a yanked kiosk) can never corrupt the OS.
#
# PREREQUISITES (or OTA updates will not survive a reboot):
#   1. The app bundle must live on a PERSISTENT writable mount, NOT on the root
#      fs -- a separate data partition (preferred) or /boot/firmware. See
#      README.md "Relocate the app".
#   2. The updater must target that mount: set ABC_APP_DIR (+ ABC_DATA_MOUNT if
#      it is mounted read-only) in abc-update's environment. See README.md.
#   3. WiFi, systemd units and asound.conf are baked into the rootfs already;
#      read-only keeps them working, they just cannot be changed without
#      lifting the overlay.
#
# RECOVERY if the Pi will not boot after this: put the SD in another computer
# and append ` overlayroot=disabled` to cmdline.txt on the boot (FAT) partition,
# or blank /etc/overlayroot.conf via that partition. It boots read-write again.
#
# Run on the Pi:  sudo deploy/readonly/enable-overlayroot.sh   (then reboot)
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "This makes / READ-ONLY on next boot. Make sure the app is already on a"
echo "persistent writable mount (README.md), or OTA updates will revert on"
echo "reboot. Type 'yes' to continue:"
read -r ans; [ "$ans" = yes ] || { echo "aborted"; exit 1; }

apt-get update
apt-get install -y overlayroot

cat > /etc/overlayroot.conf <<'CONF'
# Root is an overlay: read-only lower (the real rootfs) + tmpfs upper (RAM).
# All writes to / are discarded on reboot, so power loss cannot corrupt the OS.
# Persistent state lives on separate writable mounts (recurse=0 leaves them
# alone: /boot/firmware and any data partition stay as their own real mounts).
overlayroot="tmpfs:swap=1,recurse=0"
CONF

echo
echo "Configured. Activate with:  sudo reboot"
echo "After reboot, 'findmnt /' shows overlay and the OS is corruption-proof."
