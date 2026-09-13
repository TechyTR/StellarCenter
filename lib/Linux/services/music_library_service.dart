import 'dart:io';

import 'package:media_metadata/media_metadata.dart';

class MusicTrack {
  final String path;
  final String title;
  final String artist;
  final String album;
  final File? cover;
  final File? lyrics;

  const MusicTrack({
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.lyrics,
  });

  bool get hasCover => cover != null;

  bool get hasLyrics => lyrics != null;

  // MP3 + Cover
  // MP3 + LRC
  // MP3 + Cover + LRC
  // = Mavi tik
  bool get verified => hasCover || hasLyrics;
}

class MusicLibraryService {
  const MusicLibraryService();

  String get musicDirectory {
    final home = Platform.environment['HOME'];

    if (home != null && home.isNotEmpty) {
      return '$home/StellarCenter/Music';
    }

    return '/StellarCenter/Music';
  }

  Future<List<MusicTrack>> scan() async {
    final root = Directory(musicDirectory);

    if (!await root.exists()) {
      await root.create(recursive: true);
      return const [];
    }

    final tracks = <MusicTrack>[];

    await for (final entity in root.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      if (!entity.path
          .toLowerCase()
          .endsWith('.mp3')) {
        continue;
      }

      final track = await _readTrack(entity);

      tracks.add(track);
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

  Future<MusicTrack> _readTrack(
    File mp3,
  ) async {
    final directory = mp3.parent;

    final fileName =
        mp3.uri.pathSegments.last;

    final baseName =
        fileName.replaceFirst(
      RegExp(
        r'\.mp3$',
        caseSensitive: false,
      ),
      '',
    );

    final lrc =
        File('${directory.path}/$baseName.lrc');

    final png =
        File('${directory.path}/$baseName.png');

    final jpg =
        File('${directory.path}/$baseName.jpg');

    final jpeg =
        File('${directory.path}/$baseName.jpeg');

    File? cover;

    if (await png.exists()) {
      cover = png;
    } else if (await jpg.exists()) {
      cover = jpg;
    } else if (await jpeg.exists()) {
      cover = jpeg;
    }

    File? lyrics;

    if (await lrc.exists()) {
      lyrics = lrc;
    }

    String title = baseName;
    String artist = directory
        .path
        .split(Platform.pathSeparator)
        .last;

    String album = artist;

    try {
      final metadata =
          await MediaMetadata.read(
        mp3.path,
      );

      final metadataTitle =
          metadata?.title?.trim();

      final metadataArtist =
          metadata?.artist?.trim();

      final metadataAlbum =
          metadata?.album?.trim();

      if (metadataTitle != null &&
          metadataTitle.isNotEmpty) {
        title = metadataTitle;
      }

      if (metadataArtist != null &&
          metadataArtist.isNotEmpty) {
        artist = metadataArtist;
      }

      if (metadataAlbum != null &&
          metadataAlbum.isNotEmpty) {
        album = metadataAlbum;
      }
    } catch (_) {
      // Metadata okunamazsa dosya adı
      // ve klasör adı kullanılmaya devam eder.
    }

    return MusicTrack(
      path: mp3.path,
      title: title,
      artist: artist,
      album: album,
      cover: cover,
      lyrics: lyrics,
    );
  }
}
