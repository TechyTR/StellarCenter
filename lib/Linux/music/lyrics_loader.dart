import 'dart:io';

import 'lrc_parser.dart';

class StellarLyricsLoader {
  StellarLyricsLoader._();

  static final Map<
      String,
      List<StellarLrcLine>> _cache =
      <String, List<StellarLrcLine>>{};

  static final Map<
      String,
      Future<List<StellarLrcLine>>> _pending =
      <String,
      Future<List<StellarLrcLine>>>{};

  static Future<List<StellarLrcLine>> load(
    String? path,
  ) {
    if (path == null ||
        path.trim().isEmpty) {
      return Future.value(
        const <StellarLrcLine>[],
      );
    }

    final normalized =
        path.trim();

    final cached =
        _cache[normalized];

    if (cached != null) {
      return Future.value(cached);
    }

    final existing =
        _pending[normalized];

    if (existing != null) {
      return existing;
    }

    final future =
        _loadInternal(normalized);

    _pending[normalized] = future;

    return future.whenComplete(
      () => _pending.remove(normalized),
    );
  }

  static Future<List<StellarLrcLine>>
      _loadInternal(
    String path,
  ) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        return const [];
      }

      final content =
          await file.readAsString();

      final lines =
          StellarLrcParser.parse(
        content,
      );

      final immutable =
          List<StellarLrcLine>.unmodifiable(
        lines,
      );

      _cache[path] = immutable;

      return immutable;
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
