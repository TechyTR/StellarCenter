import 'dart:io';

import 'music_metadata.dart';
import 'music_track.dart';
import 'stellar_artist_verification.dart';
import 'stellar_local_artwork.dart';

class StellarMusicScanner {
  static Future<List<StellarMusicTrack>> scan() async {
    final home = Platform.environment['HOME'];

    if (home == null || home.isEmpty) {
      return const [];
    }

    final musicDirectory = Directory(
      '$home/StellarCenter/Music',
    );

    if (!await musicDirectory.exists()) {
      return const [];
    }

    final files = <File>[];

    await for (final entity in musicDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final extension = entity.path.split('.').last.toLowerCase();

      if (extension == 'mp3') {
        files.add(entity);
      }
    }

    final tracks = <StellarMusicTrack>[];

    for (final file in files) {
      try {
        final metadata = StellarMusicMetadataReader.read(file);

        final fileName = _fileNameWithoutExtension(file.path);

        final title =
            metadata.title ??
            fileName;

        final artist =
            metadata.artist ??
            _parentName(file.path);

        final album =
            metadata.album ??
            'Bilinmeyen Albüm';

        final lrcPath = _findLyricsPath(file.path);

        Uint8List? artwork = metadata.artwork;

        if (artwork == null) {
          artwork = await StellarLocalArtwork.find(file.path);
        }

        final verifiedArtist =
            StellarArtistVerification.instance.isVerified(
          artist,
        );

        tracks.add(
          StellarMusicTrack(
            path: file.path,
            title: title,
            artist: artist,
            album: album,
            artwork: artwork,
            lyricsPath: lrcPath,
            verifiedArtist: verifiedArtist,
          ),
        );
      } catch (_) {
        // Bozuk bir dosya tüm taramayı durdurmasın.
      }
    }

    tracks.sort(
      (a, b) => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    );

    return tracks;
  }

  static String _fileNameWithoutExtension(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dot = name.lastIndexOf('.');

    if (dot <= 0) {
      return name;
    }

    return name.substring(0, dot);
  }

  static String _parentName(String path) {
    final parts = path.split(Platform.pathSeparator);

    if (parts.length < 2) {
      return 'Bilinmeyen Sanatçı';
    }

    final parent = parts[parts.length - 2];

    if (parent.trim().isEmpty) {
      return 'Bilinmeyen Sanatçı';
    }

    return parent;
  }

  static String? _findLyricsPath(String audioPath) {
    final dot = audioPath.lastIndexOf('.');

    if (dot <= 0) {
      return null;
    }

    final base = audioPath.substring(0, dot);

    final candidates = <String>[
      '$base.lrc',
      '$base.LRC',
    ];

    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }

    return null;
  }
}
