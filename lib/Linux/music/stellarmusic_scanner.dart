import 'dart:io';
import 'dart:typed_data';

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
      if (entity is! File) {
        continue;
      }

      final extension = entity.path
          .split('.')
          .last
          .toLowerCase();

      if (extension == 'mp3') {
        files.add(entity);
      }
    }

    final tracks = <StellarMusicTrack>[];

    for (final file in files) {
      try {
        final metadata =
            StellarMusicMetadataReader.read(file);

        final title =
            _clean(metadata.title) ??
            _fileNameWithoutExtension(file.path);

        final artist =
            _clean(metadata.artist) ??
            _parentName(file.path);

        final album =
            _clean(metadata.album) ??
            'Bilinmeyen Albüm';

        Uint8List? artwork = metadata.artwork;

        if (artwork == null) {
          artwork =
              await StellarLocalArtwork.find(
            file.path,
          );
        }

        final lyricsPath =
            _findLyricsPath(file.path);

        final verifiedArtist =
            StellarArtistVerification
                .instance
                .isVerified(artist);

        tracks.add(
          StellarMusicTrack(
            path: file.path,
            title: title,
            artist: artist,
            album: album,
            artwork: artwork,
            lyricsPath: lyricsPath,
            verifiedArtist: verifiedArtist,
          ),
        );
      } catch (_) {
        // Bozuk tek bir MP3 tüm taramayı bozmaz.
      }
    }

    tracks.sort((a, b) {
      final artistCompare =
          a.artist.toLowerCase().compareTo(
                b.artist.toLowerCase(),
              );

      if (artistCompare != 0) {
        return artistCompare;
      }

      final albumCompare =
          a.album.toLowerCase().compareTo(
                b.album.toLowerCase(),
              );

      if (albumCompare != 0) {
        return albumCompare;
      }

      return a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          );
    });

    return tracks;
  }

  static String? _clean(String? value) {
    if (value == null) {
      return null;
    }

    final result = value.trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static String _fileNameWithoutExtension(
    String path,
  ) {
    final name = path
        .split(Platform.pathSeparator)
        .last;

    final dot = name.lastIndexOf('.');

    if (dot <= 0) {
      return name;
    }

    return name.substring(0, dot);
  }

  static String _parentName(String path) {
    final parts =
        path.split(Platform.pathSeparator);

    if (parts.length < 2) {
      return 'Bilinmeyen Sanatçı';
    }

    final parent =
        parts[parts.length - 2].trim();

    if (parent.isEmpty) {
      return 'Bilinmeyen Sanatçı';
    }

    return parent;
  }

  static String? _findLyricsPath(
    String audioPath,
  ) {
    final dot =
        audioPath.lastIndexOf('.');

    if (dot <= 0) {
      return null;
    }

    final base =
        audioPath.substring(0, dot);

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
