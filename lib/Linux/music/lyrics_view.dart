import 'package:flutter/material.dart';

import 'lrc_parser.dart';

class StellarLyricsView
    extends StatefulWidget {
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

  final Map<int, GlobalKey> _keys =
      <int, GlobalKey>{};

  int _lastIndex = -1;

  @override
  void didUpdateWidget(
    covariant StellarLyricsView oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lines != widget.lines) {
      _keys.clear();
      _lastIndex = -1;
    }

    _updateScroll();
  }

  GlobalKey _keyFor(int index) {
    return _keys.putIfAbsent(
      index,
      () => GlobalKey(),
    );
  }

  void _updateScroll() {
    if (widget.lines.isEmpty) {
      return;
    }

    final index =
        StellarLrcParser.activeIndex(
      widget.lines,
      widget.position,
    );

    if (index < 0 ||
        index == _lastIndex) {
      return;
    }

    _lastIndex = index;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted ||
          !_controller.hasClients) {
        return;
      }

      final key = _keys[index];

      if (key == null) {
        return;
      }

      final context = key.currentContext;

      if (context == null) {
        return;
      }

      Scrollable.ensureVisible(
        context,
        alignment: .5,
        duration: const Duration(
          milliseconds: 420,
        ),
        curve: Curves.easeOutCubic,
      );
    });
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
            fontSize: 15,
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
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 120,
      ),
      itemCount: widget.lines.length,
      itemBuilder: (
        context,
        index,
      ) {
        final active =
            index == activeIndex;

        return KeyedSubtree(
          key: _keyFor(index),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 280,
            ),
            curve: Curves.easeOutCubic,
            padding:
                const EdgeInsets.symmetric(
              vertical: 9,
            ),
            child:
                AnimatedDefaultTextStyle(
              duration: const Duration(
                milliseconds: 280,
              ),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.white
                        .withOpacity(.30),
                fontSize:
                    active ? 25 : 16,
                fontWeight: active
                    ? FontWeight.w800
                    : FontWeight.w500,
                height: 1.35,
              ),
              child: Text(
                widget.lines[index].text,
                textAlign:
                    TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
