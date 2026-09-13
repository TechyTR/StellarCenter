import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  bool get verified {
    return artist != 'Unknown Artist' ||
        album != 'Unknown Album' ||
        hasCover ||
        hasLyrics;
  }
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

      if (!entity.path.toLowerCase().endsWith('.mp3')) {
        continue;
      }

      final track = await _readTrack(entity);

      tracks.add(track);
    }

    tracks.sort(
      (a, b) => a.title
          .toLowerCase()
          .compareTo(b.title.toLowerCase()),
    );

    return tracks;
  }

  Future<MusicTrack> _readTrack(File mp3) async {
    final directory = mp3.parent;

    final fileName = mp3.uri.pathSegments.last;

    final baseName = fileName.replaceFirst(
      RegExp(
        r'\.mp3$',
        caseSensitive: false,
      ),
      '',
    );

    final lrc = File(
      '${directory.path}/$baseName.lrc',
    );

    final png = File(
      '${directory.path}/$baseName.png',
    );

    final jpg = File(
      '${directory.path}/$baseName.jpg',
    );

    final jpeg = File(
      '${directory.path}/$baseName.jpeg',
    );

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
    String artist = 'Unknown Artist';
    String album = 'Unknown Album';

    final folderName = directory.path
        .split(Platform.pathSeparator)
        .where((part) => part.isNotEmpty)
        .lastOrNull;

    if (folderName != null && folderName.isNotEmpty) {
      album = folderName;
    }

    final id3 = await _readId3Tags(mp3);

    if (id3.title != null && id3.title!.isNotEmpty) {
      title = id3.title!;
    }

    if (id3.artist != null && id3.artist!.isNotEmpty) {
      artist = id3.artist!;
    }

    if (id3.album != null && id3.album!.isNotEmpty) {
      album = id3.album!;
    }

    final parts = baseName
        .split(' - ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (id3.artist == null &&
        id3.title == null &&
        parts.length >= 2) {
      artist = parts[0];
      title = parts.sublist(1).join(' - ');
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

  Future<_Id3Tags> _readId3Tags(File file) async {
    try {
      final handle = await file.open();

      try {
        final header = await handle.read(10);

        if (header.length < 10) {
          return const _Id3Tags();
        }

        if (header[0] != 0x49 ||
            header[1] != 0x44 ||
            header[2] != 0x33) {
          return const _Id3Tags();
        }

        final versionMajor = header[3];

        final tagSize = _synchsafeInt(
          header.sublist(6, 10),
        );

        if (tagSize <= 0) {
          return const _Id3Tags();
        }

        final tagData = await handle.read(tagSize);

        String? title;
        String? artist;
        String? album;

        var offset = 0;

        while (offset + 10 <= tagData.length) {
          final frameId = ascii.decode(
            tagData.sublist(
              offset,
              offset + 4,
            ),
            allowInvalid: true,
          );

          if (frameId.trim().isEmpty ||
              !RegExp(r'^[A-Z0-9]{4}$').hasMatch(frameId)) {
            break;
          }

          final frameSizeBytes = tagData.sublist(
            offset + 4,
            offset + 8,
          );

          final frameSize = versionMajor >= 4
              ? _synchsafeInt(frameSizeBytes)
              : _bigEndianInt(frameSizeBytes);

          if (frameSize <= 0 ||
              offset + 10 + frameSize > tagData.length) {
            break;
          }

          final frameData = tagData.sublist(
            offset + 10,
            offset + 10 + frameSize,
          );

          switch (frameId) {
            case 'TIT2':
              title = _decodeTextFrame(frameData);
              break;

            case 'TPE1':
              artist = _decodeTextFrame(frameData);
              break;

            case 'TALB':
              album = _decodeTextFrame(frameData);
              break;
          }

          offset += 10 + frameSize;
        }

        return _Id3Tags(
          title: title,
          artist: artist,
          album: album,
        );
      } finally {
        await handle.close();
      }
    } catch (_) {
      return const _Id3Tags();
    }
  }

  String? _decodeTextFrame(List<int> data) {
    if (data.isEmpty) {
      return null;
    }

    final encoding = data[0];
    final bytes = data.sublist(1);

    if (bytes.isEmpty) {
      return null;
    }

    try {
      switch (encoding) {
        case 0:
          return latin1
              .decode(bytes, allowInvalid: true)
              .replaceAll('\u0000', '')
              .trim();

        case 1:
          if (bytes.length >= 2 &&
              bytes[0] == 0xFF &&
              bytes[1] == 0xFE) {
            return utf16
                .decode(bytes.sublist(2))
                .replaceAll('\u0000', '')
                .trim();
          }

          if (bytes.length >= 2 &&
              bytes[0] == 0xFE &&
              bytes[1] == 0xFF) {
            return _decodeUtf16BigEndian(
              bytes.sublist(2),
            );
          }

          return utf16
              .decode(bytes)
              .replaceAll('\u0000', '')
              .trim();

        case 2:
          return utf16
              .decode(bytes, allowInvalid: true)
              .replaceAll('\u0000', '')
              .trim();

        case 3:
          return utf8
              .decode(bytes, allowMalformed: true)
              .replaceAll('\u0000', '')
              .trim();

        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  String _decodeUtf16BigEndian(List<int> bytes) {
    final units = <int>[];

    for (var i = 0; i + 1 < bytes.length; i += 2) {
      units.add(
        (bytes[i] << 8) | bytes[i + 1],
      );
    }

    return String.fromCharCodes(units)
        .replaceAll('\u0000', '')
        .trim();
  }

  int _synchsafeInt(List<int> bytes) {
    if (bytes.length < 4) {
      return 0;
    }

    return (bytes[0] << 21) |
        (bytes[1] << 14) |
        (bytes[2] << 7) |
        bytes[3];
  }

  int _bigEndianInt(List<int> bytes) {
    if (bytes.length < 4) {
      return 0;
    }

    return (bytes[0] << 24) |
        (bytes[1] << 16) |
        (bytes[2] << 8) |
        bytes[3];
  }
}

class _Id3Tags {
  final String? title;
  final String? artist;
  final String? album;

  const _Id3Tags({
    this.title,
    this.artist,
    this.album,
  });
}

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull {
    if (isEmpty) {
      return null;
    }

    return last;
  }
}
