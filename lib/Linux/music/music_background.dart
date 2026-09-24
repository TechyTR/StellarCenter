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
      duration: const Duration(
        seconds: 14,
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
                    math.sin(t) * 0.8,
                    math.cos(t) * 0.8,
                  ),
                  end: Alignment(
                    math.cos(t) * 0.8,
                    math.sin(t) * 0.8,
                  ),
                  colors: widget.colors,
                ),
              ),
            ),

            Positioned(
              left: -120 + math.sin(t) * 140,
              top: -100 + math.cos(t) * 100,
              child: _orb(
                widget.colors[0],
                360,
              ),
            ),

            Positioned(
              right: -140 + math.cos(t) * 180,
              bottom: -120 + math.sin(t) * 140,
              child: _orb(
                widget.colors[
                    widget.colors.length > 1
                        ? 1
                        : 0
                ],
                420,
              ),
            ),

            Positioned(
              left: 120 + math.cos(t * 1.4) * 180,
              bottom: 40 + math.sin(t * 1.2) * 160,
              child: _orb(
                widget.colors[
                    widget.colors.length > 2
                        ? 2
                        : 0
                ],
                260,
              ),
            ),

            Container(
              color: Colors.black.withOpacity(
                0.28,
              ),
            ),

            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  Widget _orb(
    Color color,
    double size,
  ) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.65),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 100,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }
}
