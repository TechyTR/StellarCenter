import 'dart:async';

import 'package:flutter/material.dart';

import 'music_track.dart';
import 'fullscreen_player.dart';
import 'music_service.dart';
import 'music_cover.dart';

class StellarEdgePlayer extends StatefulWidget {
  final List<StellarMusicTrack> tracks;

  const StellarEdgePlayer({
    super.key,
    required this.tracks,
  });

  @override
  State<StellarEdgePlayer> createState() =>
      _StellarEdgePlayerState();
}

class _StellarEdgePlayerState
    extends State<StellarEdgePlayer> {
  final StellarMusicService service =
      StellarMusicService.instance;

  StreamSubscription<
          StellarMusicTrack?>?
      _trackSubscription;

  StreamSubscription<bool>?
      _playingSubscription;

  StellarMusicTrack? _track;
  bool _playing = false;

  @override
  void initState() {
    super.initState();

    _track = service.currentTrack;
    _playing = service.isPlaying;

    _trackSubscription =
        service.currentTrackStream.listen(
      (track) {
        if (!mounted) return;

        setState(() {
          _track = track;
        });
      },
    );

    _playingSubscription =
        service.playingStream.listen(
      (playing) {
        if (!mounted) return;

        setState(() {
          _playing = playing;
        });
      },
    );
  }

  @override
  void dispose() {
    _trackSubscription?.cancel();
    _playingSubscription?.cancel();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            StellarFullscreenPlayer(
          tracks: widget.tracks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;

    if (track == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        10,
        10,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        color: Colors.black.withOpacity(0.48),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Tam ekran',
              onPressed: _openFullscreen,
              icon: const Icon(
                Icons.open_in_full_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Row(
            children: [
              Hero(
                tag:
                    'stellar-cover-${track.path}',
                child: StellarMusicCover(
                  artwork: track.artwork,
                  size: 58,
                  radius: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            track.artist,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (track
                            .verifiedArtist) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color:
                                Color(0xFF2196F3),
                            size: 15,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.album,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Önceki',
                onPressed: service.previous,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: _playing
                    ? 'Duraklat'
                    : 'Oynat',
                onPressed:
                    service.togglePlayPause,
                icon: Icon(
                  _playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Sonraki',
                onPressed: service.next,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
