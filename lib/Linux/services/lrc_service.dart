class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });
}

class LrcService {
  const LrcService._();

  static List<LyricLine> parse(String content) {
    final lines = <LyricLine>[];

    final regex = RegExp(
      r'\[(\d{1,3}):(\d{2})(?:\.(\d{1,3}))?\](.*)',
    );

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();

      if (line.isEmpty) continue;

      final match = regex.firstMatch(line);

      if (match == null) continue;

      final minutes =
          int.tryParse(match.group(1) ?? '');

      final seconds =
          int.tryParse(match.group(2) ?? '');

      final fraction =
          match.group(3) ?? '0';

      if (minutes == null ||
          seconds == null ||
          seconds > 59) {
        continue;
      }

      int milliseconds;

      if (fraction.length == 1) {
        milliseconds =
            int.parse(fraction) * 100;
      } else if (fraction.length == 2) {
        milliseconds =
            int.parse(fraction) * 10;
      } else {
        milliseconds =
            int.parse(fraction.substring(0, 3));
      }

      lines.add(
        LyricLine(
          timestamp: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds,
          ),
          text: match.group(4)?.trim() ?? '',
        ),
      );
    }

    lines.sort(
      (a, b) =>
          a.timestamp.compareTo(b.timestamp),
    );

    return lines;
  }

  static int currentIndex(
    List<LyricLine> lines,
    Duration position, {
    Duration offset = Duration.zero,
  }) {
    if (lines.isEmpty) return -1;

    final adjusted =
        position + offset;

    var index = -1;

    for (var i = 0; i < lines.length; i++) {
      if (adjusted >= lines[i].timestamp) {
        index = i;
      } else {
        break;
      }
    }

    return index;
  }
}
