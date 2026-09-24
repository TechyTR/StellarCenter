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
      duration:
          const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle =
            _controller.value *
            math.pi *
            2;

        final begin = Alignment(
          math.sin(angle) * 0.7,
          math.cos(angle * 0.8) * 0.7,
        );

        final end = Alignment(
          math.cos(angle * 0.7) * 0.7,
          math.sin(angle) * 0.7,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: const [
                Color(0xFF081B4B),
                Color(0xFF24105C),
                Color(0xFF4B0E52),
                Color(0xFF071B35),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
