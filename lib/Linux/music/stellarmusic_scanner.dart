import 'dart:io';
import 'dart:typed_data';

import 'artist_verification.dart';
import 'local_artwork.dart';
import 'music_metadata.dart';
import 'music_track.dart';

class StellarMusicScanner {
  StellarMusicScanner._();

  static Future<List<StellarMusicTrack>> scan() async {
    final home = Platform.environment['HOME'];

    if (home == null || home.trim().isEmpty) {
      return const [];
    }

    final musicDirectory = Directory(
      '$home/StellarCenter/Music',
    );

    if (!await musicDirectory.exists()) {
      return const [];
    }

    final tracks = <StellarMusicTrack>[];

    try {
      await for (final entity
          in musicDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File ||
            !_isSupportedAudio(entity.path)) {
          continue;
        }

        try {
          final track = await _readTrack(entity);

          if (track != null) {
            tracks.add(track);
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      return tracks;
    }

    tracks.sort(_compareTracks);

    return List.unmodifiable(tracks);
  }

  static Future<StellarMusicTrack?> _readTrack(
    File file,
  ) async {
    final metadata =
        StellarMusicMetadataReader.read(file);

    final directory = file.parent;

    final fileName =
        file.uri.pathSegments.isNotEmpty
            ? _withoutExtension(
                file.uri.pathSegments.last,
              )
            : _withoutExtension(file.path);

    final directoryName =
        _lastPart(directory.path);

    final parentName =
        _lastPart(directory.parent.path);

    final artist =
        _clean(metadata.artist) ??
        _clean(metadata.album) ??
        _clean(parentName) ??
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

    /*
     * Embedded artwork yoksa aynı klasördeki
     * kapak dosyalarını ara.
     */
    if (artwork == null || artwork.isEmpty) {
      artwork =
          await StellarLocalArtwork.find(
        file.path,
      );
    }

    /*
     * Önce aynı isimli LRC dosyasını ara.
     */
    final lyricsPath =
        await _findLyrics(file);

    /*
     * Metadata içinde gömülü lyrics varsa onu
     * da sakla.
     */
    final lyricsText =
        _cleanLyrics(metadata.lyrics);

    final verified =
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
      lyricsText: lyricsText,
      verifiedArtist: verified,
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

    final directory =
        audioFile.parent.path;

    final fileName =
        audioFile.uri.pathSegments.last;

    final withoutExtension =
        _withoutExtension(fileName);

    final candidates = <String>[
      '$base.lrc',
      '$base.LRC',

      '$directory/$withoutExtension.lrc',
      '$directory/$withoutExtension.LRC',

      '$directory/lyrics.lrc',
      '$directory/Lyrics.lrc',
      '$directory/LYRICS.LRC',

      '$directory/lyrics.txt',
      '$directory/Lyrics.txt',
    ];

    final seen = <String>{};

    for (final candidate in candidates) {
      if (!seen.add(candidate)) {
        continue;
      }

      try {
        final file = File(candidate);

        if (await file.exists()) {
          final length =
              await file.length();

          if (length > 0) {
            return file.path;
          }
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  static int _compareTracks(
    StellarMusicTrack a,
    StellarMusicTrack b,
  ) {
    final artist =
        _compareText(a.artist, b.artist);

    if (artist != 0) {
      return artist;
    }

    final album =
        _compareText(a.album, b.album);

    if (album != 0) {
      return album;
    }

    final title =
        _compareText(a.title, b.title);

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
        value
            .replaceAll('\u0000', '')
            .trim();

    return result.isEmpty
        ? null
        : result;
  }

  static String? _cleanLyrics(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final result =
        value
            .replaceAll('\u0000', '')
            .trim();

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

  static String? _lastPart(
    String path,
  ) {
    final parts = path
        .split(Platform.pathSeparator)
        .where(
          (value) =>
              value.isNotEmpty,
        )
        .toList();

    return parts.isEmpty
        ? null
        : parts.last;
  }
}
