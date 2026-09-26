import 'dart:typed_data';

import 'package:flutter/material.dart';

class StellarMusicColors {
  StellarMusicColors._();

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

  static Color primary(
    Uint8List? artwork,
  ) {
    return fromArtwork(artwork).first;
  }

  static Color secondary(
    Uint8List? artwork,
  ) {
    final colors = fromArtwork(artwork);

    if (colors.length < 2) {
      return colors.first;
    }

    return colors[1];
  }
}
