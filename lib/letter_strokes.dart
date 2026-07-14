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
