import 'dart:io';
import 'dart:typed_data';

class StellarLocalArtwork {
  StellarLocalArtwork._();

  static Future<Uint8List?> find(
    String audioPath,
  ) async {
    final audioFile = File(audioPath);
    final directory = audioFile.parent;

    final dot =
        audioPath.lastIndexOf('.');

    final base = dot > 0
        ? audioPath.substring(0, dot)
        : audioPath;

    final candidates = <String>[
      '$base.jpg',
      '$base.jpeg',
      '$base.png',
      '$base.webp',

      '${directory.path}/cover.jpg',
      '${directory.path}/cover.jpeg',
      '${directory.path}/cover.png',
      '${directory.path}/cover.webp',

      '${directory.path}/Cover.jpg',
      '${directory.path}/Cover.png',

      '${directory.path}/folder.jpg',
      '${directory.path}/folder.png',

      '${directory.path}/album.jpg',
      '${directory.path}/album.png',

      '${directory.path}/front.jpg',
      '${directory.path}/front.png',
    ];

    final seen = <String>{};

    for (final path in candidates) {
      if (!seen.add(path)) {
        continue;
      }

      final file = File(path);

      try {
        if (!await file.exists()) {
          continue;
        }

        final bytes =
            await file.readAsBytes();

        if (bytes.isEmpty) {
          continue;
        }

        return bytes;
      } catch (_) {
        continue;
      }
    }

    return null;
  }
}
