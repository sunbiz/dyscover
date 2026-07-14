// Unit tests for the trace accuracy scorer (issues #3 and #4).
import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/letter_strokes.dart';

void main() {
  // 'I' is a simple three-stroke letter; sample its ideal path per stroke.
  final groups = sampleLetter(kLetterStrokes['I']!, 0.02);
  final flat = [for (final g in groups) ...g];

  test('sampleLetter produces per-stroke dense point lists', () {
    expect(groups.length, kLetterStrokes['I']!.length); // three strokes
    expect(flat.length, greaterThan(20));
  });

  test('no trace scores zero', () {
    final s = TraceScore.of(const [], groups);
    expect(s.accuracy, 0);
    expect(s.coverage, 0);
    expect(s.precision, 0);
  });

  test('tracing the ideal path scores 100 (full coverage, on track)', () {
    final s = TraceScore.of([flat], groups);
    expect(s.coverage, closeTo(1.0, 0.001));
    expect(s.precision, closeTo(1.0, 0.001));
    expect(s.accuracy, 100);
  });

  test('skipping a whole stroke is not "outstanding"', () {
    // Draw only two of I's three strokes (top bar + stem), skipping the base.
    final twoStrokes = [for (final g in groups.take(2)) ...g];
    final s = TraceScore.of([twoStrokes], groups);
    expect(s.precision, closeTo(1.0, 0.02)); // what we drew was on track
    expect(s.coverage, lessThan(0.85)); // but a stroke is missing
    expect(s.accuracy, lessThan(88)); // so not 5 stars
  });

  test('straying off the track lowers precision and score', () {
    // A stroke far from the letter (top-left corner; 'I' sits around x~0.5).
    final off = [for (var i = 0; i < 12; i++) Offset(0.02 + 0.01 * i, 0.02)];
    final s = TraceScore.of([off], groups);
    expect(s.precision, lessThan(0.2));
    expect(s.accuracy, lessThan(20));
  });

  test('filling the whole area does NOT score high (needs precision)', () {
    // Dense grid scribble covering the entire box: coverage is ~full, but most
    // points are off the thin letter, so precision -- and accuracy -- stay low.
    final scribble = <Offset>[];
    for (var x = 0; x <= 33; x++) {
      for (var y = 0; y <= 33; y++) {
        scribble.add(Offset(x / 33, y / 33));
      }
    }
    final s = TraceScore.of([scribble], groups);
    expect(s.coverage, greaterThan(0.9)); // it did reach every part...
    expect(s.precision, lessThan(0.4)); // ...but was mostly off the line
    expect(s.accuracy, lessThan(40)); // so it is NOT "outstanding"
  });

  test('covered flags mark the traced samples', () {
    final s = TraceScore.of([flat], groups);
    expect(s.covered.length, flat.length);
    expect(s.covered.every((b) => b), isTrue);
  });
}
