import 'package:flutter/material.dart';

import 'lrc_parser.dart';
import 'music_track.dart';
import 'stellar_lyrics_loader.dart';

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
    final lines = await StellarLyricsLoader.load(
      widget.track.lyricsPath,
    );

    if (!mounted) return;

    setState(() {
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeIndex = StellarLrcParser.activeIndex(
      _lines,
      widget.position,
    );

    final start = (activeIndex - 2).clamp(
      0,
      _lines.length - 1,
    );

    final end = (activeIndex + 3).clamp(
      0,
      _lines.length,
    );

    final visible = _lines.sublist(start, end);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          _LyricLine(
            text: visible[i].text,
            active: start + i == activeIndex,
          ),
      ],
    );
  }
}

class _LyricLine extends StatelessWidget {
  final String text;
  final bool active;

  const _LyricLine({
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 7,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          fontSize: active ? 22 : 15,
          height: 1.25,
          fontWeight:
              active ? FontWeight.w700 : FontWeight.w500,
          color: active
              ? Colors.white
              : Colors.white.withOpacity(0.38),
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
