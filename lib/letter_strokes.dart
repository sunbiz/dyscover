import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Normalized (0..1, y-down) stroke skeletons for the uppercase letters, listed
/// in the order and direction a learner should draw them. Straight letters are
/// plain point lists; curved letters are built from elliptical arcs.
///
/// One source of truth for the tracing guide (issue #2, animated marker +
/// direction arrows + stroke-order numbers) and, later, accuracy scoring
/// (issue #3, hit-testing the finger path against these strokes).
final Map<String, List<List<Offset>>> kLetterStrokes = _build();

/// Points along an elliptical arc, sweeping [startDeg] -> [endDeg] (degrees,
/// 0 = right, 90 = down). Endpoints are included.
List<Offset> _arc(double cx, double cy, double rx, double ry, double startDeg,
    double endDeg, int steps) {
  final pts = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final a =
        (startDeg + (endDeg - startDeg) * i / steps) * math.pi / 180.0;
    pts.add(Offset(cx + rx * math.cos(a), cy + ry * math.sin(a)));
  }
  return pts;
}

List<Offset> _sampleOne(List<Offset> st, double spacing) {
  final out = <Offset>[st.first];
  for (var i = 1; i < st.length; i++) {
    final a = st[i - 1], b = st[i];
    final d = (b - a).distance;
    final n = math.max(1, (d / spacing).ceil());
    for (var k = 1; k <= n; k++) {
      out.add(Offset.lerp(a, b, k / n)!);
    }
  }
  return out;
}

/// Resamples each stroke into its own dense point list (the "ideal path"),
/// spaced about [spacing] apart (normalized). Kept per-stroke so coverage can
/// weight every stroke equally: a short stroke (like A's crossbar) counts as
/// much as a long one, so skipping it genuinely lowers the score.
List<List<Offset>> sampleLetter(List<List<Offset>> strokes, double spacing) =>
    [for (final st in strokes) if (st.isNotEmpty) _sampleOne(st, spacing)];

/// How closely a finger trace (normalized 0..1 points) followed the ideal
/// stroke [samples]. Coverage is the fraction of the letter the finger passed
/// over; precision is the fraction of finger points that stayed within the
/// track. The combined [accuracy] (0..100) feeds the star feedback (issue #4).
class TraceScore {
  final List<bool> covered; // one flag per ideal sample
  final double coverage; // 0..1
  final double precision; // 0..1
  final int accuracy; // 0..100

  const TraceScore(this.covered, this.coverage, this.precision, this.accuracy);

  static const TraceScore empty = TraceScore(<bool>[], 0, 0, 0);

  // A finger point marks COVERAGE for every ideal sample within [covTol] (did
  // the child reach this part of the letter?), and counts toward PRECISION if
  // its nearest sample is within [precTol] (did they stay on the line?).
  //
  // Coverage is averaged per stroke (each stroke weighted equally), so skipping
  // a whole stroke tanks coverage even if it is short. Accuracy is the PRODUCT
  // of coverage and precision, so neither filling the area (high coverage, low
  // precision) nor drawing a couple of strokes perfectly (high precision, low
  // coverage) can score high -- both must be good.
  //
  // [sampleGroups] is the ideal path per stroke; [covered] is returned flat in
  // the same (concatenated) order for the color fill.
  static TraceScore of(
    List<List<Offset>> childStrokes,
    List<List<Offset>> sampleGroups, {
    double covTol = 0.05,
    double precTol = 0.06,
  }) {
    final flat = <Offset>[for (final g in sampleGroups) ...g];
    if (flat.isEmpty) return empty;
    final covered = List<bool>.filled(flat.length, false);
    final covTol2 = covTol * covTol;
    final precTol2 = precTol * precTol;
    var total = 0, onTrack = 0;
    for (final stroke in childStrokes) {
      for (final pt in stroke) {
        total++;
        var minD2 = double.infinity;
        for (var i = 0; i < flat.length; i++) {
          final dx = flat[i].dx - pt.dx, dy = flat[i].dy - pt.dy;
          final d2 = dx * dx + dy * dy;
          if (d2 <= covTol2) covered[i] = true;
          if (d2 < minD2) minD2 = d2;
        }
        if (minD2 <= precTol2) onTrack++;
      }
    }
    var idx = 0, groups = 0;
    var covSum = 0.0;
    for (final g in sampleGroups) {
      if (g.isEmpty) continue;
      var c = 0;
      for (var j = 0; j < g.length; j++) {
        if (covered[idx + j]) c++;
      }
      covSum += c / g.length;
      groups++;
      idx += g.length;
    }
    final cov = groups == 0 ? 0.0 : covSum / groups;
    final prec = total == 0 ? 0.0 : onTrack / total;
    final acc = (100 * cov * prec).round().clamp(0, 100);
    return TraceScore(covered, cov, prec, acc);
  }
}

