# Corruption-resistant kiosk (read-only OS) that still takes OTA updates

Kiosks get their power pulled. On a Pi that means unclean writes to a mounted
ext4 SD card, which is the usual cause of "my Pi won't boot anymore". This is
how Dyscover stays uncorruptable while still self-updating over the air.

## The principle

Split the **immutable OS** from the **mutable app data**:

- The **root filesystem is read-only** (an overlay: real rootfs read-only +
  a tmpfs in RAM for any runtime writes, discarded on reboot). Power loss can
  never corrupt the OS, because the rootfs is never written after boot.
- The **app bundle** lives on a small, **persistent writable mount** that is
  written **only during an update**, briefly, atomically, with a checksum and a
  `.prev` rollback. That is the one place a power cut during an update could
  touch, and the updater `sync`s and keeps the old copy so the worst case is
  "boot the previous build".

Dyscover's OTA already updates only the app bundle (`/opt/abc-app`), never the
OS or the flutter-pi engine, which makes this clean.

## Two layers (do Layer 1 always; Layer 2 for the belt-and-suspenders)

### Layer 1 - reduce writes (safe, reversible, no read-only needed)

`sudo deploy/readonly/harden-writes.sh` sends journald logs to RAM, puts
`/tmp` and `/var/tmp` on tmpfs, and disables chatty periodic writers. Combined
with the image's existing `noatime` rootfs and zram (RAM) swap, the SD is
essentially **not written during normal operation**, so an unclean power-off is
already very unlikely to corrupt anything. This alone gets you most of the way.

### Layer 2 - read-only root (makes the OS truly uncorruptable)

Requires a persistent writable home for the app first, then the overlay flip.

**Finding on this device (pi4tab):** the ext4 rootfs (`mmcblk0p2`) fills the
whole 59 GB card - there is **no free space** for a data partition, and a
mounted rootfs cannot be shrunk online. So pick one:

#### Path A (recommended) - separate data partition. Needs physical SD access.

1. Image the SD, then on a PC shrink `mmcblk0p2` and add `mmcblk0p3`
   (e.g. 512 MB, ext4 - journaled, the safest for the writable data).
2. On the Pi: `mkfs.ext4 -L data /dev/mmcblk0p3`, add to `/etc/fstab`:
   `LABEL=data /data ext4 defaults,noatime,ro 0 2` (read-only by default).
3. Relocate the app (below), pointing it at `/data/abc-app`, with
   `ABC_DATA_MOUNT=/data` so the updater flips it rw only for the swap.

#### Path B (no physical access) - app on the boot (FAT) partition.

`/boot/firmware` is a separate 512 MB FAT mount (417 MB free) not covered by
the root overlay. Put the app there. Trade-off: FAT has no journaling, so the
brief update write-window is slightly less robust than ext4 - acceptable for an
app that updates rarely, and the OS is still fully protected. Use
`ABC_DATA_MOUNT=/boot/firmware`.

### Relocate the app (either path)

```
sudo systemctl stop abc-kiosk
sudo mv /opt/abc-app  /data/abc-app          # or /boot/firmware/abc-app
sudo ln -sfn /data/abc-app /opt/abc-app      # keep the old path working
# point the updater at the new home + its mount:
sudo systemctl edit abc-update.service       # add:
#   [Service]
#   Environment=ABC_APP_DIR=/data/abc-app
#   Environment=ABC_DATA_MOUNT=/data
sudo systemctl start abc-kiosk               # verify it renders from the new path
```

`abc-update.sh` already understands `ABC_DATA_MOUNT`: it remounts that mount rw
only for the atomic swap, `sync`s, and remounts it ro (see the EXIT trap).

### Flip to read-only

`sudo deploy/readonly/enable-overlayroot.sh` then `sudo reboot`. It installs
`overlayroot`, writes `overlayroot="tmpfs:swap=1,recurse=0"` (recurse=0 leaves
`/boot/firmware` and any data partition as their own real mounts), and prints
the recovery steps.

## Recovery

If the Pi will not boot after the flip: put the SD in another computer and
append ` overlayroot=disabled` to `cmdline.txt` on the boot partition (or blank
`/etc/overlayroot.conf`). It boots read-write again - nothing is lost.

To make an intentional change to the read-only OS later:
`sudo overlayroot-chroot` (edit the real rootfs), or set
`overlayroot=disabled`, reboot, change, re-enable.

## Why not update the whole OS over the air too?

That is the A/B dual-slot world (RAUC, Mender, SWUpdate, balenaOS): a full new
OS is written to an inactive slot and switched with rollback. Bigger
re-architecture; only worth it if OS-level OTA becomes a requirement. Dyscover
only needs to ship app changes, which the above covers.
