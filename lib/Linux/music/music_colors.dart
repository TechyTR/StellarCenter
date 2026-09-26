import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class StellarMusicColors {
  StellarMusicColors._();

  static const List<Color> defaultColors = [
    Color(0xFF1769FF),
    Color(0xFF7B2CFF),
    Color(0xFFE91E63),
    Color(0xFF00AEEF),
  ];

  static final Map<int, List<Color>> _cache =
      <int, List<Color>>{};

  static List<Color> fromArtwork(
    Uint8List? artwork,
  ) {
    if (artwork == null ||
        artwork.isEmpty) {
      return defaultColors;
    }

    final key = Object.hash(
      artwork.length,
      artwork.first,
      artwork[artwork.length ~/ 2],
      artwork.last,
    );

    return _cache[key] ??
        defaultColors;
  }

  static Future<List<Color>>
      fromArtworkAsync(
    Uint8List? artwork,
  ) async {
    if (artwork == null ||
        artwork.isEmpty) {
      return defaultColors;
    }

    final key = Object.hash(
      artwork.length,
      artwork.first,
      artwork[artwork.length ~/ 2],
      artwork.last,
    );

    final cached = _cache[key];

    if (cached != null) {
      return cached;
    }

    try {
      final codec =
          await ui.instantiateImageCodec(
        artwork,
        targetWidth: 24,
        targetHeight: 24,
      );

      final frame =
          await codec.getNextFrame();

      final data =
          await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      frame.image.dispose();
      codec.dispose();

      if (data == null) {
        return defaultColors;
      }

      final bytes = data.buffer.asUint8List();
      final buckets =
          <String, _ColorBucket>{};

      for (var i = 0;
          i + 3 < bytes.length;
          i += 4) {
        final r = bytes[i];
        final g = bytes[i + 1];
        final b = bytes[i + 2];
        final a = bytes[i + 3];

        if (a < 80) continue;

        final max = [
          r,
          g,
          b,
        ].reduce((a, b) => a > b ? a : b);

        final min = [
          r,
          g,
          b,
        ].reduce((a, b) => a < b ? a : b);

        final brightness =
            (r + g + b) / 3;

        final saturation =
            max - min;

        if (brightness < 20 ||
            brightness > 245 ||
            saturation < 18) {
          continue;
        }

        final qr = (r ~/ 32) * 32;
        final qg = (g ~/ 32) * 32;
        final qb = (b ~/ 32) * 32;

        final bucket =
            buckets.putIfAbsent(
          '$qr:$qg:$qb',
          _ColorBucket.new,
        );

        bucket.r += r;
        bucket.g += g;
        bucket.b += b;
        bucket.count++;
      }

      final entries =
          buckets.values.toList()
            ..sort(
              (a, b) =>
                  b.count.compareTo(a.count),
            );

      final colors = <Color>[];

      for (final bucket in entries) {
        if (bucket.count == 0) continue;

        final color = Color.fromARGB(
          255,
          bucket.r ~/ bucket.count,
          bucket.g ~/ bucket.count,
          bucket.b ~/ bucket.count,
        );

        if (_isDistinct(
          colors,
          color,
        )) {
          colors.add(color);
        }

        if (colors.length >= 4) {
          break;
        }
      }

      final result = colors.length >= 2
          ? List<Color>.unmodifiable(colors)
          : defaultColors;

      _cache[key] = result;

      return result;
    } catch (_) {
      return defaultColors;
    }
  }

  static bool _isDistinct(
    List<Color> colors,
    Color color,
  ) {
    for (final existing in colors) {
      final distance =
          (color.red - existing.red).abs() +
          (color.green - existing.green).abs() +
          (color.blue - existing.blue).abs();

      if (distance < 90) {
        return false;
      }
    }

    return true;
  }

  static LinearGradient gradient(
    Uint8List? artwork,
  ) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: fromArtwork(artwork),
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
    final colors =
        fromArtwork(artwork);

    return colors.length > 1
        ? colors[1]
        : colors.first;
  }

  static void clearCache() {
    _cache.clear();
  }
}

class _ColorBucket {
  int r = 0;
  int g = 0;
  int b = 0;
  int count = 0;
}