Map<String, List<List<Offset>>> _build() {
  Offset p(double x, double y) => Offset(x, y);
  return {
    'A': [
      [p(.50, .15), p(.30, .85)],
      [p(.50, .15), p(.70, .85)],
      [p(.37, .56), p(.63, .56)],
    ],
    'B': [
      [p(.34, .15), p(.34, .85)],
      _arc(.34, .325, .30, .175, -90, 90, 10),
      _arc(.34, .685, .32, .195, -90, 90, 10),
    ],
    'C': [
      _arc(.52, .50, .26, .36, -52, -308, 22),
    ],
    'D': [
      [p(.34, .15), p(.34, .85)],
      _arc(.34, .50, .36, .35, -90, 90, 14),
    ],
    'E': [
      [p(.36, .15), p(.36, .85)],
      [p(.36, .15), p(.68, .15)],
      [p(.36, .50), p(.62, .50)],
      [p(.36, .85), p(.68, .85)],
    ],
    'F': [
      [p(.36, .15), p(.36, .85)],
      [p(.36, .15), p(.68, .15)],
      [p(.36, .50), p(.62, .50)],
    ],
    'G': [
      _arc(.52, .50, .26, .36, -52, -318, 22),
      [p(.66, .74), p(.72, .55), p(.72, .52), p(.52, .52)],
    ],
    'H': [
      [p(.34, .15), p(.34, .85)],
      [p(.66, .15), p(.66, .85)],
      [p(.34, .50), p(.66, .50)],
    ],
    'I': [
      [p(.38, .15), p(.62, .15)],
      [p(.50, .15), p(.50, .85)],
      [p(.38, .85), p(.62, .85)],
    ],
    'J': [
      [p(.60, .15), p(.60, .66), ..._arc(.44, .66, .16, .18, 0, 150, 8)],
    ],
    'K': [
      [p(.34, .15), p(.34, .85)],
      [p(.66, .15), p(.34, .50)],
      [p(.37, .48), p(.66, .85)],
    ],
    'L': [
      [p(.36, .15), p(.36, .85)],
      [p(.36, .85), p(.66, .85)],
    ],
    'M': [
      [p(.26, .15), p(.26, .85)],
      [p(.26, .15), p(.50, .58)],
      [p(.50, .58), p(.74, .15)],
      [p(.74, .15), p(.74, .85)],
    ],
    'N': [
      [p(.32, .15), p(.32, .85)],
      [p(.32, .15), p(.68, .85)],
      [p(.68, .15), p(.68, .85)],
    ],
    'O': [
      _arc(.50, .50, .25, .36, -90, -450, 30),
    ],
    'P': [
      [p(.34, .15), p(.34, .85)],
      _arc(.34, .335, .30, .185, -90, 90, 10),
    ],
    'Q': [
      _arc(.50, .48, .25, .34, -90, -450, 30),
      [p(.58, .60), p(.76, .86)],
    ],
    'R': [
      [p(.34, .15), p(.34, .85)],
      _arc(.34, .335, .30, .185, -90, 90, 10),
      [p(.40, .50), p(.68, .85)],
    ],
    'S': [
      [
        p(.66, .24), p(.58, .17), p(.47, .16), p(.38, .21), p(.36, .31),
        p(.43, .39), p(.55, .46), p(.64, .55), p(.64, .67), p(.56, .77),
        p(.44, .80), p(.34, .74),
      ],
    ],
    'T': [
      [p(.30, .15), p(.70, .15)],
      [p(.50, .15), p(.50, .85)],
    ],
    'U': [
      [p(.32, .15), ..._arc(.50, .58, .18, .24, 180, 0, 12), p(.68, .15)],
    ],
    'V': [
      [p(.30, .15), p(.50, .85), p(.70, .15)],
    ],
    'W': [
      [p(.22, .15), p(.34, .85), p(.50, .38), p(.66, .85), p(.78, .15)],
    ],
    'X': [
      [p(.32, .15), p(.68, .85)],
      [p(.68, .15), p(.32, .85)],
    ],
    'Y': [
      [p(.32, .15), p(.50, .52)],
      [p(.68, .15), p(.50, .52)],
      [p(.50, .52), p(.50, .85)],
    ],
    'Z': [
      [p(.32, .15), p(.68, .15), p(.32, .85), p(.68, .85)],
    ],
  };
}
