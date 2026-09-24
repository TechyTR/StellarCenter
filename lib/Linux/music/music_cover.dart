import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicCover extends StatelessWidget {
  final Uint8List? artwork;
  final double size;
  final double radius;

  const StellarMusicCover({
    super.key,
    required this.artwork,
    this.size = 300,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final image = artwork;

    if (image == null || image.isEmpty) {
      return _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.memory(
          image,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return _fallback();
          },
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1769FF),
            Color(0xFF6424A8),
            Color(0xFFB5179E),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size * .25,
        color: Colors.white.withValues(alpha: .9),
      ),
    );
  }
}
