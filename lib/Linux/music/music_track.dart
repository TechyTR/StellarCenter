import 'dart:typed_data';

class StellarMusicTrack {
  final String path;
  final String title;
  final String artist;
  final String album;
  final Uint8List? artwork;
  final String? lyricsPath;
  final String? lyricsText;
  final bool verifiedArtist;

  const StellarMusicTrack({
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.artwork,
    required this.lyricsPath,
    required this.lyricsText,
    required this.verifiedArtist,
  });

  bool get hasLyrics {
    return (lyricsPath != null &&
            lyricsPath!.trim().isNotEmpty) ||
        (lyricsText != null &&
            lyricsText!.trim().isNotEmpty);
  }

  StellarMusicTrack copyWith({
    String? title,
    String? artist,
    String? album,
    Uint8List? artwork,
    String? lyricsPath,
    String? lyricsText,
    bool? verifiedArtist,
  }) {
    return StellarMusicTrack(
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artwork: artwork ?? this.artwork,
      lyricsPath: lyricsPath ?? this.lyricsPath,
      lyricsText: lyricsText ?? this.lyricsText,
      verifiedArtist:
          verifiedArtist ?? this.verifiedArtist,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StellarMusicTrack &&
        other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
