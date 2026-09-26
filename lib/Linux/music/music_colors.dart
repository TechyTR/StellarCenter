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

  static Future<List<Color>> fromArtworkAsync(
    Uint8List? artwork,
  ) async {
    if (artwork == null || artwork.isEmpty) {
      return defaultColors;
    }

    final cacheKey = Object.hash(
      artwork.length,
      artwork.fold<int>(
        0,
        (value, byte) => (value * 31 + byte) & 0x7fffffff,
      ),
    );

    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    try {
      final codec = await ui.instantiateImageCodec(
        artwork,
        targetWidth: 24,
        targetHeight: 24,
        allowUpscaling: false,
      );

      final frame = await codec.getNextFrame();
      final image = frame.image;

      final data = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      image.dispose();
      codec.dispose();

      if (data == null) {
        return defaultColors;
      }

      final bytes = data.buffer.asUint8List();

      final colors = _extractPalette(
        bytes,
      );

      _cache[cacheKey] = colors;
      return colors;
    } catch (_) {
      return defaultColors;
    }
  }

  static List<Color> _extractPalette(
    Uint8List bytes,
  ) {
    final buckets = <int, _ColorBucket>{};

    for (var i = 0; i + 3 < bytes.length; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      final a = bytes[i + 3];

      if (a < 150) {
        continue;
      }

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

      final brightness = (r + g + b) / 3;

      if (max - min < 18 ||
          brightness < 22 ||
          brightness > 245) {
        continue;
      }

      final qr = (r ~/ 32).clamp(0, 7);
      final qg = (g ~/ 32).clamp(0, 7);
      final qb = (b ~/ 32).clamp(0, 7);

      final key =
          (qr << 6) | (qg << 3) | qb;

      final bucket = buckets.putIfAbsent(
        key,
        () => _ColorBucket(),
      );

      bucket.r += r;
      bucket.g += g;
      bucket.b += b;
      bucket.count++;
    }

    if (buckets.isEmpty) {
      return defaultColors;
    }

    final sorted = buckets.values.toList()
      ..sort(
        (a, b) => b.count.compareTo(a.count),
      );

    final result = <Color>[];

    for (final bucket in sorted) {
      final color = Color.fromARGB(
        255,
        (bucket.r / bucket.count).round(),
        (bucket.g / bucket.count).round(),
        (bucket.b / bucket.count).round(),
      );

      if (_isDistinct(
        color,
        result,
      )) {
        result.add(color);
      }

      if (result.length == 4) {
        break;
      }
    }

    if (result.isEmpty) {
      return defaultColors;
    }

    while (result.length < 3) {
      result.add(
        defaultColors[
            result.length % defaultColors.length],
      );
    }

    return result;
  }

  static bool _isDistinct(
    Color color,
    List<Color> colors,
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
    final colors = fromArtwork(artwork);

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
