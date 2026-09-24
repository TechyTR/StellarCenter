import 'dart:async';

import 'package:flutter/material.dart';

import 'music_track.dart';
import 'fullscreen_player.dart';
import 'stellar_music_cover.dart';
import 'stellar_music_service.dart';
import 'music_icon.dart';

class StellarEdgePlayer extends StatefulWidget {
  final List<StellarMusicTrack> tracks;

  const StellarEdgePlayer({
    super.key,
    required this.tracks,
  });

  @override
  State<StellarEdgePlayer> createState() => _StellarEdgePlayerState();
}

class _StellarEdgePlayerState extends State<StellarEdgePlayer> {
  final StellarMusicService service =
      StellarMusicService.instance;

  StreamSubscription? _trackSub;
  StreamSubscription? _playingSub;

  StellarMusicTrack? _track;
  bool _playing = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();

    service.setTracks(widget.tracks);

    _track = service.currentTrack;
    _playing = service.isPlaying;

    _trackSub = service.currentTrackStream.listen((track) {
      if (!mounted) return;

      setState(() {
        _track = track;
      });
    });

    _playingSub = service.playingStream.listen((playing) {
      if (!mounted) return;

      setState(() {
        _playing = playing;
      });
    });
  }

  @override
  void dispose() {
    _trackSub?.cancel();
    _playingSub?.cancel();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StellarFullscreenPlayer(
          tracks: widget.tracks,
        ),
      ),
    );
  }

  void _handleVerticalDragUpdate(
    DragUpdateDetails details,
  ) {
    if (details.delta.dy < 0) {
      _dragDistance += -details.delta.dy;
    }
  }

  void _handleVerticalDragEnd(
    DragEndDetails details,
  ) {
    if (_dragDistance > 45) {
      _openFullscreen();
    }

    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;

    if (track == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openFullscreen,
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        padding: const EdgeInsets.fromLTRB(
          10,
          10,
          12,
          10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withValues(alpha: 0.50),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                StellarMusicCover(
                  artwork: track.artwork,
                  size: 56,
                  radius: 14,
                ),

                const SizedBox(width: 12),

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
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.artist.isEmpty
                            ? 'Bilinmeyen sanatçı'
                            : track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                _SmallControl(
                  icon: StellarMusicIconType.previous,
                  onTap: service.previous,
                ),

                _SmallControl(
                  icon: _playing
                      ? StellarMusicIconType.pause
                      : StellarMusicIconType.play,
                  onTap: service.togglePlayPause,
                ),

                _SmallControl(
                  icon: StellarMusicIconType.next,
                  onTap: service.next,
                ),
              ],
            ),

            const SizedBox(height: 5),

            const Text(
              'Yukarı kaydır • Tam ekran',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallControl extends StatelessWidget {
  final StellarMusicIconType icon;
  final VoidCallback onTap;

  const _SmallControl({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: StellarMusicIcon(
          type: icon,
          size: 25,
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}
