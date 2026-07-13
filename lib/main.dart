import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

/// Loaded once at startup and read by every screen.
late final Content content;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  content = await Content.load();
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

class DyscoverApp extends StatelessWidget {
  const DyscoverApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dyscover',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFF8EE)),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bigButton(context, '🔤', 'Letters',
                  () => _go(context, const LettersScreen())),
              const SizedBox(width: 40),
              _bigButton(context, '🖼️', 'Pictures',
                  () => _go(context, const PicturesScreen())),
            ],
          ),
        ),
      );

  void _go(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  Widget _bigButton(
          BuildContext c, String emoji, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 24, color: Colors.black26, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 120)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

/// A tile that scales up on press for immediate, tactile feedback.
class TapTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  const TapTile({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Colors.white,
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
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 20, color: Colors.black26, offset: Offset(0, 8)),
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
                          onTap: () {
                            setState(() => _stage = l);
                            Audio.sequence([l.nameAudio, l.soundAudio]);
                          },
                          child: Text(
                            l.label,
                            style: const TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ))
                    .toList(),
              ),
            ),
            if (_stage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Audio.play(_stage!.wordAudio),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_stage!.label,
                          style: TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w900,
                              color: _stage!.color)),
                      const SizedBox(width: 24),
                      if (_stage!.image.isNotEmpty)
                        Image.asset('assets/${_stage!.image}', height: 140),
                      const SizedBox(width: 24),
                      Text(_stage!.exampleWord,
                          style: const TextStyle(
                              fontSize: 56, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/${p.image}', height: 120),
                        Text(p.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}

PreferredSizeWidget _bar(BuildContext c, String title) => AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 96,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: TapTile(
          onTap: () => Navigator.pop(c),
          child: const Text('⬅', style: TextStyle(fontSize: 40)),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black87)),
    );
