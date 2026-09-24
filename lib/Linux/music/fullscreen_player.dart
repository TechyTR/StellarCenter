import 'package:flutter/material.dart';

import 'music_track.dart';
import 'music_background.dart';
import 'stellar_music_cover.dart';
import 'music_icon.dart';
import 'lyrics_overlay.dart';
import 'repeat_mode.dart';
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
  final StellarMusicService service =
      StellarMusicService.instance;

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
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Şu anda parça çalmıyor',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return StreamBuilder<Duration>(
          stream: service.positionStream,
          initialData: service.position,
          builder: (context, positionSnapshot) {
            final position =
                positionSnapshot.data ?? Duration.zero;

            return StellarMusicBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Kapat',
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics:
                              const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            8,
                            24,
                            24,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),

                              Hero(
                                tag:
                                    'stellar-cover-${track.path}',
                                child: StellarMusicCover(
                                  artwork: track.artwork,
                                  size: 300,
                                  radius: 28,
                                ),
                              ),

                              const SizedBox(height: 28),

                              Text(
                                track.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                track.artist.isEmpty
                                    ? 'Bilinmeyen sanatçı'
                                    : track.artist,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                ),
                              ),

                              if (track.album.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    track.album,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 25),

                              StellarLyricsOverlay(
                                track: track,
                                position: position,
                              ),
                            ],
                          ),
                        ),
                      ),

                      _PlayerControls(
                        service: service,
                      ),

                      const SizedBox(height: 18),
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

class _PlayerControls extends StatelessWidget {
  final StellarMusicService service;

  const _PlayerControls({
    required this.service,
  });

  String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds =
        duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.playingStream,
      initialData: service.isPlaying,
      builder: (context, playingSnapshot) {
        final playing =
            playingSnapshot.data ?? false;

        return StreamBuilder<StellarRepeatMode>(
          stream: service.repeatModeStream,
          initialData: service.repeatMode,
          builder: (context, repeatSnapshot) {
            final repeat =
                repeatSnapshot.data ??
                    service.repeatMode;

            return Column(
              children: [
                StreamBuilder<Duration>(
                  stream: service.positionStream,
                  initialData: service.position,
                  builder: (
                    context,
                    positionSnapshot,
                  ) {
                    final position =
                        positionSnapshot.data ??
                            Duration.zero;

                    final duration =
                        service.duration;

                    final max =
                        duration.inMilliseconds > 0
                            ? duration.inMilliseconds
                                .toDouble()
                            : 1.0;

                    final value =
                        position.inMilliseconds
                            .clamp(
                              0,
                              max.toInt(),
                            )
                            .toDouble();

                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: max,
                          value: value,
                          onChanged: (value) {
                            service.seek(
                              Duration(
                                milliseconds:
                                    value.toInt(),
                              ),
                            );
                          },
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 28,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                _format(position),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _format(duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: service.previous,
                      child: const StellarMusicIcon(
                        type:
                            StellarMusicIconType.previous,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 28),

                    GestureDetector(
                      onTap:
                          service.togglePlayPause,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withValues(alpha: 0.14),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.20),
                          ),
                        ),
                        child: Center(
                          child: StellarMusicIcon(
                            type: playing
                                ? StellarMusicIconType.pause
                                : StellarMusicIconType.play,
                            size: 31,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 28),

                    GestureDetector(
                      onTap: service.next,
                      child: const StellarMusicIcon(
                        type: StellarMusicIconType.next,
                        size: 36,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: service.cycleRepeatMode,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const StellarMusicIcon(
                          type:
                              StellarMusicIconType.repeat,
                          size: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          repeat.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
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
