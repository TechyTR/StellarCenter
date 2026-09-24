import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class StellarMusicMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final Uint8List? artwork;

  const StellarMusicMetadata({
    this.title,
    this.artist,
    this.album,
    this.artwork,
  });
}

class StellarMusicMetadataReader {
  static StellarMusicMetadata read(
    File file,
  ) {
    try {
      final metadata = readMetadata(
        file,
        getImage: true,
      );

      Uint8List? artwork;

      try {
        final image = metadata.pictures;

        if (image != null &&
            image.isNotEmpty) {
          artwork = image.first.bytes;
        }
      } catch (_) {
        artwork = null;
      }

      return StellarMusicMetadata(
        title: _clean(metadata.title),
        artist: _clean(metadata.artist),
        album: _clean(metadata.album),
        artwork: artwork,
      );
    } catch (_) {
      return const StellarMusicMetadata();
    }
  }

  static String? _clean(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
