import 'dart:math' as math;

import 'package:flutter/material.dart';

class StellarMusicBackground extends StatefulWidget {
  final Widget child;

  const StellarMusicBackground({
    super.key,
    required this.child,
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
      duration: const Duration(
        seconds: 18,
      ),
    )..repeat();
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
        child: widget.child,
        builder: (
          context,
          child,
        ) {
          final t =
              _controller.value *
              math.pi *
              2;

          final x1 =
              math.sin(t) * 0.72;

          final y1 =
              math.cos(t * 0.83) * 0.72;

          final x2 =
              math.cos(t * 0.71) * 0.82;

          final y2 =
              math.sin(t * 0.91) * 0.82;

          final x3 =
              math.sin(t * 0.43) * 0.9;

          final y3 =
              math.cos(t * 0.57) * 0.9;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(x1, y1),
                end: Alignment(x2, y2),
                colors: const [
                  Color(0xFF030713),
                  Color(0xFF0C1D4B),
                  Color(0xFF24105B),
                  Color(0xFF561046),
                  Color(0xFF06182F),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Glow(
                  alignment: Alignment(
                    x1,
                    y1,
                  ),
                  radius: 0.52,
                  color: const Color(
                    0xFF087BFF,
                  ),
                  opacity: 0.24,
                ),
                _Glow(
                  alignment: Alignment(
                    x2,
                    y2,
                  ),
                  radius: 0.45,
                  color: const Color(
                    0xFFE02BFF,
                  ),
                  opacity: 0.20,
                ),
                _Glow(
                  alignment: Alignment(
                    x3,
                    y3,
                  ),
                  radius: 0.38,
                  color: const Color(
                    0xFF00C8FF,
                  ),
                  opacity: 0.14,
                ),
                _Glow(
                  alignment: Alignment(
                    -x2,
                    -y1,
                  ),
                  radius: 0.30,
                  color: const Color(
                    0xFF5DFFCB,
                  ),
                  opacity: 0.08,
                ),
                child!,
              ],
            ),
          );
        },
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
