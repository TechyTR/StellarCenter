import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'music_colors.dart';

class StellarMusicBackground extends StatefulWidget {
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

class _StellarMusicBackgroundState extends State<StellarMusicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<Color> _colors = StellarMusicColors.defaultColors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _loadColors();
  }

  @override
  void didUpdateWidget(covariant StellarMusicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameArtwork(oldWidget.artwork, widget.artwork)) {
      _loadColors();
    }
  }

  Future<void> _loadColors() async {
    final colors = await StellarMusicColors.fromArtworkAsync(widget.artwork);
    if (!mounted) return;
    setState(() => _colors = colors);
  }

  bool _sameArtwork(Uint8List? a, Uint8List? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
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
    // Keep the animated layer isolated. The player controls and lyrics must
    // not rebuild on every animation frame (important on low-power boards).
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + t * 2, -1),
                      end: Alignment(1, 1 - t * 2),
                      colors: _colors,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x99000000),
                ],
              ),
            ),
          ),
        ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
}
