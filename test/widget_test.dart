// Smoke tests for the Dyscover ABC kiosk.
//
// These load the bundled content.json and verify navigation renders. They do
// not tap tiles, because tapping triggers audio playback which needs the
// platform audio plugin (unavailable in the widget-test environment).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/main.dart';

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

    expect(find.text('Version 1.0.3'), findsOneWidget);
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

  testWidgets('Pictures screen renders the picture set', (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.text('Pictures'));
    await tester.pumpAndSettle();

    expect(content.pictures, isNotEmpty);
    expect(find.text(content.pictures.first.label), findsOneWidget);
  });
}
