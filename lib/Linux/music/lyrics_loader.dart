import 'dart:convert';
import 'dart:io';

import 'lrc_parser.dart';

class StellarLyricsLoader {
  StellarLyricsLoader._();

  static final Map<String, StellarLrcDocument> _documentCache = {};
  static final Map<String, Future<StellarLrcDocument>> _pending = {};

  static Future<StellarLrcDocument> loadDocument(String? path) {
    if (path == null || path.trim().isEmpty) {
      return Future.value(
        const StellarLrcDocument(lines: <StellarLrcLine>[]),
      );
    }

    final normalized = path.trim();
    final cached = _documentCache[normalized];
    if (cached != null) return Future.value(cached);

    final existing = _pending[normalized];
    if (existing != null) return existing;

    final future = _loadInternal(normalized);
    _pending[normalized] = future;
    return future.whenComplete(() => _pending.remove(normalized));
  }

  static Future<List<StellarLrcLine>> load(String? path) async {
    return (await loadDocument(path)).lines;
  }

  static Future<StellarLrcDocument> _loadInternal(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return const StellarLrcDocument(lines: <StellarLrcLine>[]);
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return const StellarLrcDocument(lines: <StellarLrcLine>[]);
      }

      final content = _decodeText(bytes);
      if (content.trim().isEmpty) {
        return const StellarLrcDocument(lines: <StellarLrcLine>[]);
      }

      final parsed = StellarLrcParser.parseDocument(content);
      final document = StellarLrcDocument(
        artist: parsed.artist,
        album: parsed.album,
        title: parsed.title,
        lines: List.unmodifiable(parsed.lines),
      );

      _documentCache[path] = document;
      return document;
    } catch (_) {
      return const StellarLrcDocument(lines: <StellarLrcLine>[]);
    }
  }

  static String _decodeText(List<int> bytes) {
    if (_startsWith(bytes, const [0xEF, 0xBB, 0xBF])) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }
    if (_startsWith(bytes, const [0xFF, 0xFE])) {
      return _decodeUtf16(bytes.sublist(2), littleEndian: true);
    }
    if (_startsWith(bytes, const [0xFE, 0xFF])) {
      return _decodeUtf16(bytes.sublist(2), littleEndian: false);
    }

    // Prefer valid UTF-8; older Turkish-tagged LRC files often use ISO-8859-9.
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes)
          .replaceAll('Ð', 'Ğ')
          .replaceAll('Ý', 'İ')
          .replaceAll('Þ', 'Ş')
          .replaceAll('ð', 'ğ')
          .replaceAll('ý', 'ı')
          .replaceAll('þ', 'ş');
    }
  }

  static bool _startsWith(List<int> bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }

  static String _decodeUtf16(
    List<int> bytes, {
    required bool littleEndian,
  }) {
    final units = <int>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final first = bytes[i];
      final second = bytes[i + 1];
      units.add(
        littleEndian ? first | (second << 8) : (first << 8) | second,
      );
    }
    return String.fromCharCodes(units);
  }

  static void clear() => _documentCache.clear();

  static void remove(String path) => _documentCache.remove(path);

  static void removeAll(Iterable<String> paths) {
    for (final path in paths) {
      _documentCache.remove(path);
    }
  }
}
