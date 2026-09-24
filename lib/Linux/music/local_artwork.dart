import 'dart:io';
import 'dart:typed_data';

class StellarLocalArtwork {
  static Future<Uint8List?> find(String audioPath) async {
    final audioFile = File(audioPath);
    final directory = audioFile.parent;

    final baseName = audioFile.uri.pathSegments.last;
    final dotIndex = baseName.lastIndexOf('.');

    final nameWithoutExtension =
        dotIndex > 0 ? baseName.substring(0, dotIndex) : baseName;

    final candidates = <String>[
      '$nameWithoutExtension.png',
      '$nameWithoutExtension.jpg',
      '$nameWithoutExtension.jpeg',
      'cover.png',
      'cover.jpg',
      'cover.jpeg',
      'folder.png',
      'folder.jpg',
      'folder.jpeg',
      'album.png',
      'album.jpg',
      'album.jpeg',
    ];

    for (final name in candidates) {
      try {
        final file = File('${directory.path}/$name');

        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          if (bytes.isNotEmpty) {
            return bytes;
          }
        }
      } catch (_) {
        // Bir kapak okunamazsa diğer adaylara devam et.
      }
    }

    return null;
  }
}
