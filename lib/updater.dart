/// Over-the-air update check for the flutter-pi kiosk.
///
/// The device-side heavy lifting (download, checksum, atomic swap, restart)
/// lives in `deploy/abc-update.sh`, run on a schedule by `abc-update.timer` and
/// on demand from the About screen. This file is the *app* side: it reads the
/// published manifest to tell the user whether an update is waiting, and can
/// ask systemd to apply it now.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'version.dart';

/// URL of the manifest attached to the latest GitHub release. The
/// `/releases/latest/download/<asset>` form always resolves to the newest
/// release, so there is no GitHub API call or token needed.
final Uri kManifestUrl =
    Uri.parse('https://github.com/$kGithubRepo/releases/latest/download/version.json');

/// Result of asking the manifest "is there something newer than me?".
class UpdateStatus {
  /// The latest published version, or null if the check could not complete.
  final String? latest;

  /// True when [latest] is strictly newer than [kAppVersion].
  final bool updateAvailable;

  /// Human-readable release notes from the manifest, if any.
  final String? notes;

  /// Set when the check failed (offline, no release yet, bad response).
  final String? error;

  const UpdateStatus({
    this.latest,
    this.updateAvailable = false,
    this.notes,
    this.error,
  });

  bool get ok => error == null;
}

/// Returns true when [latest] is a strictly newer semantic version than
/// [current]. Tolerates a leading `v` and a trailing `+build`.
bool isNewerVersion(String latest, String current) {
  List<int> parts(String v) => v
      .trim()
      .replaceFirst(RegExp(r'^v', caseSensitive: false), '')
      .split('+')
      .first
      .split('.')
      .map((s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
  final a = parts(latest);
  final b = parts(current);
  for (var i = 0; i < a.length || i < b.length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Fetches the manifest and compares it to the running version.
Future<UpdateStatus> checkForUpdate() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.getUrl(kManifestUrl);
    req.followRedirects = true;
    req.maxRedirects = 8;
    req.headers.set(HttpHeaders.userAgentHeader, '$kAppName/$kAppVersion');
    final resp = await req.close().timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) {
      return UpdateStatus(error: 'Server returned ${resp.statusCode}');
    }
    final body = await resp.transform(utf8.decoder).join();
    final map = json.decode(body) as Map<String, dynamic>;
    final latest = (map['version'] ?? '').toString();
    if (latest.isEmpty) {
      return const UpdateStatus(error: 'No version in manifest');
    }
    return UpdateStatus(
      latest: latest,
      updateAvailable: isNewerVersion(latest, kAppVersion),
      notes: map['notes']?.toString(),
    );
  } on TimeoutException {
    return const UpdateStatus(error: 'Timed out. Check the connection.');
  } catch (e) {
    return UpdateStatus(error: 'Could not reach the update server.');
  } finally {
    client.close(force: true);
  }
}

/// Asks systemd to run the updater now (download + swap + restart). Allowed
/// without a password by the `deploy/abc-update.sudoers` drop-in. Returns null
/// on success, or an error message. The kiosk restarts on success, so the UI
/// only needs to show "updating" until it is torn down.
Future<String?> triggerUpdate() async {
  try {
    final r = await Process.run(
      'sudo',
      ['-n', 'systemctl', 'start', 'abc-update.service'],
    );
    if (r.exitCode != 0) {
      return (r.stderr as String?)?.trim().isNotEmpty == true
          ? (r.stderr as String).trim()
          : 'Updater exited with code ${r.exitCode}';
    }
    return null;
  } catch (e) {
    return 'Could not start the updater on this device.';
  }
}
