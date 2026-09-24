import 'package:flutter/material.dart';

import '../music/music_track.dart';
import '../music/edge_player.dart';
import '../music/fullscreen_player.dart';
import '../music/stellar_music_scanner.dart';
import '../music/stellar_music_service.dart';

class LinuxMusicPage extends StatefulWidget {
  const LinuxMusicPage({super.key});

  @override
  State<LinuxMusicPage> createState() => _LinuxMusicPageState();
}

class _LinuxMusicPageState extends State<LinuxMusicPage> {
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

    final tracks = await StellarMusicScanner.scan();

    if (!mounted) return;

    service.setTracks(tracks);

    setState(() {
      _tracks = tracks;
      _loading = false;
    });
  }

  void _play(int index) {
    if (index < 0 || index >= _tracks.length) {
      return;
    }

    service.setTracks(_tracks);

    service.playIndex(index);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StellarFullscreenPlayer(
          tracks: _tracks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Stellar Music',
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yenile',
                      onPressed: _loading ? null : _scan,
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
                        child: CircularProgressIndicator(),
                      )
                    : _tracks.isEmpty
                        ? const _EmptyMusic()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(
                              18,
                              8,
                              18,
                              130,
                            ),
                            itemCount: _tracks.length,
                            itemBuilder:
                                (context, index) {
                              final track =
                                  _tracks[index];

                              return _SongTile(
                                track: track,
                                onTap: () =>
                                    _play(index),
                              );
                            },
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

class _EmptyMusic extends StatelessWidget {
  const _EmptyMusic();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

class _SongTile extends StatelessWidget {
  final StellarMusicTrack track;
  final VoidCallback onTap;

  const _SongTile({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: _Artwork(
          artwork: track.artwork,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (track.verifiedArtist)
              const Padding(
                padding:
                    EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.verified_rounded,
                  size: 17,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
        subtitle: Text(
          track.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.play_circle_outline_rounded,
          size: 30,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final dynamic artwork;

  const _Artwork({
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
    if (artwork == null) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1769FF),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: Colors.white,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(
        artwork,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}
