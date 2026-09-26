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

    if (oldWidget.track.lyricsPath !=
        widget.track.lyricsPath) {
      _load();
    }
  }

  Future<void> _load() async {
    final path = widget.track.lyricsPath;

    if (path == null || path.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        _lines = const [];
        _loadedPath = null;
      });

      return;
    }

    final lines =
        await StellarLyricsLoader.load(path);

    if (!mounted) return;

    setState(() {
      _lines = lines;
      _loadedPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeIndex =
        StellarLrcParser.activeIndex(
      _lines,
      widget.position,
    );

    if (activeIndex < 0) {
      return _LyricLine(
        text: _lines.first.text,
        active: false,
      );
    }

    final start = _clamp(
      activeIndex - 2,
      0,
      _lines.length,
    );

    final end = _clamp(
      activeIndex + 3,
      start,
      _lines.length,
    );

    return AnimatedSize(
      duration: const Duration(
        milliseconds: 250,
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
              active: i == activeIndex,
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
              : Colors.white.withOpacity(0.34),
          fontSize: active ? 21 : 14,
          fontWeight: active
              ? FontWeight.w800
              : FontWeight.w500,
          height: 1.3,
          shadows: active
              ? [
                  Shadow(
                    color: Colors.black.withOpacity(
                      0.35,
                    ),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
