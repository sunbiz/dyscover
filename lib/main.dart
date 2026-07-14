import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

import 'device.dart';
import 'updater.dart';
import 'version.dart';

/// Loaded during the splash screen, then read by every screen.
late final Content content;
bool _contentReady = false;

/// Loads [content] exactly once. Safe to call from the splash and from tests.
Future<void> ensureContentLoaded() async {
  if (_contentReady) return;
  content = await Content.load();
  _contentReady = true;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Paint the splash immediately; content loads in the background so the
  // first frame never waits on disk I/O (important on the Pi kiosk).
  runApp(const DyscoverApp());
}

// ---- Data -------------------------------------------------------------------

class Content {
  final List<Letter> letters;
  final List<Picture> pictures;
  const Content(this.letters, this.pictures);

  static Future<Content> load() async {
    final j = json.decode(await rootBundle.loadString('assets/content.json'))
        as Map<String, dynamic>;
    return Content(
      (j['letters'] as List).map((e) => Letter.fromJson(e as Map)).toList(),
      (j['pictures'] as List).map((e) => Picture.fromJson(e as Map)).toList(),
    );
  }
}

class Letter {
  final String id, label, exampleWord, nameAudio, soundAudio, wordAudio, image;
  final Color color;
  Letter.fromJson(Map j)
      : id = j['id'] as String,
        label = j['label'] as String,
        exampleWord = (j['example_word'] ?? '') as String,
        nameAudio = j['name_audio'] as String,
        soundAudio = j['sound_audio'] as String,
        wordAudio = (j['word_audio'] ?? '') as String,
        image = (j['image'] ?? '') as String,
        color = Color(
          int.parse((j['color'] as String).replaceFirst('#', '0xFF')),
        );
}

class Picture {
  final String id, label, image, wordAudio;
  Picture.fromJson(Map j)
      : id = j['id'] as String,
        label = j['label'] as String,
        image = j['image'] as String,
        wordAudio = j['word_audio'] as String;
}

// ---- Audio: ONE reused player (flutter-pi guidance) -------------------------

class Audio {
  static final AudioPlayer _p = AudioPlayer(playerId: 'main')
    ..setReleaseMode(ReleaseMode.stop);

  /// Play a single asset clip, interrupting whatever is playing.
  static Future<void> play(String path) async {
    if (path.isEmpty) return;
    await _p.stop();
    await _p.play(AssetSource(path)); // resolves assets/<path>
  }

  /// Play clips back-to-back (e.g. letter name, then phonic sound).
  static Future<void> sequence(List<String> paths) async {
    for (final p in paths) {
      if (p.isEmpty) continue;
      await play(p);
      await _p.onPlayerComplete.first;
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }
}

// ---- UI ---------------------------------------------------------------------

const Color kBackground = Color(0xFFFFF8EE);
const Color kBrand = Color(0xFF4C8BF5);

class DyscoverApp extends StatelessWidget {
  const DyscoverApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dyscover ABC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kBackground,
          colorScheme: ColorScheme.fromSeed(seedColor: kBrand),
        ),
        home: const SplashScreen(),
      );
}

/// Instant-paint splash: shows the brand while [Content.load] runs, then
/// fades into the home screen. Never blocks the first frame.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await ensureContentLoaded();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.94, end: 1.06).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _SplashBlock('A', Color(0xFFE8563F)),
                    SizedBox(width: 16),
                    _SplashBlock('B', Color(0xFF3FA34D)),
                    SizedBox(width: 16),
                    _SplashBlock('C', Color(0xFF4C8BF5)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Dyscover ',
                        style: TextStyle(color: Colors.black87)),
                    TextSpan(text: 'ABC', style: TextStyle(color: kBrand)),
                  ],
                ),
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            ],
          ),
        ),
      );
}

