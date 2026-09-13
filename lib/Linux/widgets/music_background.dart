import 'dart:math' as math;

import 'package:flutter/material.dart';

class MusicBackground extends StatefulWidget {
  final Widget child;

  const MusicBackground({
    super.key,
    required this.child,
  });

  @override
  State<MusicBackground> createState() =>
      _MusicBackgroundState();
}

class _MusicBackgroundState
    extends State<MusicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value *
            math.pi *
            2;

        final dx = math.sin(t) * 0.18;
        final dy = math.cos(t * 0.8) * 0.16;

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: scheme.surface,
            ),
            FractionalTranslation(
              translation:
                  Offset(dx, dy),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.sin(t) * 0.65,
                      math.cos(t) * 0.65,
                    ),
                    radius: 1.2,
                    colors: [
                      scheme.primary
                          .withValues(alpha: 0.16),
                      scheme.secondary
                          .withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            FractionalTranslation(
              translation: Offset(-dx, -dy),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.cos(t * 0.7) * 0.7,
                      math.sin(t * 0.6) * 0.7,
                    ),
                    radius: 1.1,
                    colors: [
                      scheme.tertiary
                          .withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
