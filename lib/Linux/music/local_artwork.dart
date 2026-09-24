import 'dart:io';
import 'dart:typed_data';

class StellarLocalArtwork {
  static Future<Uint8List?> find(
    String audioPath,
  ) async {
    final dot =
        audioPath.lastIndexOf('.');

    if (dot <= 0) {
      return null;
    }

    final base =
        audioPath.substring(0, dot);

    final directory =
        File(audioPath).parent;

    final audioName =
        audioPath
            .split(Platform.pathSeparator)
            .last
            .substring(
              0,
              audioPath
                  .split(Platform.pathSeparator)
                  .last
                  .lastIndexOf('.'),
            );

    final candidates = <String>[
      '$base.png',
      '$base.PNG',
      '$base.jpg',
      '$base.JPG',
      '$base.jpeg',
      '$base.JPEG',
      '${directory.path}/$audioName.png',
      '${directory.path}/$audioName.PNG',
      '${directory.path}/cover.png',
      '${directory.path}/cover.PNG',
      '${directory.path}/folder.png',
      '${directory.path}/folder.PNG',
      '${directory.path}/album.png',
      '${directory.path}/album.PNG',
    ];

    for (final path in candidates) {
      final file = File(path);

      if (!await file.exists()) {
        continue;
      }

      try {
        return await file.readAsBytes();
      } catch (_) {
        // Sonraki artwork adayına geç.
      }
    }

    return null;
  }
}
