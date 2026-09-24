import 'package:flutter/material.dart';

import 'lyrics_overlay.dart';
import 'music_background.dart';
import 'music_icon.dart';
import 'music_track.dart';
import 'repeat_mode.dart';
import 'music_cover.dart';
import 'music_service.dart';

class StellarFullscreenPlayer
    extends StatefulWidget {
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
  final service =
      StellarMusicService.instance;

  @override
  void initState() {
    super.initState();

    service.initialize();
    service.setTracks(widget.tracks);
  }

  String _time(Duration value) {
    final minutes = value.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = value.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (value.inHours > 0) {
      return '${value.inHours}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
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
                'Müzik seçilmedi',
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
                positionSnapshot.data ??
                    Duration.zero;

            return StreamBuilder<Duration>(
              stream: service.durationStream,
              initialData: service.duration,
              builder:
                  (context, durationSnapshot) {
                final duration =
                    durationSnapshot.data ??
                        Duration.zero;

                return StreamBuilder<bool>(
                  stream: service.playingStream,
                  initialData: service.isPlaying,
                  builder:
                      (context, playingSnapshot) {
                    final playing =
                        playingSnapshot.data ??
                            false;

                    return StreamBuilder<
                        StellarRepeatMode>(
                      stream:
                          service.repeatModeStream,
                      initialData:
                          service.repeatMode,
                      builder: (
                        context,
                        repeatSnapshot,
                      ) {
                        final repeat =
                            repeatSnapshot.data ??
                                service.repeatMode;

                        return Scaffold(
                          backgroundColor:
                              Colors.transparent,
                          body:
                              StellarMusicBackground(
                            child: SafeArea(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          },
                                          icon:
                                              const Icon(
                                            Icons
                                                .keyboard_arrow_down_rounded,
                                            color:
                                                Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'STELLAR MUSIC',
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .white
                                                .withOpacity(
                                                    .65),
                                            fontSize: 11,
                                            letterSpacing:
                                                2.2,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        const SizedBox(
                                          width: 48,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child:
                                        SingleChildScrollView(
                                      padding:
                                          const EdgeInsets
                                              .fromLTRB(
                                        28,
                                        12,
                                        28,
                                        30,
                                      ),
                                      child: Column(
                                        children: [
                                          AnimatedSwitcher(
                                            duration:
                                                const Duration(
                                              milliseconds:
                                                  450,
                                            ),
                                            switchInCurve:
                                                Curves
                                                    .easeOutCubic,
                                            switchOutCurve:
                                                Curves
                                                    .easeInCubic,
                                            child: KeyedSubtree(
                                              key: ValueKey(
                                                track.path,
                                              ),
                                              child:
                                                  Hero(
                                                tag:
                                                    'stellar-cover-${track.path}',
                                                child:
                                                    StellarMusicCover(
                                                  artwork:
                                                      track.artwork,
                                                  size:
                                                      310,
                                                  radius:
                                                      30,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 26,
                                          ),
                                          Text(
                                            track.title,
                                            textAlign:
                                                TextAlign
                                                    .center,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize:
                                                  25,
                                              fontWeight:
                                                  FontWeight
                                                      .w800,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            track.artist,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (track
                                              .verifiedArtist)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .verified_rounded,
                                                color:
                                                    Colors.blue,
                                                size: 18,
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          if (track.lyricsPath !=
                                              null)
                                            StellarLyricsOverlay(
                                              track: track,
                                              position:
                                                  position,
                                            ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          SliderTheme(
                                            data:
                                                SliderTheme.of(
                                              context,
                                            ).copyWith(
                                              trackHeight:
                                                  4,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                enabledThumbRadius:
                                                    6,
                                              ),
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                overlayRadius:
                                                    16,
                                              ),
                                            ),
                                            child:
                                                Slider(
                                              value:
                                                  duration.inMilliseconds >
                                                          0
                                                      ? position.inMilliseconds.clamp(
                                                          0,
                                                          duration.inMilliseconds,
                                                        ).toDouble()
                                                      : 0,
                                              max:
                                                  duration.inMilliseconds >
                                                          0
                                                      ? duration.inMilliseconds.toDouble()
                                                      : 1,
                                              onChanged:
                                                  duration.inMilliseconds >
                                                          0
                                                      ? (value) {
                                                          service.seek(
                                                            Duration(
                                                              milliseconds:
                                                                  value.round(),
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                _time(
                                                  position,
                                                ),
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white60,
                                                  fontSize:
                                                      12,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                _time(
                                                  duration,
                                                ),
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white60,
                                                  fontSize:
                                                      12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          _Controls(
                                            playing:
                                                playing,
                                            repeat:
                                                repeat,
                                            onPrevious:
                                                service
                                                    .previous,
                                            onNext:
                                                service
                                                    .next,
                                            onPlayPause:
                                                service
                                                    .togglePlayPause,
                                            onStop:
                                                service
                                                    .stop,
                                            onRepeat:
                                                service
                                                    .cycleRepeatMode,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final bool playing;
  final StellarRepeatMode repeat;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onRepeat;

  const _Controls({
    required this.playing,
    required this.repeat,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
    required this.onStop,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        _Button(
          onTap: onRepeat,
          size: 46,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.repeat_rounded,
                color: Colors.white,
                size: 21,
              ),
              Text(
                repeat.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _Button(
          onTap: onPrevious,
          size: 54,
          child: const StellarMusicIcon(
            type:
                StellarMusicIconType.previous,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        _Button(
          onTap: onPlayPause,
          size: 72,
          filled: true,
          child: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 220),
            child: StellarMusicIcon(
              key: ValueKey(playing),
              type: playing
                  ? StellarMusicIconType.pause
                  : StellarMusicIconType.play,
              size: 34,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 14),
        _Button(
          onTap: onNext,
          size: 54,
          child: const StellarMusicIcon(
            type: StellarMusicIconType.next,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        _Button(
          onTap: onStop,
          size: 46,
          child: const Icon(
            Icons.stop_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final bool filled;

  const _Button({
    required this.onTap,
    required this.child,
    this.size = 46,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(100),
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? Colors.white
                : Colors.white.withOpacity(.10),
            border: Border.all(
              color: Colors.white.withOpacity(
                filled ? 0 : .12,
              ),
            ),
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
