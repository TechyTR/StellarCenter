import 'package:flutter/material.dart';

import 'lrc_parser.dart';

class StellarLyricsView extends StatefulWidget {
  final List<StellarLyricLine> lines;
  final Duration position;

  const StellarLyricsView({
    super.key,
    required this.lines,
    required this.position,
  });

  @override
  State<StellarLyricsView> createState() =>
      _StellarLyricsViewState();
}

class _StellarLyricsViewState
    extends State<StellarLyricsView> {
  final ScrollController _controller =
      ScrollController();

  int _lastIndex = -1;

  @override
  void didUpdateWidget(
    covariant StellarLyricsView oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    _scrollToActiveLine();
  }

  void _scrollToActiveLine() {
    if (widget.lines.isEmpty) {
      return;
    }

    final index = StellarLrcParser.activeIndex(
      widget.lines,
      widget.position,
    );

    if (index < 0 ||
        index == _lastIndex) {
      return;
    }

    _lastIndex = index;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!_controller.hasClients) {
          return;
        }

        final target =
            (index * 64.0)
                .clamp(
                  0.0,
                  _controller.position.maxScrollExtent,
                )
                .toDouble();

        _controller.animateTo(
          target,
          duration: const Duration(
            milliseconds: 350,
          ),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex =
        StellarLrcParser.activeIndex(
      widget.lines,
      widget.position,
    );

    if (widget.lines.isEmpty) {
      return const Center(
        child: Text(
          'Bu şarkı için söz bulunamadı.',
        ),
      );
    }

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        final active =
            index == activeIndex;

        return AnimatedDefaultTextStyle(
          duration: const Duration(
            milliseconds: 220,
          ),
          style: TextStyle(
            fontSize: active ? 24 : 17,
            height: 1.45,
            fontWeight: active
                ? FontWeight.w800
                : FontWeight.w500,
            color: active
                ? Colors.white
                : Colors.white.withOpacity(
                    0.48,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              widget.lines[index].text.isEmpty
                  ? '♪'
                  : widget.lines[index].text,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
