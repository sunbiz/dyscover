// Smoke tests for the Dyscover ABC kiosk.
//
// These load the bundled content.json and verify navigation renders. They do
// not tap tiles, because tapping triggers audio playback which needs the
// platform audio plugin (unavailable in the widget-test environment).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/main.dart';

/// Silence the audioplayers plugin so tests can tap tiles (which play audio)
/// without a real platform player. Method calls no-op; the per-player and
/// global event streams stay open but emit nothing.
void muteAudio() {
  final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in const ['xyz.luan/audioplayers', 'xyz.luan/audioplayers.global']) {
    m.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
  }
  for (final name in const [
    'xyz.luan/audioplayers/events/main',
    'xyz.luan/audioplayers.global/events',
  ]) {
    m.setMockStreamHandler(EventChannel(name),
        MockStreamHandler.inline(onListen: (_, __) {}));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureContentLoaded();
  });

  // The app opens on the splash, loads content, then fades to the home
  // screen. Advance past that so tests start from home.
  Future<void> pumpToHome(WidgetTester tester) async {
    await tester.pumpWidget(const DyscoverApp());
    await tester.pump(); // run the load microtask -> pushReplacement
    await tester.pump(const Duration(seconds: 1)); // finish the fade
  }

  testWidgets('Home shows Letters and Pictures', (tester) async {
    await pumpToHome(tester);
    expect(find.text('Letters'), findsOneWidget);
    expect(find.text('Pictures'), findsOneWidget);
  });

  testWidgets('Letters screen shows a tile for every letter', (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.text('Letters'));
    await tester.pumpAndSettle();

    // The grid is lazily built, so only the first on-screen tiles exist;
    // assert the data is complete and the first tile rendered.
    expect(content.letters.length, 26);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('About screen shows version and credits', (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.4'), findsOneWidget);
    expect(find.text('Purkayastha Lab for Health Innovation'), findsOneWidget);
    expect(find.text('Check for updates'), findsOneWidget);
    expect(find.text('Exit to desktop'), findsOneWidget);
    expect(find.textContaining('github.com/sunbiz/dyscover'), findsOneWidget);
  });

  testWidgets('Exit to desktop is gated by a PIN pad', (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Exit to desktop'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exit to desktop'));
    await tester.pumpAndSettle();
    // The touch PIN pad appears instead of switching immediately.
    expect(find.text('Enter grown-up PIN'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Enter grown-up PIN'), findsNothing);
  });

  testWidgets('Tapping a letter opens the trace canvas and captures a stroke',
      (tester) async {
    muteAudio();
    await pumpToHome(tester);
    await tester.tap(find.text('Letters'));
    await tester.pumpAndSettle();

    // Tapping a letter speaks it and opens the tracing canvas directly.
    await tester.tap(find.text('A').first);
    await tester.pumpAndSettle();
    expect(find.text('Trace A'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    // The letter can be replayed, and the example word is shown to hear too.
    expect(find.text('Hear it'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    // The Clear button starts disabled (dimmed) because nothing is drawn yet.
    Color clearColor() => tester
        .widget<TapTile>(
            find.ancestor(of: find.text('Clear'), matching: find.byType(TapTile)))
        .color;
    expect(clearColor().a, closeTo(0.35, 0.02));

    // Drag a finger across the writing surface.
    final surface = find.byWidgetPredicate((w) =>
        w is CustomPaint && w.painter.runtimeType.toString() == '_TracePainter');
    expect(surface, findsOneWidget);
    final center = tester.getCenter(surface);
    final gesture = await tester.startGesture(center - const Offset(90, 0));
    for (var i = 0; i < 3; i++) {
      await gesture.moveBy(const Offset(60, 0));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    // A stroke was captured, so Clear is now enabled (full opacity).
    expect(clearColor().a, closeTo(1.0, 0.02));

    // Clearing empties the canvas and disables the button again.
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(clearColor().a, closeTo(0.35, 0.02));
  });

  testWidgets('Pictures screen renders the picture set', (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.text('Pictures'));
    await tester.pumpAndSettle();

    expect(content.pictures, isNotEmpty);
    expect(find.text(content.pictures.first.label), findsOneWidget);
  });
}