class _SplashBlock extends StatelessWidget {
  final String letter;
  final Color color;
  const _SplashBlock(this.letter, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                blurRadius: 16, color: Colors.black26, offset: Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Text(letter,
              style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Dyscover ',
                        style: TextStyle(color: Colors.black87)),
                    TextSpan(text: 'ABC', style: TextStyle(color: kBrand)),
                  ],
                ),
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('Tap to learn and play',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.45))),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bigButton(context, Icons.sort_by_alpha_rounded, 'Letters',
                      const Color(0xFFE8563F),
                      () => _go(context, const LettersScreen())),
                  const SizedBox(width: 40),
                  _bigButton(context, Icons.photo_library_rounded, 'Pictures',
                      const Color(0xFF4C8BF5),
                      () => _go(context, const PicturesScreen())),
                ],
              ),
            ],
          ),
            ),
            // Subtle grown-up corner: version + updates + credits.
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                iconSize: 40,
                color: Colors.black.withValues(alpha: 0.35),
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => _go(context, const AboutScreen()),
              ),
            ),
          ],
        ),
      );

  void _go(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  Widget _bigButton(BuildContext c, IconData icon, String label, Color color,
          VoidCallback onTap) =>
      TapTile(
        onTap: onTap,
        child: SizedBox(
          width: 320,
          height: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 140, color: color),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

/// A tile that scales up on press for immediate, tactile feedback.
/// When [selected] it draws a white ring so the active choice stands out.
class TapTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool selected;
  const TapTile({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Colors.white,
    this.selected = false,
  });

  @override
  State<TapTile> createState() => _TapTileState();
}

class _TapTileState extends State<TapTile> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _scale = 1.12),
        onTapUp: (_) {
          setState(() => _scale = 1);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(28),
              border: widget.selected
                  ? Border.all(color: Colors.white, width: 6)
                  : null,
              boxShadow: [
                BoxShadow(
                  blurRadius: widget.selected ? 30 : 20,
                  color: widget.selected ? Colors.black38 : Colors.black26,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(child: widget.child),
          ),
        ),
      );
}

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  Letter? _stage;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _bar(context, 'Letters'),
        body: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: content.letters
                    .map((l) => TapTile(
                          color: l.color,
                          selected: _stage?.id == l.id,
                          onTap: () {
                            setState(() => _stage = l);
                            Audio.sequence([l.nameAudio, l.soundAudio]);
                          },
                          // Fill the tile: the letter scales up to the card,
                          // leaving only a small margin.
                          child: SizedBox.expand(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  l.label,
                                  style: const TextStyle(
                                      fontSize: 100,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            if (_stage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    // The word card: tap to replay the example word.
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Audio.play(_stage!.wordAudio),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black26,
                                  offset: Offset(0, 8)),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Both cases together helps early readers pair them.
                              Text(
                                  '${_stage!.label}${_stage!.label.toLowerCase()}',
                                  style: TextStyle(
                                      fontSize: 96,
                                      fontWeight: FontWeight.w900,
                                      color: _stage!.color)),
                              const SizedBox(width: 24),
                              if (_stage!.image.isNotEmpty)
                                Image.asset('assets/${_stage!.image}',
                                    height: 160),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Text(_stage!.exampleWord,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 58,
                                        fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 20),
                              Icon(Icons.volume_up_rounded,
                                  size: 44,
                                  color: Colors.black.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Trace: open the full-screen tracing canvas for this letter.
                    TapTile(
                      color: _stage!.color,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TraceScreen(_stage!)),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gesture_rounded,
                                size: 64, color: Colors.white),
                            SizedBox(height: 2),
                            Text('Trace',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

/// Full-screen tracing canvas (Release 1, issue #1). The child draws the
/// letter with a finger over a faint guide glyph. This adds the kinesthetic
/// (touch + movement) channel the Orton-Gillingham approach calls its most
/// effective, turning Letters from tap-to-hear into multi-sensory.
///
/// Deliberately scoped: accuracy scoring (#3), an animated stroke guide (#2),
/// and star/voice feedback (#4) arrive in later issues.
class TraceScreen extends StatefulWidget {
  final Letter letter;
  const TraceScreen(this.letter, {super.key});

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  // Each entry is one continuous stroke (finger down until finger up). Keeping
  // strokes separate stops multi-stroke letters (A, K, T...) from being joined
  // by a stray line when the finger lifts and starts again.
  final List<List<Offset>> _strokes = [];

  @override
  void initState() {
    super.initState();
    _say(); // hear the letter while tracing it: audio and touch together
  }

  void _say() =>
      Audio.sequence([widget.letter.nameAudio, widget.letter.soundAudio]);

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    return Scaffold(
      appBar: _bar(context, 'Trace ${l.label}'),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, box) {
                  // A square writing surface, as large as the space allows.
                  final side = math.min(box.maxWidth, box.maxHeight) - 24;
                  return Container(
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 24,
                            color: Colors.black26,
                            offset: Offset(0, 10)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Guide track: the letter to trace, drawn faintly.
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                l.label,
                                style: TextStyle(
                                  fontSize: 100,
                                  fontWeight: FontWeight.w900,
                                  color: l.color.withValues(alpha: 0.20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Drawing surface: capture the finger path.
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (d) => setState(
                                () => _strokes.add([d.localPosition])),
                            onPanUpdate: (d) => setState(
                                () => _strokes.last.add(d.localPosition)),
                            child: CustomPaint(
                              painter: _TracePainter(_strokes, l.color),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  icon: Icons.volume_up_rounded,
                  label: 'Hear it',
                  color: kBrand,
                  onTap: _say,
                ),
                const SizedBox(width: 20),
                _controlButton(
                  icon: Icons.refresh_rounded,
                  label: 'Clear',
                  color: const Color(0xFFE28413),
                  onTap:
                      _strokes.isEmpty ? null : () => setState(_strokes.clear),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) =>
      TapTile(
        color: onTap == null ? color.withValues(alpha: 0.35) : color,
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        ),
      );
}

/// Paints the child's finger strokes as smooth, rounded colored lines.
class _TracePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  const _TracePainter(this.strokes, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = color;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        // A touch that never moved still leaves a mark where it landed.
        canvas.drawCircle(stroke.first, 13, dot);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, line);
    }
  }

  // The stroke list is mutated in place between rebuilds, so always repaint.
  @override
  bool shouldRepaint(_TracePainter oldDelegate) => true;
}

class PicturesScreen extends StatelessWidget {
  const PicturesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _bar(context, 'Pictures'),
        body: GridView.count(
          crossAxisCount: 4,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: content.pictures
              .map((p) => TapTile(
                    onTap: () => Audio.play(p.wordAudio),
                    // Fill the card: the picture takes all the space above a
                    // large label, leaving little whitespace.
                    child: SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/${p.image}',
                                  fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 4),
                            Text(p.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
}

PreferredSizeWidget _bar(BuildContext c, String title) => AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 96,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: TapTile(
          onTap: () => Navigator.pop(c),
          child: const Icon(Icons.arrow_back_rounded,
              size: 44, color: Colors.black87),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black87)),
    );

/// Grown-up screen: app identity, version, manual update check, and credits.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _checking = false;
  bool _updating = false;
  bool _switching = false;
  String? _deskError;
  UpdateStatus? _status;

  Future<void> _exitToDesktop() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PinPad(),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _switching = true;
      _deskError = null;
    });
    final err = await exitToDesktop();
    // On success the kiosk service stops and this app is torn down, so we only
    // get here again if it failed.
    if (!mounted) return;
    setState(() {
      _switching = false;
      _deskError = err;
    });
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _status = null;
    });
    final s = await checkForUpdate();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _status = s;
    });
  }

  Future<void> _update() async {
    setState(() => _updating = true);
    final err = await triggerUpdate();
    if (!mounted) return;
    // On success the kiosk service restarts and tears this app down, so we only
    // land here again if it failed.
    setState(() {
      _updating = false;
      if (err != null) _status = UpdateStatus(error: err);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _bar(context, 'About'),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _SplashBlock('A', Color(0xFFE8563F)),
                      SizedBox(width: 12),
                      _SplashBlock('B', Color(0xFF3FA34D)),
                      SizedBox(width: 12),
                      _SplashBlock('C', Color(0xFF4C8BF5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Dyscover ',
                            style: TextStyle(color: Colors.black87)),
                        TextSpan(text: 'ABC', style: TextStyle(color: kBrand)),
                      ],
                    ),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(kAppTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.5))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: const [
                      _Chip('Version $kAppVersion'),
                      _Chip('flutter-pi kiosk'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _updateCard(),
                  const SizedBox(height: 20),
                  _deviceCard(),
                  const SizedBox(height: 28),
                  const _AboutLink(
                    icon: Icons.science_rounded,
                    color: kBrand,
                    title: kLabName,
                    subtitle: kLabAffiliation,
                    url: kLabUrl,
                  ),
                  const SizedBox(height: 16),
                  const _AboutLink(
                    icon: Icons.code_rounded,
                    color: Color(0xFF566573),
                    title: 'Source code',
                    subtitle: kGithubRepo,
                    url: kGithubUrl,
                  ),
                  const SizedBox(height: 28),
                  Text('© 2026 $kLabName',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black.withValues(alpha: 0.4))),
                  const SizedBox(height: 4),
                  Text('Picture artwork: Google Noto Emoji (Apache 2.0)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.35))),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _updateCard() {
    final s = _status;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              blurRadius: 18, color: Colors.black12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.system_update_rounded, size: 30, color: kBrand),
              const SizedBox(width: 12),
              const Text('Software updates',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_statusLine(),
              style: TextStyle(
                  fontSize: 18,
                  color: s?.ok == false
                      ? const Color(0xFFC0392B)
                      : Colors.black.withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: (_checking || _updating) ? null : _check,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18)),
                icon: _checking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white))
                    : const Icon(Icons.refresh_rounded),
                label: Text(_checking ? 'Checking…' : 'Check for updates',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (s != null && s.updateAvailable) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _updating ? null : _update,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3FA34D),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18)),
                  icon: _updating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.white))
                      : const Icon(Icons.download_rounded),
                  label: Text(_updating ? 'Updating…' : 'Update now',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _deviceCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                blurRadius: 18, color: Colors.black12, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.desktop_windows_rounded, size: 30, color: kBrand),
                SizedBox(width: 12),
                Text('Device',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _switching
                  ? 'Switching to the desktop…'
                  : _deskError ??
                      'Leave the kiosk for the Raspberry Pi desktop (Wi-Fi, '
                          'settings, files). Reboot to return to the kiosk.',
              style: TextStyle(
                  fontSize: 18,
                  color: _deskError != null
                      ? const Color(0xFFC0392B)
                      : Colors.black.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _switching ? null : _exitToDesktop,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE28413),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18)),
                icon: _switching
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white))
                    : const Icon(Icons.logout_rounded),
                label: Text(_switching ? 'Please wait…' : 'Exit to desktop',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );

  String _statusLine() {
    if (_updating) return 'Downloading and installing. The app will restart.';
    final s = _status;
    if (s == null) {
      return 'You are on version $kAppVersion. Tap to check for a newer one.';
    }
    if (!s.ok) return s.error!;
    if (s.updateAvailable) {
      final notes = (s.notes?.isNotEmpty ?? false) ? '\n${s.notes}' : '';
      return 'Update available: version ${s.latest}.$notes';
    }
    return 'You are up to date (version $kAppVersion).';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kBrand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: kBrand)),
      );
}

