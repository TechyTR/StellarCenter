class StellarLrcLine {
  final Duration timestamp;
  final String text;

  const StellarLrcLine({
    required this.timestamp,
    required this.text,
  });
}

class StellarLrcParser {
  static final RegExp _timestampPattern =
      RegExp(r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]');

  static List<StellarLrcLine> parse(String content) {
    final result = <StellarLrcLine>[];

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();

      if (line.isEmpty) continue;

      final matches =
          _timestampPattern.allMatches(line).toList();

      if (matches.isEmpty) continue;

      final text = line
          .replaceAll(_timestampPattern, '')
          .trim();

      if (text.isEmpty) continue;

      for (final match in matches) {
        final minutes =
            int.tryParse(match.group(1) ?? '') ?? 0;

        final seconds =
            int.tryParse(match.group(2) ?? '') ?? 0;

        final fraction =
            int.tryParse(match.group(3) ?? '0') ?? 0;

        final milliseconds =
            match.group(3) == null
                ? 0
                : match.group(3)!.length == 1
                    ? fraction * 100
                    : match.group(3)!.length == 2
                        ? fraction * 10
                        : fraction;

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

    return result;
  }

  static int activeIndex(
    List<StellarLrcLine> lines,
    Duration position,
  ) {
    if (lines.isEmpty) return -1;

    var index = -1;

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].timestamp <= position) {
        index = i;
      } else {
        break;
      }
    }

    return index;
  }
}
