import 'dart:io';

import 'lrc_parser.dart';

class StellarLyricsLoader {
  static final Map<String, List<StellarLrcLine>> _cache =
      <String, List<StellarLrcLine>>{};

  static Future<List<StellarLrcLine>> load(
    String? path,
  ) async {
    if (path == null || path.trim().isEmpty) {
      return const [];
    }

    final cached = _cache[path];

    if (cached != null) {
      return cached;
    }

    try {
      final file = File(path);

      if (!await file.exists()) {
        return const [];
      }

      final content = await file.readAsString();

      final lines = StellarLrcParser.parse(content);

      _cache[path] = lines;

      return lines;
    } catch (_) {
      return const [];
    }
  }

  static void clear() {
    _cache.clear();
  }

  static void remove(String path) {
    _cache.remove(path);
  }
}
