import 'dart:async';

import 'package:flutter/material.dart';

import 'music_track.dart';
import 'fullscreen_player.dart';
import 'stellar_music_service.dart';
import 'stellar_music_cover.dart';

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

    return GestureDetector(
      onTap: _openFullscreen,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(22),
          color: Colors.black.withOpacity(0.48),
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        child: Row(
          children: [
            StellarMusicCover(
              artwork: track.artwork,
              size: 58,
              radius: 14,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: service.previous,
              icon: const Icon(
                Icons.skip_previous_rounded,
              ),
            ),
            IconButton(
              onPressed:
                  service.togglePlayPause,
              icon: Icon(
                _playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
              ),
            ),
            IconButton(
              onPressed: service.next,
              icon: const Icon(
                Icons.skip_next_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
