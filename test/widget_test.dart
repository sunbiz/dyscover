// Smoke tests for the Dyscover ABC kiosk.
//
// These load the bundled content.json and verify navigation renders. They do
// not tap tiles, because tapping triggers audio playback which needs the
// platform audio plugin (unavailable in the widget-test environment).

import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    content = await Content.load();
  });

  testWidgets('Home shows Letters and Pictures', (tester) async {
    await tester.pumpWidget(const DyscoverApp());
    expect(find.text('Letters'), findsOneWidget);
    expect(find.text('Pictures'), findsOneWidget);
  });

  testWidgets('Letters screen shows a tile for every letter', (tester) async {
    await tester.pumpWidget(const DyscoverApp());
    await tester.tap(find.text('Letters'));
    await tester.pumpAndSettle();

    // The grid is lazily built, so only the first on-screen tiles exist;
    // assert the data is complete and the first tile rendered.
    expect(content.letters.length, 26);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('Pictures screen renders the picture set', (tester) async {
    await tester.pumpWidget(const DyscoverApp());
    await tester.tap(find.text('Pictures'));
    await tester.pumpAndSettle();

    expect(content.pictures, isNotEmpty);
    expect(find.text(content.pictures.first.label), findsOneWidget);
  });
}