/// A credit row. The kiosk has no browser, so the URL is shown as text for a
/// visitor to type or scan, not opened in-app.
class _AboutLink extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, url;
  const _AboutLink({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                blurRadius: 14, color: Colors.black12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withValues(alpha: 0.55))),
                  const SizedBox(height: 2),
                  Text(url,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ],
        ),
      );
}

/// On-screen numeric keypad for the grown-up PIN (the kiosk has no keyboard).
/// Pops `true` when [kAdminPin] is entered, `false` on cancel.
class _PinPad extends StatefulWidget {
  const _PinPad();

  @override
  State<_PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<_PinPad> {
  String _entered = '';
  bool _error = false;

  void _tap(String d) {
    if (_entered.length >= kAdminPin.length) return;
    setState(() {
      _error = false;
      _entered += d;
    });
    if (_entered.length == kAdminPin.length) {
      if (_entered == kAdminPin) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = true;
          _entered = '';
        });
      }
    }
  }

  void _back() {
    if (_entered.isEmpty) return;
    setState(() {
      _error = false;
      _entered = _entered.substring(0, _entered.length - 1);
    });
  }

  Widget _key(String label, VoidCallback onTap, {IconData? icon}) => Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          width: 84,
          height: 68,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: icon != null
                ? Icon(icon, size: 26)
                : Text(label,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w800)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Enter grown-up PIN', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(kAdminPin.length, (i) {
                final filled = i < _entered.length;
                return Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? kBrand : Colors.transparent,
                    border: Border.all(
                        color: _error ? const Color(0xFFC0392B) : kBrand,
                        width: 2),
                  ),
                );
              }),
            ),
            SizedBox(
              height: 26,
              child: Center(
                child: _error
                    ? const Text('Wrong PIN, try again',
                        style: TextStyle(color: Color(0xFFC0392B)))
                    : const SizedBox.shrink(),
              ),
            ),
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (final d in row) _key(d, () => _tap(d))],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 92),
                _key('0', () => _tap('0')),
                _key('', _back, icon: Icons.backspace_outlined),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
        ],
      );
}
