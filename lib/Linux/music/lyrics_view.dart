import 'package:flutter/material.dart';

import 'lrc_parser.dart';

class StellarLyricsView extends StatefulWidget {
  final List<StellarLrcLine> lines;
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

    _updateScroll();
  }

  void _updateScroll() {
    if (widget.lines.isEmpty) return;

    final index =
        StellarLrcParser.activeIndex(
      widget.lines,
      widget.position,
    );

    if (index < 0 || index == _lastIndex) {
      return;
    }

    _lastIndex = index;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_controller.hasClients) {
          return;
        }

        final target =
            (index * 62.0).clamp(
          0.0,
          _controller.position.maxScrollExtent,
        );

        _controller.animateTo(
          target.toDouble(),
          duration: const Duration(
            milliseconds: 420,
          ),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lines.isEmpty) {
      return const Center(
        child: Text(
          'Bu şarkı için söz bulunamadı.',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    final activeIndex =
        StellarLrcParser.activeIndex(
      widget.lines,
      widget.position,
    );

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 100,
      ),
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        final active =
            index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 280,
          ),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(
              milliseconds: 280,
            ),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : Colors.white.withOpacity(0.38),
              fontSize: active ? 24 : 17,
              fontWeight: active
                  ? FontWeight.w800
                  : FontWeight.w500,
              height: 1.4,
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
