import 'dart:async';
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

  Uint8List? _loadedArtwork;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 18,
      ),
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

  bool _sameArtwork(
    Uint8List? a,
    Uint8List? b,
  ) {
    if (identical(a, b)) {
      return true;
    }

    if (a == null || b == null) {
      return false;
    }

    if (a.length != b.length) {
      return false;
    }

    if (a.isEmpty) {
      return true;
    }

    return a.first == b.first &&
        a[a.length ~/ 2] ==
            b[b.length ~/ 2] &&
        a.last == b.last;
  }

  Future<void> _loadColors() async {
    final artwork = widget.artwork;

    final colors =
        await StellarMusicColors.fromArtworkAsync(
      artwork,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _colors = colors;
      _loadedArtwork = artwork;
    });
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
        builder: (context, child) {
          final t = _controller.value;

          final x1 =
              -1.0 + (t * 2.0);
          final y1 =
              -0.8 + (t * 1.6);

          final x2 =
              1.0 - (t * 2.0);
          final y2 =
              0.8 - (t * 1.6);

          final color1 =
              _colors[0 % _colors.length];
          final color2 =
              _colors[1 % _colors.length];
          final color3 =
              _colors[2 % _colors.length];
          final color4 =
              _colors[3 % _colors.length];

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  x1,
                  y1,
                ),
                end: Alignment(
                  x2,
                  y2,
                ),
                colors: [
                  Color.lerp(
                    color1,
                    color3,
                    t,
                  )!,
                  Color.lerp(
                    color2,
                    color4,
                    t,
                  )!,
                  Colors.black,
                ],
                stops: const [
                  0.0,
                  0.55,
                  1.0,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Glow(
                  alignment: Alignment(
                    -0.75 + t * 1.5,
                    -0.65,
                  ),
                  radius: 0.72,
                  color: color1,
                  opacity: 0.18,
                ),
                _Glow(
                  alignment: Alignment(
                    0.75 - t * 1.5,
                    0.55,
                  ),
                  radius: 0.62,
                  color: color2,
                  opacity: 0.14,
                ),
                _Glow(
                  alignment: Alignment(
                    -0.15,
                    0.85 - t * 1.7,
                  ),
                  radius: 0.52,
                  color: color3,
                  opacity: 0.11,
                ),
                _Glow(
                  alignment: Alignment(
                    0.35,
                    -0.85 + t * 1.7,
                  ),
                  radius: 0.45,
                  color: color4,
                  opacity: 0.09,
                ),
                child!,
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final double radius;
  final Color color;
  final double opacity;

  const _Glow({
    required this.alignment,
    required this.radius,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: radius,
        heightFactor: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(opacity),
                color.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
