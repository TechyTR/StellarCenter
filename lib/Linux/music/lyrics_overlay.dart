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
  State<StellarLyricsOverlay> createState() =>
      _StellarLyricsOverlayState();
}

class _StellarLyricsOverlayState
    extends State<StellarLyricsOverlay> {
  List<StellarLrcLine> _lines = const [];

  String? _loadedPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(
    covariant StellarLyricsOverlay oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.track.path != widget.track.path ||
        oldWidget.track.lyricsPath !=
            widget.track.lyricsPath ||
        oldWidget.track.lyricsText !=
            widget.track.lyricsText) {
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _lines = const [];
      });
    }

    /*
     * 1. Harici .lrc dosyası.
     */
    final path = widget.track.lyricsPath;

    if (path != null && path.trim().isNotEmpty) {
      try {
        final document =
            await StellarLyricsLoader.loadDocument(path);

        if (document.lines.isNotEmpty) {
          if (!mounted) {
            return;
          }

          setState(() {
            _lines = document.lines;
            _loadedPath = path;
            _loading = false;
          });

          return;
        }
      } catch (_) {
        // Embedded lyrics'e geç.
      }
    }

    /*
     * 2. MP3 metadata içindeki lyrics.
     */
    final embedded = widget.track.lyricsText;

    if (embedded != null &&
        embedded.trim().isNotEmpty) {
      final parsed =
          StellarLrcParser.parse(embedded);

      if (parsed.isNotEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _lines = parsed;
          _loadedPath = null;
          _loading = false;
        });

        return;
      }

      /*
       * Timestamp yoksa düz sözleri satır satır göster.
       */
      final plain =
          _plainTextToLines(embedded);

      if (!mounted) {
        return;
      }

      setState(() {
        _lines = plain;
        _loadedPath = null;
        _loading = false;
      });

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _lines = const [];
      _loadedPath = null;
      _loading = false;
    });
  }

  List<StellarLrcLine> _plainTextToLines(
    String content,
  ) {
    final result = <StellarLrcLine>[];

    final rawLines =
        content.split(RegExp(r'\r?\n'));

    var index = 0;

    for (final raw in rawLines) {
      final text = raw.trim();

      if (text.isEmpty) {
        continue;
      }

      result.add(
        StellarLrcLine(
          timestamp: Duration(
            seconds: index,
          ),
          text: text,
        ),
      );

      index++;
    }

    return List.unmodifiable(result);
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
          style: TextStyle(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),
      );
    }

    final activeIndex =
        StellarLrcParser.activeIndex(
      _lines,
      widget.position,
    );

    final visibleIndex =
        activeIndex < 0 ? 0 : activeIndex;

    /*
     * Aktif satırın etrafında birkaç satır göster.
     */
    final start = _clamp(
      visibleIndex - 2,
      0,
      _lines.length,
    );

    final end = _clamp(
      visibleIndex + 4,
      start,
      _lines.length,
    );

    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOutCubic,
        child: SingleChildScrollView(
          physics:
              const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = start; i < end; i++)
                _LyricLine(
                  key: ValueKey(
                    '${_loadedPath ?? widget.track.path}-$i',
                  ),
                  text: _lines[i].text,
                  active:
                      i == activeIndex ||
                      (activeIndex < 0 && i == 0),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _clamp(
    int value,
    int min,
    int max,
  ) {
    if (value < min) {
      return min;
    }

    if (value > max) {
      return max;
    }

    return value;
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
      duration: const Duration(
        milliseconds: 220,
      ),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: active ? 9 : 5,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          color: active
              ? Colors.white
              : Colors.white.withOpacity(.32),
          fontSize: active ? 20 : 14,
          fontWeight: active
              ? FontWeight.w800
              : FontWeight.w500,
          height: 1.35,
          shadows: active
              ? [
                  Shadow(
                    color:
                        Colors.black.withOpacity(.45),
                    blurRadius: 9,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.left,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
