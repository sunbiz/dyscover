// Unit tests for the trace accuracy scorer (issue #3).
import 'package:flutter_test/flutter_test.dart';

import 'package:dyscover/letter_strokes.dart';

void main() {
  // 'I' is a simple three-stroke letter; sample its ideal path once.
  final samples = sampleStrokes(kLetterStrokes['I']!, 0.02);

  test('sampleStrokes produces a dense point list', () {
    expect(samples.length, greaterThan(20));
  });

  test('no trace scores zero', () {
    final s = TraceScore.of(const [], samples, 0.1);
    expect(s.accuracy, 0);
    expect(s.coverage, 0);
    expect(s.precision, 0);
  });

  test('tracing the ideal path scores 100 (full coverage, on track)', () {
    // Feed the ideal samples back as the finger path.
    final s = TraceScore.of([samples], samples, 0.1);
    expect(s.coverage, closeTo(1.0, 0.001));
    expect(s.precision, closeTo(1.0, 0.001));
    expect(s.accuracy, 100);
  });

  test('partial coverage cannot reach a top score', () {
    final half = samples.sublist(0, samples.length ~/ 2);
    final s = TraceScore.of([half], samples, 0.1);
    expect(s.precision, closeTo(1.0, 0.001)); // the half we drew was on track
    expect(s.coverage, greaterThan(0.3));
    expect(s.coverage, lessThan(0.9)); // but not the whole letter
    expect(s.accuracy, lessThan(90)); // missing coverage caps the score
  });

  test('straying off the track lowers precision and score', () {
    // A stroke far from the letter (top-left corner; 'I' sits around x~0.5).
    final off = [for (var i = 0; i < 12; i++) Offset(0.02 + 0.01 * i, 0.02)];
    final s = TraceScore.of([off], samples, 0.1);
    expect(s.precision, lessThan(0.2));
    expect(s.accuracy, lessThan(20));
  });

  test('covered flags mark the traced samples', () {
    final s = TraceScore.of([samples], samples, 0.1);
    expect(s.covered.length, samples.length);
    expect(s.covered.every((b) => b), isTrue);
  });
}
