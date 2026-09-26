import 'package:flutter/material.dart';

import '../music/music_track.dart';
import '../music/edge_player.dart';
import '../music/stellarmusic_scanner.dart';
import '../music/music_service.dart';
import '../music/music_cover.dart';

class LinuxMusicPage extends StatefulWidget {
  const LinuxMusicPage({
    super.key,
  });

  @override
  State<LinuxMusicPage> createState() =>
      _LinuxMusicPageState();
}

class _LinuxMusicPageState
    extends State<LinuxMusicPage> {
  final StellarMusicService service =
      StellarMusicService.instance;

  List<StellarMusicTrack> _tracks = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await service.initialize();
    await _scan();
  }

  Future<void> _scan() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final tracks =
        await StellarMusicScanner.scan();

    if (!mounted) {
      return;
    }

    service.setTracks(tracks);

    setState(() {
      _tracks = tracks;
      _loading = false;
    });
  }

  Future<void> _play(int index) async {
    if (index < 0 ||
        index >= _tracks.length) {
      return;
    }

    service.setTracks(_tracks);

    await service.playIndex(index);
  }

  Map<String, Map<String, List<int>>>
      _buildGroups() {
    final groups =
        <String, Map<String, List<int>>>{};

    for (var i = 0;
        i < _tracks.length;
        i++) {
      final track = _tracks[i];

      groups.putIfAbsent(
        track.artist,
        () => <String, List<int>>{},
      );

      groups[track.artist]!
          .putIfAbsent(
            track.album,
            () => <int>[],
          )
          .add(i);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Müzik',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Stellar Music',
                            style: TextStyle(
                              color:
                                  Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yenile',
                      onPressed:
                          _loading ? null : _scan,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : _tracks.isEmpty
                        ? const _EmptyMusic()
                        : ListView(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              18,
                              8,
                              18,
                              150,
                            ),
                            children: [
                              for (final artistEntry
                                  in groups.entries)
                                _ArtistSection(
                                  artist:
                                      artistEntry.key,
                                  albums:
                                      artistEntry.value,
                                  tracks:
                                      _tracks,
                                  onPlay: _play,
                                ),
                            ],
                          ),
              ),
            ],
          ),
          if (_tracks.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StellarEdgePlayer(
                tracks: _tracks,
              ),
            ),
        ],
      ),
    );
  }
}

class _ArtistSection
    extends StatelessWidget {
  final String artist;
  final Map<String, List<int>> albums;
  final List<StellarMusicTrack> tracks;
  final Future<void> Function(int) onPlay;

  const _ArtistSection({
    required this.artist,
    required this.albums,
    required this.tracks,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final firstIndex =
        albums.values.first.first;

    final artistArtwork =
        tracks[firstIndex].artwork;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(
            10,
            0,
            10,
            10,
          ),
          leading: StellarMusicCover(
            artwork: artistArtwork,
            size: 52,
            radius: 12,
          ),
          title: Text(
            artist,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            '${albums.length} albüm',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          children: [
            for (final albumEntry
                in albums.entries)
              _AlbumSection(
                album: albumEntry.key,
                indexes:
                    albumEntry.value,
                tracks: tracks,
                onPlay: onPlay,
              ),
          ],
        ),
      ),
    );
  }
}

class _AlbumSection
    extends StatelessWidget {
  final String album;
  final List<int> indexes;
  final List<StellarMusicTrack> tracks;
  final Future<void> Function(int) onPlay;

  const _AlbumSection({
    required this.album,
    required this.indexes,
    required this.tracks,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final artwork =
        tracks[indexes.first].artwork;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          childrenPadding:
              const EdgeInsets.only(
            bottom: 6,
          ),
          leading: StellarMusicCover(
            artwork: artwork,
            size: 44,
            radius: 10,
          ),
          title: Text(
            album,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            '${indexes.length} şarkı',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          children: [
            for (final index in indexes)
              _SongTile(
                track: tracks[index],
                onTap: () => onPlay(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _SongTile
    extends StatelessWidget {
  final StellarMusicTrack track;
  final VoidCallback onTap;

  const _SongTile({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      leading: const SizedBox(
        width: 28,
        child: Icon(
          Icons.music_note_rounded,
          size: 19,
          color: Colors.white54,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
          if (track.verifiedArtist)
            const Padding(
              padding:
                  EdgeInsets.only(left: 6),
              child: Icon(
                Icons.verified_rounded,
                size: 16,
                color: Colors.blue,
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.play_circle_outline_rounded,
        size: 26,
      ),
      onTap: onTap,
    );
  }
}

class _EmptyMusic
    extends StatelessWidget {
  const _EmptyMusic();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 64,
            color: Colors.white38,
          ),
          SizedBox(height: 15),
          Text(
            'Henüz müzik bulunamadı',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '~/StellarCenter/Music',
            style: TextStyle(
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
