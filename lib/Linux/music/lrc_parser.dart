class StellarLrcLine {
  final Duration timestamp;
  final String text;

  const StellarLrcLine({
    required this.timestamp,
    required this.text,
  });
}

class StellarLrcParser {
  static final RegExp _timestampPattern = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );

  static List<StellarLrcLine> parse(
    String content,
  ) {
    final result = <StellarLrcLine>[];

    for (final rawLine in content.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      final matches =
          _timestampPattern.allMatches(line).toList();

      if (matches.isEmpty) {
        continue;
      }

      final text = line
          .replaceAll(_timestampPattern, '')
          .trim();

      if (text.isEmpty) {
        continue;
      }

      for (final match in matches) {
        final minutes =
            int.tryParse(match.group(1) ?? '') ?? 0;

        final seconds =
            int.tryParse(match.group(2) ?? '') ?? 0;

        final milliseconds =
            _fractionToMilliseconds(
          match.group(3),
        );

        result.add(
          StellarLrcLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            text: text,
          ),
        );
      }
    }

    result.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );

    return List.unmodifiable(result);
  }

  static int activeIndex(
    List<StellarLrcLine> lines,
    Duration position,
  ) {
    if (lines.isEmpty) {
      return -1;
    }

    var low = 0;
    var high = lines.length - 1;
    var result = -1;

    while (low <= high) {
      final middle =
          low + ((high - low) ~/ 2);

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

    if (next < 0 || next >= lines.length) {
      return null;
    }

    return lines[next].timestamp;
  }

  static int _fractionToMilliseconds(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 0;
    }

    final normalized = value.padRight(3, '0');

    final limited = normalized.substring(
      0,
      normalized.length > 3
          ? 3
          : normalized.length,
    );

    return int.tryParse(limited) ?? 0;
  }
}
