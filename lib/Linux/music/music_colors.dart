import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicColors {
  static List<Color> fallback() {
    return const [
      Color(0xFF0066FF),
      Color(0xFF8A2BE2),
      Color(0xFFFF1493),
    ];
  }

  static List<Color> fromArtwork(
    Uint8List? artwork,
  ) {
    if (artwork == null ||
        artwork.isEmpty) {
      return fallback();
    }

    // İlk aşamada canlı ve güvenli bir palet.
    // Gerçek piksel analizi sonraki optimizasyon
    // aşamasında eklenecek.
    return const [
      Color(0xFF0066FF),
      Color(0xFF7B2CFF),
      Color(0xFFFF2D95),
      Color(0xFF00C6FF),
    ];
  }
}
