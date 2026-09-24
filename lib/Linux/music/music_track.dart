import 'dart:typed_data';

class StellarMusicTrack {
  final String path;

  final String title;
  final String artist;
  final String album;

  final Uint8List? artwork;

  final String? lyricsPath;

  final bool verifiedArtist;

  const StellarMusicTrack({
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.artwork,
    required this.lyricsPath,
    required this.verifiedArtist,
  });

  StellarMusicTrack copyWith({
    String? title,
    String? artist,
    String? album,
    Uint8List? artwork,
    String? lyricsPath,
    bool? verifiedArtist,
  }) {
    return StellarMusicTrack(
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artwork: artwork ?? this.artwork,
      lyricsPath: lyricsPath ?? this.lyricsPath,
      verifiedArtist: verifiedArtist ?? this.verifiedArtist,
    );
  }
}
