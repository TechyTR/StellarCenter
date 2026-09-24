import 'dart:math' as math;

import 'package:flutter/material.dart';

class StellarMusicBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const StellarMusicBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  @override
  State<StellarMusicBackground> createState() =>
      _StellarMusicBackgroundState();
}

class _StellarMusicBackgroundState
    extends State<StellarMusicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors.length >= 4
        ? widget.colors
        : [
            Colors.blue,
            Colors.purple,
            Colors.pink,
            Colors.cyan,
          ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    math.cos(t) * .7,
                    math.sin(t) * .7,
                  ),
                  end: Alignment(
                    -math.cos(t) * .7,
                    -math.sin(t) * .7,
                  ),
                  colors: [
                    colors[0],
                    colors[1],
                    colors[2],
                    colors[3],
                  ],
                ),
              ),
            ),

            _Orb(
              color: colors[0],
              x: .18 + math.sin(t * .7) * .22,
              y: .20 + math.cos(t * .9) * .18,
              size: 420,
            ),

            _Orb(
              color: colors[2],
              x: .78 + math.cos(t * .8) * .20,
              y: .32 + math.sin(t * .6) * .25,
              size: 480,
            ),

            _Orb(
              color: colors[3],
              x: .48 + math.sin(t * .5) * .28,
              y: .82 + math.cos(t * .8) * .14,
              size: 360,
            ),

            Container(
              color: Colors.black.withOpacity(.20),
            ),

            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double x;
  final double y;
  final double size;

  const _Orb({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(
        x * 2 - 1,
        y * 2 - 1,
      ),
      child: ImageFiltered(
        imageFilter: const ColorFilter.blur(
          sigmaX: 60,
          sigmaY: 60,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.72),
          ),
        ),
      ),
    );
  }
}
