import 'dart:async';

import 'package:flutter/material.dart';

import 'music_track.dart';
import 'repeat_mode.dart';
import 'stellar_music_background.dart';
import 'stellar_music_cover.dart';
import 'stellar_music_service.dart';

class StellarFullscreenPlayer extends StatefulWidget {
  final List<StellarMusicTrack> tracks;

  const StellarFullscreenPlayer({
    super.key,
    required this.tracks,
  });

  @override
  State<StellarFullscreenPlayer> createState() =>
      _StellarFullscreenPlayerState();
}

class _StellarFullscreenPlayerState
    extends State<StellarFullscreenPlayer> {
  final service = StellarMusicService.instance;

  StreamSubscription? _trackSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _repeatSub;

  StellarMusicTrack? _track;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  StellarRepeatMode _repeatMode =
      StellarRepeatMode.playlistOnce;

  @override
  void initState() {
    super.initState();

    service.setTracks(widget.tracks);

    _track = service.currentTrack;
    _repeatMode = service.repeatMode;

    _trackSub = service.currentTrackStream.listen((track) {
      if (mounted) setState(() => _track = track);
    });

    _positionSub = service.positionStream.listen((value) {
      if (mounted) setState(() => _position = value);
    });

    _durationSub = service.durationStream.listen((value) {
      if (mounted) setState(() => _duration = value);
    });

    _playingSub = service.playingStream.listen((value) {
      if (mounted) setState(() => _playing = value);
    });

    _repeatSub = service.repeatModeStream.listen((value) {
      if (mounted) setState(() => _repeatMode = value);
    });
  }

  @override
  void dispose() {
    _trackSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _repeatSub?.cancel();

    // AudioPlayer burada KESİNLİKLE dispose edilmiyor.
    return super.dispose();
  }

  String _time(Duration value) {
    final minutes = value.inMinutes;
    final seconds =
        value.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Müzik')),
        body: const Center(
          child: Text('Henüz şarkı seçilmedi.'),
        ),
      );
    }

    final maxSeconds =
        _duration.inMilliseconds <= 0
            ? 1.0
            : _duration.inMilliseconds.toDouble();

    final currentSeconds =
        _position.inMilliseconds
            .clamp(0, _duration.inMilliseconds)
            .toDouble();

    return Scaffold(
      body: StellarMusicBackground(
        colors: const [
          Color(0xFF1769FF),
          Color(0xFF8A2BE2),
          Color(0xFFFF2D8D),
          Color(0xFF00C8FF),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'ŞİMDİ ÇALIYOR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: StellarMusicCover(
                  artwork: track.artwork,
                  size: 360,
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white70,
                            ),
                          ),
                          if (track.album.isNotEmpty)
                            Text(
                              track.album,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: service.cycleRepeatMode,
                      icon: Icon(
                        _repeatMode == StellarRepeatMode.songForever
                            ? Icons.repeat_one
                            : Icons.repeat,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Slider(
                  value: currentSeconds,
                  max: maxSeconds,
                  onChanged: (value) {
                    service.seek(
                      Duration(
                        milliseconds: value.toInt(),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_time(_position)),
                    Text(_time(_duration)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 34,
                    onPressed: service.previous,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.18),
                    ),
                    child: IconButton(
                      iconSize: 40,
                      onPressed: service.toggle,
                      icon: Icon(
                        _playing
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    iconSize: 34,
                    onPressed: service.next,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                _repeatMode.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: .8,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
