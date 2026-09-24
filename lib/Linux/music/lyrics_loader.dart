import 'dart:io';

import 'lrc_parser.dart';

class StellarLyricsLoader {
  static Future<List<StellarLrcLine>> load(
    String? path,
  ) async {
    if (path == null || path.isEmpty) {
      return const [];
    }

    try {
      final file = File(path);

      if (!await file.exists()) {
        return const [];
      }

      final content = await file.readAsString();

      return StellarLrcParser.parse(content);
    } catch (_) {
      return const [];
    }
  }
}
