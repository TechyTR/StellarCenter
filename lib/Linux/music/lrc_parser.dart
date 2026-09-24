import 'dart:io';

class StellarLyricLine {
  final Duration timestamp;
  final String text;

  const StellarLyricLine({
    required this.timestamp,
    required this.text,
  });
}

class StellarLrcParser {
  static final RegExp _timestampRegex = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );

  static Future<List<StellarLyricLine>> parseFile(
    File file,
  ) async {
    if (!await file.exists()) {
      return const [];
    }

    String content;

    try {
      content = await file.readAsString();
    } catch (_) {
      return const [];
    }

    return parse(content);
  }

  static List<StellarLyricLine> parse(
    String content,
  ) {
    final result = <StellarLyricLine>[];

    final lines = content.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      final matches =
          _timestampRegex.allMatches(rawLine).toList();

      if (matches.isEmpty) {
        continue;
      }

      final text = rawLine
          .replaceAll(_timestampRegex, '')
          .trim();

      for (final match in matches) {
        final minutes =
            int.tryParse(match.group(1) ?? '') ?? 0;

        final seconds =
            int.tryParse(match.group(2) ?? '') ?? 0;

        final fractionText =
            match.group(3);

        int milliseconds = 0;

        if (fractionText != null) {
          if (fractionText.length == 1) {
            milliseconds =
                int.parse(fractionText) * 100;
          } else if (fractionText.length == 2) {
            milliseconds =
                int.parse(fractionText) * 10;
          } else {
            milliseconds =
                int.parse(
                  fractionText.substring(0, 3),
                );
          }
        }

        result.add(
          StellarLyricLine(
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
      (a, b) =>
          a.timestamp.compareTo(b.timestamp),
    );

    return result;
  }

  static int activeIndex(
    List<StellarLyricLine> lines,
    Duration position,
  ) {
    if (lines.isEmpty) {
      return -1;
    }

    int index = -1;

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
