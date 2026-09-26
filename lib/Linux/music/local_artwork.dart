import 'dart:io';
import 'dart:typed_data';

class StellarLocalArtwork {
  static Future<Uint8List?> find(
    String audioPath,
  ) async {
    final dot = audioPath.lastIndexOf('.');

    final base = dot > 0
        ? audioPath.substring(0, dot)
        : audioPath;

    final directory =
        File(audioPath).parent.path;

    final candidates = <String>[
      '$base.jpg',
      '$base.jpeg',
      '$base.png',

      '$directory/cover.jpg',
      '$directory/cover.jpeg',
      '$directory/cover.png',

      '$directory/folder.jpg',
      '$directory/folder.png',

      '$directory/album.jpg',
      '$directory/album.png',
    ];

    for (final path in candidates) {
      final file = File(path);

      if (!await file.exists()) {
        continue;
      }

      try {
        return await file.readAsBytes();
      } catch (_) {
        // Bir artwork okunamazsa diğerlerini dene.
      }
    }

    return null;
  }
}
