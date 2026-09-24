import 'package:flutter/material.dart';

import 'lyrics_overlay.dart';
import 'music_background.dart';
import 'music_icon.dart';
import 'music_track.dart';
import 'repeat_mode.dart';
import 'stellar_music_cover.dart';
import 'stellar_music_service.dart';

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
  final StellarMusicService service =
      StellarMusicService.instance;

  @override
  void initState() {
    super.initState();

    service.initialize();

    if (widget.tracks.isNotEmpty) {
      service.setTracks(widget.tracks);
    }
  }

  String _format(Duration value) {
    final minutes =
        value.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        value.inSeconds
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
    return Material(
      color: Colors.transparent,
      child: StreamBuilder<
          StellarMusicTrack?>(
        stream:
            service.currentTrackStream,
        initialData:
            service.currentTrack,
        builder: (
          context,
          trackSnapshot,
        ) {
          final track =
              trackSnapshot.data;

          if (track == null) {
            return const Scaffold(
              backgroundColor:
                  Colors.black,
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
            builder: (
              context,
              positionSnapshot,
            ) {
              final position =
                  positionSnapshot.data ??
                  Duration.zero;

              return StreamBuilder<Duration>(
                stream:
                    service.durationStream,
                initialData:
                    service.duration,
                builder: (
                  context,
                  durationSnapshot,
                ) {
                  final duration =
                      durationSnapshot.data ??
                      Duration.zero;

                  return StreamBuilder<bool>(
                    stream:
                        service.playingStream,
                    initialData:
                        service.isPlaying,
                    builder: (
                      context,
                      playingSnapshot,
                    ) {
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
                              child:
                                  SafeArea(
                                child:
                                    Column(
                                  children: [
                                    _TopBar(
                                      onClose:
                                          () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                    ),
                                    Expanded(
                                      child:
                                          SingleChildScrollView(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              28,
                                          vertical:
                                              20,
                                        ),
                                        child:
                                            Column(
                                          children: [
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
                                                    28,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  26,
                                            ),
                                            Text(
                                              track.title,
                                              textAlign:
                                                  TextAlign.center,
                                              maxLines:
                                                  2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize:
                                                    25,
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  7,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Flexible(
                                                  child:
                                                      Text(
                                                    track.artist,
                                                    maxLines:
                                                        1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.white.withOpacity(0.72),
                                                      fontSize:
                                                          16,
                                                    ),
                                                  ),
                                                ),
                                                if (track
                                                    .verifiedArtist) ...[
                                                  const SizedBox(
                                                    width:
                                                        7,
                                                  ),
                                                  Container(
                                                    width:
                                                        17,
                                                    height:
                                                        17,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      color:
                                                          Colors.white,
                                                    ),
                                                    child:
                                                        const Icon(
                                                      Icons.check,
                                                      size:
                                                          12,
                                                      color:
                                                          Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(
                                              height:
                                                  4,
                                            ),
                                            Text(
                                              track.album,
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white.withOpacity(0.42),
                                                fontSize:
                                                    13,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  25,
                                            ),
                                            StellarLyricsOverlay(
                                              track:
                                                  track,
                                              position:
                                                  position,
                                            ),
                                            const SizedBox(
                                              height:
                                                  22,
                                            ),
                                            _ProgressBar(
                                              position:
                                                  position,
                                              duration:
                                                  duration,
                                              onChanged:
                                                  (value) {
                                                service.seek(
                                                  value,
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              height:
                                                  4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _format(
                                                    position,
                                                  ),
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.white.withOpacity(0.45),
                                                    fontSize:
                                                        11,
                                                  ),
                                                ),
                                                Text(
                                                  _format(
                                                    duration,
                                                  ),
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.white.withOpacity(0.45),
                                                    fontSize:
                                                        11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height:
                                                  14,
                                            ),
                                            _Controls(
                                              playing:
                                                  playing,
                                              repeat:
                                                  repeat,
                                              onPrevious:
                                                  service.previous,
                                              onNext:
                                                  service.next,
                                              onPlayPause:
                                                  service.togglePlayPause,
                                              onStop:
                                                  service.stop,
                                              onRepeat:
                                                  service.cycleRepeatMode,
                                            ),
                                            const SizedBox(
                                              height:
                                                  30,
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
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TopBar({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 16),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Şimdi Çalıyor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 54,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  const _ProgressBar({
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final max =
        duration.inMilliseconds > 0
            ? duration.inMilliseconds
                .toDouble()
            : 1.0;

    final value =
        position.inMilliseconds
            .clamp(0, max.toInt())
            .toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape:
            const RoundSliderThumbShape(
          enabledThumbRadius: 5,
        ),
        overlayShape:
            const RoundSliderOverlayShape(
          overlayRadius: 13,
        ),
        activeTrackColor:
            Colors.white,
        inactiveTrackColor:
            Colors.white24,
        thumbColor:
            Colors.white,
        overlayColor:
            Colors.white12,
      ),
      child: Slider(
        min: 0,
        max: max,
        value: value,
        onChanged: (value) {
          onChanged(
            Duration(
              milliseconds:
                  value.round(),
            ),
          );
        },
      ),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            _RoundButton(
              onTap: onRepeat,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const StellarMusicIcon(
                    type:
                        StellarMusicIconType.repeat,
                    size: 23,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    repeat.label,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _RoundButton(
              onTap: onPrevious,
              size: 54,
              child:
                  const StellarMusicIcon(
                type:
                    StellarMusicIconType.previous,
                size: 27,
              ),
            ),
            const SizedBox(width: 16),
            _RoundButton(
              onTap: onPlayPause,
              size: 70,
              filled: true,
              child: StellarMusicIcon(
                type: playing
                    ? StellarMusicIconType.pause
                    : StellarMusicIconType.play,
                size: 34,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            _RoundButton(
              onTap: onNext,
              size: 54,
              child:
                  const StellarMusicIcon(
                type:
                    StellarMusicIconType.next,
                size: 27,
              ),
            ),
            const SizedBox(width: 20),
            _RoundButton(
              onTap: onStop,
              child: const Icon(
                Icons.stop_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final bool filled;

  const _RoundButton({
    required this.onTap,
    required this.child,
    this.size = 44,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? Colors.white
                : Colors.white.withOpacity(
                    0.10,
                  ),
            border: filled
                ? null
                : Border.all(
                    color: Colors.white
                        .withOpacity(0.10),
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
