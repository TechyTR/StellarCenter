import 'package:flutter/material.dart';

import 'music_track.dart';
import 'repeat_mode.dart';
import 'stellar_music_background.dart';
import 'stellar_music_cover.dart';
import 'stellar_music_icon.dart';
import 'stellar_music_service.dart';
import 'stellar_lyrics_overlay.dart';

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

  @override
  void initState() {
    super.initState();

    service.setTracks(widget.tracks);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StellarMusicTrack?>(
      stream: service.currentTrackStream,
      initialData: service.currentTrack,
      builder: (context, trackSnapshot) {
        final track = trackSnapshot.data;

        if (track == null) {
          return const Scaffold(
            body: Center(
              child: Text('Şu anda parça çalmıyor'),
            ),
          );
        }

        return StreamBuilder<Duration>(
          stream: service.positionStream,
          initialData: service.position,
          builder: (context, positionSnapshot) {
            final position =
                positionSnapshot.data ?? Duration.zero;

            return Scaffold(
              body: StellarMusicBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          physics:
                              const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              StellarMusicCover(
                                artwork: track.artwork,
                                size: 300,
                              ),

                              const SizedBox(height: 28),

                              Text(
                                track.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                track.artist,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.68),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              if (track.album.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    track.album,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.40),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 25),

                              StellarLyricsOverlay(
                                track: track,
                                position: position,
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      _Controls(
                        service: service,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final StellarMusicService service;

  const _Controls({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.playingStream,
      initialData: service.isPlaying,
      builder: (context, playingSnapshot) {
        final playing = playingSnapshot.data ?? false;

        return StreamBuilder<StellarRepeatMode>(
          stream: service.repeatModeStream,
          initialData: service.repeatMode,
          builder: (context, repeatSnapshot) {
            final repeat =
                repeatSnapshot.data ?? service.repeatMode;

            return Column(
              children: [
                StreamBuilder<Duration>(
                  stream: service.positionStream,
                  initialData: service.position,
                  builder: (context, positionSnapshot) {
                    final position =
                        positionSnapshot.data ?? Duration.zero;

                    final duration = service.duration;

                    final max = duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0;

                    final value = position.inMilliseconds
                        .clamp(0, max.toInt())
                        .toDouble();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: Slider(
                        min: 0,
                        max: max,
                        value: value,
                        onChanged: (value) {
                          service.seek(
                            Duration(
                              milliseconds: value.toInt(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: service.previous,
                      icon: const StellarMusicIcon(
                        type:
                            StellarMusicIconType.previous,
                        size: 34,
                      ),
                    ),

                    const SizedBox(width: 18),

                    GestureDetector(
                      onTap: service.togglePlayPause,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: Center(
                          child: StellarMusicIcon(
                            type: playing
                                ? StellarMusicIconType.pause
                                : StellarMusicIconType.play,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    IconButton(
                      onPressed: service.next,
                      icon: const StellarMusicIcon(
                        type: StellarMusicIconType.next,
                        size: 34,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: service.cycleRepeatMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StellarMusicIcon(
                          type:
                              StellarMusicIconType.repeat,
                          size: 19,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          repeat.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
