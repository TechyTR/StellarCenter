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
    final metadata = StellarMusicMetadataReader.read(file);

    final directory = file.parent;

    final fileName = file.uri.pathSegments.isNotEmpty
        ? _withoutExtension(
            file.uri.pathSegments.last,
          )
        : _withoutExtension(file.path);

    /*
     * Metadata'daki gerçek sanatçı kullanılacak.
     *
     * Metadata yoksa klasör yapısından sanatçı
     * tahmin edilir.
     */
    final artist =
        _clean(metadata.artist) ??
        _artistFromDirectory(
          directory,
          musicRoot: await _musicRoot(file),
        ) ??
        'Bilinmeyen Sanatçı';

    /*
     * ÖNEMLİ:
     *
     * Burada artık dosya adı / şarkı adı
     * kesinlikle albüm olarak kullanılmıyor.
     *
     * Gerçek album metadata'sı varsa onu kullan.
     * Yoksa albüm klasöründen almaya çalış.
     * O da yoksa "Bilinmeyen Albüm".
     */
    final album =
        _clean(metadata.album) ??
        _albumFromDirectory(
          directory,
          musicRoot: await _musicRoot(file),
        ) ??
        'Bilinmeyen Albüm';

    /*
     * Şarkı adı yalnızca title olarak kullanılır.
     */
    final title =
        _clean(metadata.title) ??
        _clean(fileName) ??
        'Bilinmeyen Şarkı';

    /*
     * Önce müzik dosyasının içine gömülü kapak.
     */
    Uint8List? artwork = metadata.artwork;

    /*
     * Embedded artwork yoksa klasördeki kapak
     * dosyalarını ara.
     */
    if (artwork == null || artwork.isEmpty) {
      artwork = await StellarLocalArtwork.find(
        file.path,
      );
    }

    /*
     * Harici lyrics dosyasını bul.
     */
    final lyricsPath = await _findLyrics(file);

    /*
     * Metadata içindeki lyrics.
     */
    final lyricsText = _cleanLyrics(
      metadata.lyrics,
    );

    /*
     * Sanatçı doğrulaması.
     */
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

    /*
     * Beklenen yapı:
     *
     * Music/
     *   Sanatçı/
     *     Albüm/
     *       Şarkı.mp3
     *
     * İlk klasör sanatçı kabul edilir.
     */
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

    /*
     * Music/
     *   Sanatçı/
     *     Albüm/
     *       Şarkı.mp3
     *
     * Burada ikinci klasör albüm.
     */
    if (parts.length >= 2) {
      return _clean(parts[1]);
    }

    /*
     * Sadece:
     *
     * Music/
     *   Sanatçı/
     *     Şarkı.mp3
     *
     * varsa albüm bilinmiyor.
     *
     * Sanatçı klasörünün adını albüm yapmıyoruz.
     */
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

        if (!await file.exists()) {
          continue;
        }

        final length = await file.length();

        if (length <= 0) {
          continue;
        }

        return file.path;
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

    final result = value
        .replaceAll('\u0000', '')
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

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

    final result = value
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
}
