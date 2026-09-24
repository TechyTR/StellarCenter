import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicCover extends StatelessWidget {
  final Uint8List? artwork;
  final double size;
  final double radius;

  const StellarMusicCover({
    super.key,
    required this.artwork,
    this.size = 240,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (artwork == null ||
        artwork!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0066FF),
              Color(0xFF8A2BE2),
              Color(0xFFFF1493),
            ],
          ),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          size: 72,
          color: Colors.white,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(radius),
      child: Image.memory(
        artwork!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
