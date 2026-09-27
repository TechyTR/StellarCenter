class StellarLrcLine {
  final Duration timestamp;
  final String text;

  const StellarLrcLine({
    required this.timestamp,
    required this.text,
  });
}

class StellarLrcParser {
  /*
   * Desteklenen örnekler:
   *
   * [00:12.34]Söz
   * [00:12:34]Söz
   * [0:12.3]Söz
   * [01:02]Söz
   *
   * Aynı satırda birden fazla timestamp da
   * desteklenir:
   *
   * [00:12.00][00:15.50]Söz
   */
  static final RegExp _timestampPattern = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );

  /*
   * LRC metadata/tag satırları.
   *
   * [ar:Artist]
   * [al:Album]
   * [ti:Title]
   * [by:Creator]
   * [re:...]
   * [ve:...]
   * [offset:...]
   *
   * Ayrıca bazı dosyalarda bracketsız:
   *
   * ar:Artist
   * al:Album
   * ti:Title
   */
  static final RegExp _metadataTagPattern =
      RegExp(
    r'^\s*\[(ar|al|ti|by|re|ve|offset|length|'
    r'language|la|au|artist|album|title)\s*:',
    caseSensitive: false,
  );

  static final RegExp _plainMetadataTagPattern =
      RegExp(
    r'^\s*(ar|al|ti|by|re|ve|offset|length|'
    r'language|la|au|artist|album|title)\s*:',
    caseSensitive: false,
  );

  static List<StellarLrcLine> parse(
    String content,
  ) {
    final result = <StellarLrcLine>[];

    /*
     * BOM temizle.
     */
    var normalizedContent =
        content.replaceFirst('\uFEFF', '');

    /*
     * CRLF / CR -> LF
     */
    normalizedContent =
        normalizedContent.replaceAll(
      '\r\n',
      '\n',
    );

    normalizedContent =
        normalizedContent.replaceAll(
      '\r',
      '\n',
    );

    for (final rawLine
        in normalizedContent.split('\n')) {
      var line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      /*
       * LRC metadata satırlarını atla.
       */
      if (_metadataTagPattern.hasMatch(line) ||
          _plainMetadataTagPattern.hasMatch(
            line,
          )) {
        continue;
      }

      final matches =
          _timestampPattern
              .allMatches(line)
              .toList();

      /*
       * Timestamp yoksa bu bir normal metadata
       * veya anlamsız satırdır.
       */
      if (matches.isEmpty) {
        continue;
      }

      /*
       * Timestamp'leri metinden çıkar.
       */
      line = line
          .replaceAll(
            _timestampPattern,
            '',
          )
          .trim();

      /*
       * Bazı LRC dosyalarında timestamp'ten sonra
       * metadata kalıntısı bulunabiliyor.
       */
      if (line.isEmpty) {
        continue;
      }

      if (_metadataTagPattern.hasMatch(line) ||
          _plainMetadataTagPattern.hasMatch(
            line,
          )) {
        continue;
      }

      for (final match in matches) {
        final minutes =
            int.tryParse(
                  match.group(1) ?? '',
                ) ??
                0;

        final seconds =
            int.tryParse(
                  match.group(2) ?? '',
                ) ??
                0;

        final milliseconds =
            _fractionToMilliseconds(
          match.group(3),
        );

        result.add(
          StellarLrcLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds:
                  milliseconds,
            ),
            text: line,
          ),
        );
      }
    }

    result.sort(
      (a, b) => a.timestamp.compareTo(
        b.timestamp,
      ),
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

      if (lines[middle].timestamp <=
          position) {
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

    if (next < 0 ||
        next >= lines.length) {
      return null;
    }

    return lines[next].timestamp;
  }

  static int _fractionToMilliseconds(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 0;
    }

    /*
     * .1  -> 100 ms
     * .12 -> 120 ms
     * .123 -> 123 ms
     * .1234 -> 123 ms
     */
    final normalized =
        value.padRight(3, '0');

    final limited =
        normalized.substring(
      0,
      normalized.length > 3
          ? 3
          : normalized.length,
    );

    return int.tryParse(limited) ?? 0;
  }
}
