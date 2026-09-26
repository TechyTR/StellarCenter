import 'dart:io';
import 'dart:typed_data';

import 'artist_verification.dart';
import 'local_artwork.dart';
import 'music_metadata.dart';
import 'music_track.dart';

class StellarMusicScanner {
  StellarMusicScanner._();

  static Future<List<StellarMusicTrack>> scan() async {
    final home =
        Platform.environment['HOME'];

    if (home == null ||
        home.trim().isEmpty) {
      return const [];
    }

    final musicDirectory = Directory(
      '$home/StellarCenter/Music',
    );

    if (!await musicDirectory.exists()) {
      return const [];
    }

    final tracks =
        <StellarMusicTrack>[];

    try {
      await for (final entity
          in musicDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        if (!_isSupportedAudio(
          entity.path,
        )) {
          continue;
        }

        try {
          final track =
              await _readTrack(entity);

          if (track != null) {
            tracks.add(track);
          }
        } catch (_) {
          // Tek dosya hatası tüm taramayı bozmaz.
        }
      }
    } catch (_) {
      return tracks;
    }

    tracks.sort(
      _compareTracks,
    );

    return tracks;
  }

  static Future<StellarMusicTrack?> _readTrack(
    File file,
  ) async {
    final metadata =
        StellarMusicMetadataReader.read(file);

    final directory = file.parent;

    final fileName =
        _withoutExtension(
      file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : file.path,
    );

    final directoryParts = directory.path
        .split(Platform.pathSeparator)
        .where(
          (value) => value.isNotEmpty,
        )
        .toList();

    final parentParts =
        directory.parent.path
            .split(Platform.pathSeparator)
            .where(
              (value) => value.isNotEmpty,
            )
            .toList();

    final directoryName =
        directoryParts.isEmpty
            ? null
            : directoryParts.last;

    final parentDirectoryName =
        parentParts.isEmpty
            ? null
            : parentParts.last;

    final artist =
        _clean(metadata.artist) ??
        _clean(parentDirectoryName) ??
        'Bilinmeyen Sanatçı';

    final album =
        _clean(metadata.album) ??
        _clean(directoryName) ??
        'Bilinmeyen Albüm';

    final title =
        _clean(metadata.title) ??
        _clean(fileName) ??
        'Bilinmeyen Şarkı';

    Uint8List? artwork =
        metadata.artwork;

    if (artwork == null ||
        artwork.isEmpty) {
      artwork =
          await StellarLocalArtwork.find(
        file.path,
      );
    }

    final lyricsPath =
        await _findLyrics(file);

    final verifiedArtist =
        StellarArtistVerification
            .instance
            .isVerified(artist);

    return StellarMusicTrack(
      path: file.path,
      title: title,
      artist: artist,
      album: album,
      artwork: artwork,
      lyricsPath: lyricsPath,
      verifiedArtist: verifiedArtist,
    );
  }

  static Future<String?> _findLyrics(
    File audioFile,
  ) async {
    final path = audioFile.path;

    final dot = path.lastIndexOf('.');

    final base = dot > 0
        ? path.substring(0, dot)
        : path;

    final candidates = <String>[
      '$base.lrc',
      '$base.LRC',
    ];

    for (final candidate in candidates) {
      try {
        final file = File(candidate);

        if (await file.exists()) {
          return file.path;
        }
      } catch (_) {}
    }

    return null;
  }

  static int _compareTracks(
    StellarMusicTrack a,
    StellarMusicTrack b,
  ) {
    final artist =
        _compareText(
      a.artist,
      b.artist,
    );

    if (artist != 0) {
      return artist;
    }

    final album =
        _compareText(
      a.album,
      b.album,
    );

    if (album != 0) {
      return album;
    }

    final title =
        _compareText(
      a.title,
      b.title,
    );

    if (title != 0) {
      return title;
    }

    return _compareText(
      a.path,
      b.path,
    );
  }

  static int _compareText(
    String a,
    String b,
  ) {
    return a
        .trim()
        .toLowerCase()
        .compareTo(
          b.trim().toLowerCase(),
        );
  }

  static bool _isSupportedAudio(
    String path,
  ) {
    final value =
        path.toLowerCase();

    return value.endsWith('.mp3') ||
        value.endsWith('.flac') ||
        value.endsWith('.wav') ||
        value.endsWith('.ogg') ||
        value.endsWith('.m4a');
  }

  static String? _clean(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final result =
        value.trim();

    return result.isEmpty
        ? null
        : result;
  }

  static String _withoutExtension(
    String fileName,
  ) {
    final dot =
        fileName.lastIndexOf('.');

    if (dot <= 0) {
      return fileName;
    }

    return fileName.substring(
      0,
      dot,
    );
  }
}
