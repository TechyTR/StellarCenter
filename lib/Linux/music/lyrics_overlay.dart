import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'lrc_parser.dart';
import 'lyrics_loader.dart';
import 'music_track.dart';

class StellarLyricsOverlay
    extends StatefulWidget {
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

    if (oldWidget.track.path !=
        widget.track.path) {
      _load();
      return;
    }

    if (oldWidget.track.lyricsPath !=
        widget.track.lyricsPath) {
      _load();
      return;
    }

    if (oldWidget.track.lyricsText !=
        widget.track.lyricsText) {
      _load();
    }
  }

  Future<void> _load() async {
    /*
     * 1. Önce LRC dosyasını dene.
     */
    final path = widget.track.lyricsPath;

    if (path != null &&
        path.trim().isNotEmpty) {
      final lines =
          await StellarLyricsLoader.load(
        path,
      );

      if (lines.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _lines = lines;
          _loadedPath = path;
        });

        return;
      }
    }

    /*
     * 2. LRC yoksa metadata içindeki
     * lyrics alanını kullan.
     */
    final embedded =
        widget.track.lyricsText;

    if (embedded != null &&
        embedded.trim().isNotEmpty) {
      final lines =
          StellarLrcParser.parse(
        embedded,
      );

      if (lines.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _lines = lines;
          _loadedPath = null;
        });

        return;
      }

      /*
       * Metadata'daki sözler timestamp
       * içermiyorsa da göster.
       */
      final plainLines =
          _plainTextToLines(embedded);

      if (!mounted) return;

      setState(() {
        _lines = plainLines;
        _loadedPath = null;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _lines = const [];
      _loadedPath = null;
    });
  }

  List<StellarLrcLine> _plainTextToLines(
    String content,
  ) {
    final lines = <StellarLrcLine>[];

    final rawLines =
        content.split(
      RegExp(r'\r?\n'),
    );

    var index = 0;

    for (final raw in rawLines) {
      final text =
          raw.trim();

      if (text.isEmpty) {
        continue;
      }

      lines.add(
        StellarLrcLine(
          timestamp: Duration(
            seconds: index,
          ),
          text: text,
        ),
      );

      index++;
    }

    return List.unmodifiable(lines);
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
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
        activeIndex < 0
            ? 0
            : activeIndex;

    final start = _clamp(
      visibleIndex - 2,
      0,
      _lines.length,
    );

    final end = _clamp(
      visibleIndex + 3,
      start,
      _lines.length,
    );

    return AnimatedSize(
      duration: const Duration(
        milliseconds: 260,
      ),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (
            var i = start;
            i < end;
            i++
          )
            _LyricLine(
              key: ValueKey(
                '${_loadedPath ?? widget.track.path}-$i',
              ),
              text: _lines[i].text,
              active:
                  i == activeIndex ||
                  (activeIndex < 0 &&
                      i == 0),
            ),
        ],
      ),
    );
  }

  int _clamp(
    int value,
    int min,
    int max,
  ) {
    if (value < min) return min;
    if (value > max) return max;

    return value;
  }
}

class _LyricLine
    extends StatelessWidget {
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
        milliseconds: 260,
      ),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: active ? 8 : 4,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(
          milliseconds: 260,
        ),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          color: active
              ? Colors.white
              : Colors.white.withOpacity(
                  0.34,
                ),
          fontSize: active ? 21 : 14,
          fontWeight: active
              ? FontWeight.w800
              : FontWeight.w500,
          height: 1.3,
          shadows: active
              ? [
                  Shadow(
                    color:
                        Colors.black.withOpacity(
                      .35,
                    ),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow:
              TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
