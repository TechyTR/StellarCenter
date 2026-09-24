import 'dart:async';

import 'package:flutter/material.dart';

import 'lrc_parser.dart';
import 'stellar_lyrics_loader.dart';

class StellarLyricsOverlay extends StatefulWidget {
  final String? lyricsPath;
  final Duration position;

  const StellarLyricsOverlay({
    super.key,
    required this.lyricsPath,
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

    if (oldWidget.lyricsPath != widget.lyricsPath) {
      _load();
    }
  }

  Future<void> _load() async {
    final lines = await StellarLyricsLoader.load(
      widget.lyricsPath,
    );

    if (!mounted) return;

    setState(() {
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const Center(
        child: Text(
          'Bu şarkı için senkronize söz bulunamadı.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 15,
          ),
        ),
      );
    }

    final activeIndex =
        StellarLrcParser.activeIndex(
      _lines,
      widget.position,
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 30,
      ),
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        final line = _lines[index];
        final active = index == activeIndex;
        final previous = index == activeIndex - 1;
        final next = index == activeIndex + 1;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: active
              ? 1
              : previous || next
                  ? .55
                  : .30,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: active ? 27 : 19,
              height: 1.5,
              fontWeight: active
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Text(
                line.text,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
