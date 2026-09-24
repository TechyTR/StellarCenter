import 'dart:io';

import 'music_metadata.dart';
import 'music_track.dart';

class StellarMusicScanner {
  final String musicDirectory;

  const StellarMusicScanner({
    required this.musicDirectory,
  });

  Future<List<StellarMusicTrack>> scan() async {
    final directory =
        Directory(musicDirectory);

    if (!await directory.exists()) {
      await directory.create(
        recursive: true,
      );
    }

    final tracks =
        <StellarMusicTrack>[];

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      final path =
          entity.path;

      if (!path.toLowerCase().endsWith('.mp3')) {
        continue;
      }

      final file =
          File(path);

      final baseName =
          path.split(
            Platform.pathSeparator,
          ).last;

      final nameWithoutExtension =
          baseName.replaceFirst(
        RegExp(
          r'\.mp3$',
          caseSensitive: false,
        ),
        '',
      );

      final parent =
          file.parent.path;

      final lrc =
          File(
            '$parent/$nameWithoutExtension.lrc',
          );

      final metadata =
          StellarMusicMetadataReader.read(
        file,
      );

      final fallbackArtist =
          file.parent.path
              .split(
                Platform.pathSeparator,
              )
              .last;

      final title =
          metadata.title ??
          nameWithoutExtension;

      final artist =
          metadata.artist ??
          fallbackArtist;

      final album =
          metadata.album ??
          'Bilinmeyen Albüm';

      tracks.add(
        StellarMusicTrack(
          path: file.path,
          title: title,
          artist: artist,
          album: album,
          artwork: metadata.artwork,
          lyricsPath:
              await lrc.exists()
                  ? lrc.path
                  : null,

          // Çok önemli:
          // Kapak/LRC olması doğrulanmış sanatçı
          // anlamına GELMEZ.
          verifiedArtist: false,
        ),
      );
    }

    tracks.sort(
      (a, b) => a.title
          .toLowerCase()
          .compareTo(
            b.title.toLowerCase(),
          ),
    );

    return tracks;
  }
}
