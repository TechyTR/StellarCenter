import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class StellarMusicMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final Uint8List? artwork;
  final String? lyrics;

  const StellarMusicMetadata({
    this.title,
    this.artist,
    this.album,
    this.artwork,
    this.lyrics,
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
        final pictures = metadata.pictures;

        if (pictures.isNotEmpty) {
          /*
           * Önce cover/front görselini tercih et.
           * Bulamazsak ilk resmi kullan.
           */
          final picture = pictures.firstWhere(
            (picture) =>
                picture.bytes.isNotEmpty,
            orElse: () => pictures.first,
          );

          if (picture.bytes.isNotEmpty) {
            artwork =
                Uint8List.fromList(
              picture.bytes,
            );
          }
        }
      } catch (_) {
        artwork = null;
      }

      return StellarMusicMetadata(
        title: _clean(metadata.title),
        artist: _clean(metadata.artist),
        album: _clean(metadata.album),
        lyrics: _clean(metadata.lyrics),
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
}
