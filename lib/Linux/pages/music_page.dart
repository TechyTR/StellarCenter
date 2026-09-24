import 'dart:async';

import 'package:flutter/material.dart';

import '../music/music_track.dart';
import '../music/stellar_edge_player.dart';
import '../music/stellar_fullscreen_player.dart';
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

  List<StellarMusicTrack> _tracks = [];

  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    service.initialize();

    _scan();

    _scanTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _scan(),
    );
  }

  Future<void> _scan() async {
    final tracks =
        await StellarMusicScanner.scan();

    if (!mounted) return;

    setState(() {
      _tracks = tracks;
    });

    service.setTracks(tracks);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();

    // AudioPlayer dispose EDİLMİYOR.
    // Böylece başka sayfaya geçildiğinde müzik devam eder.

    super.dispose();
  }

  void _play(int index) {
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
                      onPressed: _scan,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _tracks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note,
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          8,
                          18,
                          130,
                        ),
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) {
                          final track = _tracks[index];

                          return _SongTile(
                            track: track,
                            onTap: () => _play(index),
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
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        leading: track.artwork != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  track.artwork!,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
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
                  Icons.music_note,
                  color: Colors.white,
                ),
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
              const Icon(
                Icons.verified,
                size: 18,
                color: Colors.blue,
              ),
          ],
        ),
        subtitle: Text(
          track.artist.isEmpty
              ? 'Bilinmeyen sanatçı'
              : track.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.play_circle_outline,
          size: 30,
        ),
        onTap: onTap,
      ),
    );
  }
}
