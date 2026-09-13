import '../services/music_library_service.dart';

class MusicAlbum {
  final String artist;
  final String album;
  final List<MusicTrack> tracks;

  const MusicAlbum({
    required this.artist,
    required this.album,
    required this.tracks,
  });

  MusicTrack? get coverTrack {
    for (final track in tracks) {
      if (track.hasCover) {
        return track;
      }
    }

    return tracks.isNotEmpty
        ? tracks.first
        : null;
  }

  String get displayName {
    if (album.trim().isEmpty) {
      return artist;
    }

    return album;
  }
}

class MusicAlbumBuilder {
  const MusicAlbumBuilder._();

  static List<MusicAlbum> build(
    List<MusicTrack> tracks,
  ) {
    final groups =
        <String, List<MusicTrack>>{};

    for (final track in tracks) {
      final artist =
          track.artist.trim().isEmpty
              ? 'Bilinmeyen Sanatçı'
              : track.artist.trim();

      final album =
          track.album.trim().isEmpty
              ? artist
              : track.album.trim();

      final key =
          '${artist.toLowerCase()}::$album';

      groups.putIfAbsent(
        key,
        () => <MusicTrack>[],
      );

      groups[key]!.add(track);
    }

    final albums = groups.entries.map(
      (entry) {
        final first = entry.value.first;

        final sorted =
            List<MusicTrack>.from(entry.value)
              ..sort(
                (a, b) => a.title
                    .toLowerCase()
                    .compareTo(
                      b.title.toLowerCase(),
                    ),
              );

        return MusicAlbum(
          artist: first.artist.isEmpty
              ? 'Bilinmeyen Sanatçı'
              : first.artist,
          album: first.album.isEmpty
              ? first.artist
              : first.album,
          tracks: sorted,
        );
      },
    ).toList();

    albums.sort(
      (a, b) => a.displayName
          .toLowerCase()
          .compareTo(
            b.displayName.toLowerCase(),
          ),
    );

    return albums;
  }
}
