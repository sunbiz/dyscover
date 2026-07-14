/// Privileged device actions the kiosk can request from systemd.
///
/// The app itself is unprivileged; these shell out to units that a narrow
/// sudoers drop-in (deploy/*.sudoers) lets the kiosk user start, and nothing
/// more. The heavy lifting lives in those units, not here.
library;

import 'dart:io';

/// Switches the screen from the kiosk to the Raspberry Pi desktop (until the
/// next reboot). The kiosk stays the boot default, so a reboot returns to it.
/// Returns null on success (the kiosk service is torn down moments later), or
/// an error message. Uses --no-block so the call returns before systemd stops
/// the kiosk out from under it.
Future<String?> exitToDesktop() async {
  try {
    final r = await Process.run(
      'sudo',
      ['-n', 'systemctl', '--no-block', 'start', 'abc-desktop.service'],
    );
    if (r.exitCode != 0) {
      final err = (r.stderr as String?)?.trim() ?? '';
      return err.isNotEmpty ? err : 'Exited with code ${r.exitCode}';
    }
    return null;
  } catch (e) {
    return 'Could not switch to the desktop on this device.';
  }
}
