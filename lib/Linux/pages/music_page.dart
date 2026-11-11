import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../music/edge_player.dart';
import '../music/music_cover.dart';
import '../music/music_service.dart';
import '../music/music_track.dart';
import '../music/stellarmusic_scanner.dart';

class LinuxMusicPage
    extends StatefulWidget {
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

  List<StellarMusicTrack> _tracks =
      const [];

  bool _loading = true;
  String _searchQuery = '';
  bool _favoritesOnly = false;
  StreamSubscription<FileSystemEvent>? _folderWatcher;
  Timer? _scanDebounce;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await service.initialize();
    await service.loadLibraryState();
    await _scan();
    _startFolderWatcher();
  }

  void _startFolderWatcher() {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) return;
    final directory = Directory('$home/StellarCenter/Music');
    if (!directory.existsSync()) return;
    _folderWatcher?.cancel();
    _folderWatcher = directory.watch(recursive: true).listen((_) {
      _scanDebounce?.cancel();
      _scanDebounce = Timer(const Duration(milliseconds: 900), () {
        if (mounted && !_loading) _scan();
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _folderWatcher?.cancel();
    _scanDebounce?.cancel();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final tracks =
        await StellarMusicScanner.scan();

    if (!mounted) return;

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
      final query = _searchQuery.trim().toLowerCase();
      if (_favoritesOnly && !service.isFavorite(track)) continue;
      if (query.isNotEmpty && !('${track.title} ${track.artist} ${track.album}'.toLowerCase().contains(query))) continue;

      final artist =
          track.artist.trim().isEmpty
              ? 'Bilinmeyen Sanatçı'
              : track.artist.trim();

      final album =
          track.album.trim().isEmpty
              ? 'Bilinmeyen Albüm'
              : track.album.trim();

      groups
          .putIfAbsent(
            artist,
            () => <String, List<int>>{},
          )
          .putIfAbsent(
            album,
            () => <int>[],
          )
          .add(i);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.space): service.togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => service.seek(service.position + const Duration(seconds: 5)),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => service.seek(service.position - const Duration(seconds: 5)),
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () => _searchFocus.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Stack(
        children: [
          Positioned(
            left: 0, top: 0, bottom: 0,
            right: wide ? 360 : 0,
            child: Column(
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
                      tooltip: _favoritesOnly ? 'Tüm şarkılar' : 'Favoriler',
                      onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
                      icon: Icon(_favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _favoritesOnly ? const Color(0xFF75F0A5) : null),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  focusNode: _searchFocus,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Şarkı, sanatçı veya albüm ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white.withOpacity(.055),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
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
                        : groups.isEmpty
                            ? const Center(child: Text('Eşleşen müzik bulunamadı', style: TextStyle(color: Colors.white54)))
                            : ListView.builder(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              18,
                              8,
                              18,
                              150,
                            ),
                            itemCount:
                                groups.length,
                            itemBuilder:
                                (context, index) {
                              final entry =
                                  groups.entries
                                      .elementAt(
                                index,
                              );

                              return _ArtistSection(
                                artist: entry.key,
                                albums: entry.value,
                                tracks: _tracks,
                                onPlay: _play,
                              );
                            },
                          ),
              ),
            ],
          )),
          if (wide && _tracks.isNotEmpty)
            Positioned(
              top: 0, right: 0, bottom: 0, width: 360,
              child: StellarEdgePlayer(tracks: _tracks),
            ),
          if (!wide && _tracks.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StellarEdgePlayer(
                tracks: _tracks,
              ),
            ),
        ],
      );
        },
      ),
        ),
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

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data:
            Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent,
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
            artwork:
                tracks[firstIndex].artwork,
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
            for (final entry
                in albums.entries)
              _AlbumSection(
                album: entry.key,
                indexes: entry.value,
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
        data:
            Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent,
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
                onTap: () =>
                    onPlay(index),
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
      leading: StellarMusicCover(
        artwork: track.artwork,
        size: 44,
        radius: 9,
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
      subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54, fontSize: 11)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(tooltip: 'Kuyruğa ekle', onPressed: () => StellarMusicService.instance.addToQueue(track),
            icon: const Icon(Icons.playlist_add_rounded, size: 21)),
        IconButton(tooltip: 'Favorilere ekle', onPressed: () => StellarMusicService.instance.toggleFavorite(track),
            icon: Icon(StellarMusicService.instance.isFavorite(track) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 19, color: StellarMusicService.instance.isFavorite(track) ? const Color(0xFF75F0A5) : null)),
        const Icon(Icons.play_circle_outline_rounded, size: 24),
      ]),
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
