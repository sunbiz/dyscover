#!/usr/bin/env bash
# Reduce steady-state SD-card writes so an unclean power-off (kiosks get
# unplugged) is very unlikely to corrupt the filesystem. This is the low-risk,
# fully reversible half of corruption resistance; it does NOT make the root
# read-only (see enable-overlayroot.sh + README.md for that).
#
# Run on the Pi:  sudo deploy/readonly/harden-writes.sh
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== journald: keep logs in RAM (volatile) =="
install -d /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/volatile.conf <<'CONF'
[Journal]
Storage=volatile
RuntimeMaxUse=32M
CONF
systemctl restart systemd-journald

echo "== /tmp and /var/tmp on tmpfs (RAM) =="
add_fstab() {
  grep -qE "^[^#]*[[:space:]]$1[[:space:]]" /etc/fstab \
    || echo "tmpfs $1 tmpfs defaults,noatime,nosuid,nodev,mode=1777 0 0" >> /etc/fstab
}
add_fstab /tmp
add_fstab /var/tmp
mountpoint -q /tmp || mount /tmp
mountpoint -q /var/tmp || mount /var/tmp

echo "== disable chatty periodic writers =="
for t in apt-daily.timer apt-daily-upgrade.timer man-db.timer e2scrub_all.timer \
         fstrim.timer; do
  systemctl disable --now "$t" 2>/dev/null || true
done

echo
echo "== done: runtime SD writes are now minimal. =="
echo "Already good on this image: rootfs mounts noatime, swap is zram (RAM)."
echo
echo "Reverse with: rm /etc/systemd/journald.conf.d/volatile.conf ;"
echo "  remove the two tmpfs lines from /etc/fstab ; re-enable the timers."
