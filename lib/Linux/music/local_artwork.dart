import 'dart:io';
import 'dart:typed_data';

class StellarLocalArtwork {
  StellarLocalArtwork._();

  static Future<Uint8List?> find(
    String audioPath,
  ) async {
    final audioFile = File(audioPath);
    final directory = audioFile.parent;

    final audioName =
        audioFile.uri.pathSegments.isNotEmpty
            ? audioFile.uri.pathSegments.last
            : audioFile.path.split(Platform.pathSeparator).last;

    final audioBaseName = _withoutExtension(audioName);

    /*
     * Önce aynı isimli kapakları doğrudan dene.
     *
     * Örnek:
     *
     * şarkı.mp3
     * şarkı.jpg
     */
    final candidates = <String>[
      '${directory.path}/$audioBaseName.jpg',
      '${directory.path}/$audioBaseName.jpeg',
      '${directory.path}/$audioBaseName.png',
      '${directory.path}/$audioBaseName.webp',

      '${directory.path}/cover.jpg',
      '${directory.path}/cover.jpeg',
      '${directory.path}/cover.png',
      '${directory.path}/cover.webp',

      '${directory.path}/folder.jpg',
      '${directory.path}/folder.jpeg',
      '${directory.path}/folder.png',
      '${directory.path}/folder.webp',

      '${directory.path}/album.jpg',
      '${directory.path}/album.jpeg',
      '${directory.path}/album.png',
      '${directory.path}/album.webp',

      '${directory.path}/front.jpg',
      '${directory.path}/front.jpeg',
      '${directory.path}/front.png',
      '${directory.path}/front.webp',
    ];

    final seen = <String>{};

    for (final path in candidates) {
      if (!seen.add(path.toLowerCase())) {
        continue;
      }

      final file = File(path);

      try {
        if (!await file.exists()) {
          continue;
        }

        final bytes = await file.readAsBytes();

        if (bytes.isEmpty) {
          continue;
        }

        return bytes;
      } catch (_) {
        continue;
      }
    }

    /*
     * Linux dosya sistemi büyük/küçük harfe
     * duyarlı olabileceği için klasörü de tara.
     *
     * Böylece:
     *
     * Şarkı.mp3
     * şarkı.JPG
     *
     * gibi durumlar da çalışır.
     */
    try {
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        final name =
            entity.uri.pathSegments.isNotEmpty
                ? entity.uri.pathSegments.last
                : entity.path
                    .split(Platform.pathSeparator)
                    .last;

        final lowerName = name.toLowerCase();

        final isImage =
            lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.webp');

        if (!isImage) {
          continue;
        }

        final imageBaseName =
            _withoutExtension(name);

        if (imageBaseName.toLowerCase() !=
            audioBaseName.toLowerCase()) {
          continue;
        }

        try {
          final bytes = await entity.readAsBytes();

          if (bytes.isNotEmpty) {
            return bytes;
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      // Klasör okunamazsa kapak bulunamadı.
    }

    /*
     * Son çare: klasördeki herhangi bir
     * uygun resim dosyasını kapak olarak kullan.
     */
    try {
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        final name =
            entity.uri.pathSegments.isNotEmpty
                ? entity.uri.pathSegments.last
                : entity.path
                    .split(Platform.pathSeparator)
                    .last;

        final lowerName = name.toLowerCase();

        final isImage =
            lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.webp');

        if (!isImage) {
          continue;
        }

        try {
          final bytes = await entity.readAsBytes();

          if (bytes.isNotEmpty) {
            return bytes;
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}

    return null;
  }

  static String _withoutExtension(
    String fileName,
  ) {
    final dot = fileName.lastIndexOf('.');

    if (dot <= 0) {
      return fileName;
    }

    return fileName.substring(0, dot);
  }
}
