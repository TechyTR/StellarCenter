import 'dart:io';
import 'dart:typed_data';

import 'artist_verification.dart';
import 'local_artwork.dart';
import 'lyrics_loader.dart';
import 'music_metadata.dart';
import 'music_track.dart';
import 'lrc_parser.dart' ;

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
      await for (final entity in musicDirectory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        if (!_isSupportedAudio(entity.path)) {
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

    /*
     * Önce aynı isimli .lrc dosyasını bul.
     *
     * Örnek:
     *
     * şarkı.mp3
     * şarkı.lrc
     * şarkı.jpg
     */
    final lyricsPath = await _findLyrics(file);

    StellarLrcDocument? lrcDocument;

    if (lyricsPath != null) {
      try {
        lrcDocument =
            await StellarLyricsLoader.loadDocument(
          lyricsPath,
        );
      } catch (_) {
        lrcDocument = null;
      }
    }

    /*
     * Öncelik sırası:
     *
     * 1. Audio metadata
     * 2. LRC metadata
     * 3. Klasör yapısı
     * 4. Fallback
     */

    final artist =
        _clean(metadata.artist) ??
        _clean(lrcDocument?.artist) ??
        _artistFromDirectory(
          directory,
          musicRoot: await _musicRoot(file),
        ) ??
        'Bilinmeyen Sanatçı';

    final album =
        _clean(metadata.album) ??
        _clean(lrcDocument?.album) ??
        _albumFromDirectory(
          directory,
          musicRoot: await _musicRoot(file),
        ) ??
        'Bilinmeyen Albüm';

    final title =
        _clean(metadata.title) ??
        _clean(lrcDocument?.title) ??
        _clean(fileName) ??
        'Bilinmeyen Şarkı';

    /*
     * Kapak:
     *
     * 1. MP3 içindeki embedded artwork
     * 2. Aynı klasördeki aynı isimli JPG/PNG
     */
    Uint8List? artwork = metadata.artwork;

    if (artwork == null || artwork.isEmpty) {
      artwork = await StellarLocalArtwork.find(
        file.path,
      );
    }

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

  static Future<String> _musicRoot(
    File file,
  ) async {
    final home = Platform.environment['HOME'];

    if (home == null || home.trim().isEmpty) {
      return file.parent.path;
    }

    return '$home/StellarCenter/Music';
  }

  static String? _artistFromDirectory(
    Directory directory, {
    required String musicRoot,
  }) {
    final normalizedDirectory =
        _normalizePath(directory.path);

    final normalizedRoot =
        _normalizePath(musicRoot);

    if (normalizedDirectory == normalizedRoot) {
      return null;
    }

    final relative = _relativePath(
      normalizedDirectory,
      normalizedRoot,
    );

    if (relative == null || relative.isEmpty) {
      return null;
    }

    final parts = relative
        .split('/')
        .where(
          (part) => part.trim().isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return null;
    }

    return _clean(parts.first);
  }

  static String? _albumFromDirectory(
    Directory directory, {
    required String musicRoot,
  }) {
    final normalizedDirectory =
        _normalizePath(directory.path);

    final normalizedRoot =
        _normalizePath(musicRoot);

    if (normalizedDirectory == normalizedRoot) {
      return null;
    }

    final relative = _relativePath(
      normalizedDirectory,
      normalizedRoot,
    );

    if (relative == null || relative.isEmpty) {
      return null;
    }

    final parts = relative
        .split('/')
        .where(
          (part) => part.trim().isNotEmpty,
        )
        .toList();

    if (parts.length >= 2) {
      return _clean(parts[1]);
    }

    return null;
  }

  static String? _relativePath(
    String path,
    String root,
  ) {
    final normalizedPath =
        _normalizePath(path);

    final normalizedRoot =
        _normalizePath(root);

    if (normalizedPath == normalizedRoot) {
      return '';
    }

    final prefix = '$normalizedRoot/';

    if (!normalizedPath.startsWith(prefix)) {
      return null;
    }

    return normalizedPath.substring(
      prefix.length,
    );
  }

  static String _normalizePath(
    String path,
  ) {
    return path
        .replaceAll('\\', '/')
        .replaceAll(
          RegExp(r'/+'),
          '/',
        )
        .replaceFirst(
          RegExp(r'/$'),
          '',
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

    final directory = audioFile.parent.path;

    final fileName =
        audioFile.uri.pathSegments.last;

    final withoutExtension =
        _withoutExtension(fileName);

    /*
     * Öncelik aynı isimli LRC.
     */
    final candidates = <String>[
      '$base.lrc',
      '$base.LRC',

      '$directory/$withoutExtension.lrc',
      '$directory/$withoutExtension.LRC',

      '$directory/lyrics.lrc',
      '$directory/Lyrics.lrc',
      '$directory/LYRICS.LRC',
    ];

    final seen = <String>{};

    for (final candidate in candidates) {
      if (!seen.add(candidate)) {
        continue;
      }

      try {
        final lyricsFile = File(candidate);

        if (!await lyricsFile.exists()) {
          continue;
        }

        final length =
            await lyricsFile.length();

        if (length <= 0) {
          continue;
        }

        return lyricsFile.path;
      } catch (_) {
        continue;
      }
    }

    /*
     * Dosya adı büyük/küçük harf açısından farklıysa
     * klasördeki .lrc dosyalarını da kontrol et.
     */
    try {
      await for (final entity in audioFile.parent.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        final name =
            entity.uri.pathSegments.last;

        if (!name.toLowerCase().endsWith('.lrc')) {
          continue;
        }

        final candidateBase =
            _withoutExtension(name);

        if (candidateBase.toLowerCase() ==
            withoutExtension.toLowerCase()) {
          if (await entity.length() > 0) {
            return entity.path;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static int _compareTracks(
    StellarMusicTrack a,
    StellarMusicTrack b,
  ) {
    final artist = _compareText(
      a.artist,
      b.artist,
    );

    if (artist != 0) {
      return artist;
    }

    final album = _compareText(
      a.album,
      b.album,
    );

    if (album != 0) {
      return album;
    }

    final title = _compareText(
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
    final value = path.toLowerCase();

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

    final result = value
        .replaceAll('\u0000', '')
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    return result.isEmpty ? null : result;
  }

  static String? _cleanLyrics(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final result = value
        .replaceAll('\u0000', '')
        .trim();

    return result.isEmpty ? null : result;
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
