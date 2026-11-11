class StellarLrcLine {
  final Duration timestamp;
  final String text;

  const StellarLrcLine({
    required this.timestamp,
    required this.text,
  });
}

class StellarLrcDocument {
  final String? artist;
  final String? album;
  final String? title;
  final List<StellarLrcLine> lines;

  const StellarLrcDocument({
    this.artist,
    this.album,
    this.title,
    required this.lines,
  });
}

class StellarLrcParser {
  // Accept common LRC variants: [01:23.45], [01:23,45], [01:23:45].
  static final RegExp _timestampPattern = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.,:](\d{1,4}))?\]',
  );

  static final RegExp _wordTimestampPattern = RegExp(
    r'<\d{1,3}:\d{2}(?:[.,:]\d{1,4})?>',
  );

  static final RegExp _metadataPattern = RegExp(
    r'^\s*\[\s*(ar|al|ti|by|re|ve|offset|length|language|la|au|artist|album|title)\s*:\s*(.*?)\s*\]\s*$',
    caseSensitive: false,
  );

  static final RegExp _plainMetadataPattern = RegExp(
    r'^\s*(ar|al|ti|by|re|ve|offset|length|language|la|au|artist|album|title)\s*:\s*(.*?)\s*$',
    caseSensitive: false,
  );

  static StellarLrcDocument parseDocument(String content) {
    final result = <StellarLrcLine>[];
    String? artist;
    String? album;
    String? title;

    final normalized = content
        .replaceFirst('\uFEFF', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    for (final rawLine in normalized.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final metadata = _metadataPattern.firstMatch(line);
      if (metadata != null) {
        final key = (metadata.group(1) ?? '').trim().toLowerCase();
        final value = _cleanValue(metadata.group(2));
        if (value != null) {
          if (key == 'ar' || key == 'artist') {
            artist = value;
          } else if (key == 'al' || key == 'album') {
            album = value;
          } else if (key == 'ti' || key == 'title') {
            title = value;
          }
        }
        continue;
      }

      final plainMetadata = _plainMetadataPattern.firstMatch(line);
      if (plainMetadata != null) {
        final key = (plainMetadata.group(1) ?? '').trim().toLowerCase();
        final value = _cleanValue(plainMetadata.group(2));
        if (value != null) {
          if (key == 'ar' || key == 'artist') {
            artist = value;
          } else if (key == 'al' || key == 'album') {
            album = value;
          } else if (key == 'ti' || key == 'title') {
            title = value;
          }
        }
        continue;
      }

      final matches = _timestampPattern.allMatches(line).toList();
      if (matches.isEmpty) continue;

      final lyricText = line
          .replaceAll(_timestampPattern, '')
          .replaceAll(_wordTimestampPattern, '')
          .trim();
      if (lyricText.isEmpty) continue;

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '') ?? 0;
        if (seconds > 59) continue;

        final milliseconds = _fractionToMilliseconds(match.group(3));
        result.add(
          StellarLrcLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            text: lyricText,
          ),
        );
      }
    }

    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return StellarLrcDocument(
      artist: artist,
      album: album,
      title: title,
      lines: List.unmodifiable(result),
    );
  }

  static List<StellarLrcLine> parse(String content) =>
      parseDocument(content).lines;

  static int activeIndex(
    List<StellarLrcLine> lines,
    Duration position,
  ) {
    if (lines.isEmpty) return -1;

    var low = 0;
    var high = lines.length - 1;
    var result = -1;

    while (low <= high) {
      final middle = low + ((high - low) ~/ 2);
      if (lines[middle].timestamp <= position) {
        result = middle;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return result;
  }

  static Duration? nextTimestamp(
    List<StellarLrcLine> lines,
    int index,
  ) {
    final next = index + 1;
    if (next < 0 || next >= lines.length) return null;
    return lines[next].timestamp;
  }

  static int _fractionToMilliseconds(String? value) {
    if (value == null || value.isEmpty) return 0;
    final normalized = value.padRight(3, '0');
    final limited = normalized.substring(
      0,
      normalized.length > 3 ? 3 : normalized.length,
    );
    return int.tryParse(limited) ?? 0;
  }

  static String? _cleanValue(String? value) {
    if (value == null) return null;
    final cleaned = value
        .replaceAll('\u0000', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? null : cleaned;
  }
}
