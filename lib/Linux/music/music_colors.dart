import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicColors {
  static const List<Color> defaultColors = [
    Color(0xFF1769FF),
    Color(0xFF7B2CFF),
    Color(0xFFE91E63),
  ];

  static List<Color> fromArtwork(
    Uint8List? artwork,
  ) {
    if (artwork == null ||
        artwork.isEmpty) {
      return defaultColors;
    }

    /*
     * Burada ağır image processing yapmıyoruz.
     * Müzik oynarken her frame'de artwork
     * taramak ciddi gereksiz yük oluşturur.
     *
     * Gerçek palette extraction daha sonra
     * yalnızca track değiştiğinde yapılabilir.
     */

    return const [
      Color(0xFF1769FF),
      Color(0xFF7B2CFF),
      Color(0xFFE91E63),
      Color(0xFF00AEEF),
    ];
  }

  static LinearGradient gradient(
    Uint8List? artwork,
  ) {
    final colors = fromArtwork(artwork);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}
