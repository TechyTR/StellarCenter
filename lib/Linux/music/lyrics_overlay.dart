import 'package:flutter/material.dart';

import 'lrc_parser.dart';
import 'lyrics_loader.dart';
import 'music_track.dart';

class StellarLyricsOverlay extends StatefulWidget {
  final StellarMusicTrack track;
  final Duration position;

  const StellarLyricsOverlay({
    super.key,
    required this.track,
    required this.position,
  });

  @override
  State<StellarLyricsOverlay> createState() => _StellarLyricsOverlayState();
}

class _StellarLyricsOverlayState extends State<StellarLyricsOverlay> {
  List<StellarLrcLine> _lines = const [];
  bool _loading = true;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StellarLyricsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.path != widget.track.path ||
        oldWidget.track.lyricsPath != widget.track.lyricsPath ||
        oldWidget.track.lyricsText != widget.track.lyricsText) {
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final path = widget.track.lyricsPath;

    if (mounted) {
      setState(() {
        _loading = true;
        _lines = const [];
      });
    }

    if (path != null && path.trim().isNotEmpty) {
      try {
        final document = await StellarLyricsLoader.loadDocument(path);
        if (!mounted || generation != _loadGeneration) return;
        if (document.lines.isNotEmpty) {
          setState(() {
            _lines = document.lines;
            _loading = false;
          });
          return;
        }
      } catch (_) {
        // Fall back to embedded lyrics if the sidecar cannot be read.
      }
    }

    final embedded = widget.track.lyricsText;
    if (embedded != null && embedded.trim().isNotEmpty) {
      final parsed = StellarLrcParser.parse(embedded);
      final lines = parsed.isNotEmpty ? parsed : _plainTextToLines(embedded);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _lines = lines;
        _loading = false;
      });
      return;
    }

    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _lines = const [];
      _loading = false;
    });
  }

  List<StellarLrcLine> _plainTextToLines(String content) {
    final result = <StellarLrcLine>[];
    var index = 0;
    for (final raw in content.split(RegExp(r'\r?\n'))) {
      final text = raw.trim();
      if (text.isEmpty) continue;
      result.add(
        StellarLrcLine(
          timestamp: Duration(seconds: index),
          text: text,
        ),
      );
      index++;
    }
    return List.unmodifiable(result);
  }

  @override
  void dispose() {
    _loadGeneration++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (_lines.isEmpty) {
      return const Center(
        child: Text(
          'Şarkı sözü bulunamadı',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    final activeIndex = StellarLrcParser.activeIndex(_lines, widget.position);
    final visibleIndex = activeIndex < 0 ? 0 : activeIndex;
    final start = (visibleIndex - 2).clamp(0, _lines.length).toInt();
    final end = (visibleIndex + 4).clamp(start, _lines.length).toInt();

    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = start; i < end; i++)
              _LyricLine(
                key: ValueKey('${widget.track.path}-$i'),
                text: _lines[i].text,
                active: i == activeIndex || (activeIndex < 0 && i == 0),
              ),
          ],
        ),
      ),
    );
  }
}

class _LyricLine extends StatelessWidget {
  final String text;
  final bool active;

  const _LyricLine({
    super.key,
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: active ? 9 : 5),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        style: TextStyle(
          color: active ? Colors.white : Colors.white.withOpacity(.32),
          fontSize: active ? 20 : 14,
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          height: 1.35,
          shadows: active
              ? [
                  Shadow(
                    color: Colors.black.withOpacity(.35),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
