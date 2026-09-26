import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'music_colors.dart';

class StellarMusicBackground
    extends StatefulWidget {
  final Widget child;
  final Uint8List? artwork;

  const StellarMusicBackground({
    super.key,
    required this.child,
    this.artwork,
  });

  @override
  State<StellarMusicBackground> createState() =>
      _StellarMusicBackgroundState();
}

class _StellarMusicBackgroundState
    extends State<StellarMusicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<Color> _colors =
      StellarMusicColors.defaultColors;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _loadColors();
  }

  @override
  void didUpdateWidget(
    covariant StellarMusicBackground oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (!_sameArtwork(
      oldWidget.artwork,
      widget.artwork,
    )) {
      _loadColors();
    }
  }

  Future<void> _loadColors() async {
    final colors =
        await StellarMusicColors
            .fromArtworkAsync(
      widget.artwork,
    );

    if (!mounted) return;

    setState(() {
      _colors = colors;
    });
  }

  bool _sameArtwork(
    Uint8List? a,
    Uint8List? b,
  ) {
    if (identical(a, b)) return true;

    if (a == null || b == null) {
      return a == b;
    }

    if (a.length != b.length) {
      return false;
    }

    if (a.isEmpty) return true;

    final middle = a.length ~/ 2;

    return a.first == b.first &&
        a[middle] == b[middle] &&
        a.last == b.last;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + t * 2,
                      -1,
                    ),
                    end: Alignment(
                      1,
                      1 - t * 2,
                    ),
                    colors: _colors,
                  ),
                ),
              ),
              _Glow(
                color: _colors[0],
                alignment: Alignment(
                  -0.8 + t * 1.6,
                  -0.65,
                ),
                size: 500,
              ),
              _Glow(
                color: _colors[
                    _colors.length > 1 ? 1 : 0],
                alignment: Alignment(
                  0.75,
                  0.35 - t * .7,
                ),
                size: 460,
              ),
              _Glow(
                color: _colors[
                    _colors.length > 2 ? 2 : 0],
                alignment: Alignment(
                  -0.2,
                  0.9 - t * .4,
                ),
                size: 380,
              ),
              Container(
                color: Colors.black.withOpacity(.38),
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double size;

  const _Glow({
    required this.color,
    required this.alignment,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.18),
                blurRadius: 100,
                spreadRadius: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
