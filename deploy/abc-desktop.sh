#!/usr/bin/env bash
# Switch the screen from the Dyscover ABC kiosk to the Raspberry Pi desktop,
# until the next reboot.
#
# The kiosk stays the boot default (multi-user.target), so a reboot or
# power-cycle always returns to it. This is deliberately one-way: there is no
# "back to kiosk" here, because rebooting is the robust, self-recovering way
# back. Triggered (PIN-gated) from the app's About screen via abc-desktop.service.
set -e

# Free the display: flutter-pi holds the DRM master, so it must fully exit
# before lightdm/labwc can take over.
systemctl stop abc-kiosk || true

# lightdm is preconfigured (autologin-user=ubuntu, autologin-session=rpd-labwc)
# to drop straight into the touch desktop, no password needed.
systemctl start lightdm
