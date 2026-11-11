import 'package:flutter_test/flutter_test.dart';
import 'package:stellarcenter/Linux/music/lrc_parser.dart';

void main() {
  group('StellarLrcParser', () {
    test('parses standard, comma-fraction and repeated timestamps', () {
      final document = StellarLrcParser.parseDocument('''
[ar:Test Artist]
[ti:Test Track]
[00:01.50]First line
[00:02,25]Second line
[00:03.00][00:04.00]Repeated line
''');

      expect(document.artist, 'Test Artist');
      expect(document.title, 'Test Track');
      expect(document.lines, hasLength(4));
      expect(document.lines[0].timestamp, const Duration(milliseconds: 1500));
      expect(document.lines[1].timestamp, const Duration(milliseconds: 2250));
      expect(document.lines[2].timestamp, const Duration(seconds: 3));
      expect(document.lines[3].timestamp, const Duration(seconds: 4));
    });

    test('finds the active lyric using playback position', () {
      final lines = StellarLrcParser.parse('''
[00:01.00]First
[00:02.00]Second
[00:03.00]Third
''');

      expect(
        StellarLrcParser.activeIndex(
          lines,
          const Duration(milliseconds: 2500),
        ),
        1,
      );
      expect(
        StellarLrcParser.activeIndex(
          lines,
          Duration.zero,
        ),
        -1,
      );
    });

    test('strips enhanced LRC word timestamps from displayed text', () {
      final lines = StellarLrcParser.parse(
        '[00:01.00]<00:01.00>Hello <00:01.40>world',
      );

      expect(lines, hasLength(1));
      expect(lines.single.text, 'Hello world');
    });
  });
}
