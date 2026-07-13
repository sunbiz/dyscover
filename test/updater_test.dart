// Unit tests for the OTA version comparison. Network calls are not exercised
// here (that is covered end-to-end against a real GitHub release).

import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/updater.dart';

void main() {
  test('detects a strictly newer version', () {
    expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
    expect(isNewerVersion('1.1.0', '1.0.9'), isTrue);
    expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
  });

  test('same or older version is not an update', () {
    expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
    expect(isNewerVersion('1.0.0', '1.0.1'), isFalse);
    expect(isNewerVersion('1.2.0', '1.10.0'), isFalse); // 2 < 10, numeric
  });

  test('tolerates a leading v and a trailing build', () {
    expect(isNewerVersion('v1.0.1', '1.0.0'), isTrue);
    expect(isNewerVersion('1.0.1+5', '1.0.0+1'), isTrue);
    expect(isNewerVersion('v1.0.0+9', '1.0.0'), isFalse);
  });
}
