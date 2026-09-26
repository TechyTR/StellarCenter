import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicCover
    extends StatelessWidget {
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

    final cacheSize =
        (size * MediaQuery.devicePixelRatioOf(
          context,
        ))
            .round()
            .clamp(64, 900);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(.35),
              blurRadius: 28,
              offset:
                  const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(radius),
          child: Image.memory(
            image,
            width: size,
            height: size,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality:
                size >= 250
                    ? FilterQuality.medium
                    : FilterQuality.low,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _fallback();
            },
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(radius),
        gradient:
            const LinearGradient(
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
        color: Colors.white,
      ),
    );
  }
}
