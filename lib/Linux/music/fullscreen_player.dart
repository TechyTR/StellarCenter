import 'package:flutter/material.dart';

import 'lyrics_overlay.dart';
import 'music_background.dart';
import 'music_cover.dart';
import 'music_icon.dart';
import 'music_service.dart';
import 'music_track.dart';
import 'repeat_mode.dart';

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
                positionSnapshot.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: service.durationStream,
              initialData: service.duration,
              builder: (context, durationSnapshot) {
                final duration =
                    durationSnapshot.data ?? Duration.zero;

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

                        return Scaffold(
                          backgroundColor: Colors.transparent,
                          body: StellarMusicBackground(
                            artwork: track.artwork,
                            child: SafeArea(
                              child: Column(
                                children: [
                                  _TopBar(
                                    onClose: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  Expanded(
                                    child: LayoutBuilder(
                                      builder:
                                          (context, constraints) {
                                        final wide =
                                            constraints.maxWidth >=
                                                900;

                                        return SingleChildScrollView(
                                          padding:
                                              const EdgeInsets.fromLTRB(
                                            32,
                                            18,
                                            32,
                                            32,
                                          ),
                                          child: wide
                                              ? _WidePlayer(
                                                  track: track,
                                                  position:
                                                      position,
                                                  duration:
                                                      duration,
                                                  playing:
                                                      playing,
                                                  repeat:
                                                      repeat,
                                                  service:
                                                      service,
                                                )
                                              : _CompactPlayer(
                                                  track: track,
                                                  position:
                                                      position,
                                                  duration:
                                                      duration,
                                                  playing:
                                                      playing,
                                                  repeat:
                                                      repeat,
                                                  service:
                                                      service,
                                                ),
                                        );
                                      },
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

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TopBar({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Edge Player',
            onPressed: onClose,
            icon: const Icon(
              Icons.close_fullscreen_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Spacer(),
          const Text(
            'STELLAR MUSIC',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _WidePlayer extends StatelessWidget {
  final StellarMusicTrack track;
  final Duration position;
  final Duration duration;
  final bool playing;
  final StellarRepeatMode repeat;
  final StellarMusicService service;

  const _WidePlayer({
    required this.track,
    required this.position,
    required this.duration,
    required this.playing,
    required this.repeat,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1250,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 450,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(track.path),
                      child: Hero(
                        tag:
                            'stellar-cover-${track.path}',
                        child: StellarMusicCover(
                          artwork: track.artwork,
                          size: 390,
                          radius: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 48),

              Expanded(
                flex: 6,
                child: _InformationAndLyrics(
                  track: track,
                  position: position,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        _PlayerControlsArea(
          position: position,
          duration: duration,
          playing: playing,
          repeat: repeat,
          service: service,
        ),
      ],
    );
  }
}

class _CompactPlayer extends StatelessWidget {
  final StellarMusicTrack track;
  final Duration position;
  final Duration duration;
  final bool playing;
  final StellarRepeatMode repeat;
  final StellarMusicService service;

  const _CompactPlayer({
    required this.track,
    required this.position,
    required this.duration,
    required this.playing,
    required this.repeat,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 450,
          ),
          child: KeyedSubtree(
            key: ValueKey(track.path),
            child: Hero(
              tag: 'stellar-cover-${track.path}',
              child: StellarMusicCover(
                artwork: track.artwork,
                size: 310,
                radius: 30,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        _InformationAndLyrics(
          track: track,
          position: position,
        ),

        const SizedBox(height: 30),

        _PlayerControlsArea(
          position: position,
          duration: duration,
          playing: playing,
          repeat: repeat,
          service: service,
        ),
      ],
    );
  }
}

class _InformationAndLyrics extends StatelessWidget {
  final StellarMusicTrack track;
  final Duration position;

  const _InformationAndLyrics({
    required this.track,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Flexible(
              child: Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (track.verifiedArtist) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF2196F3),
                size: 19,
              ),
            ],
          ],
        ),

        const SizedBox(height: 5),

        Text(
          track.album,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 26),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 260,
            maxHeight: 390,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(.08),
            ),
          ),
          child: track.hasLyrics
              ? StellarLyricsOverlay(
                  track: track,
                  position: position,
                )
              : const Center(
                  child: Text(
                    'Şarkı sözü bulunamadı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PlayerControlsArea extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool playing;
  final StellarRepeatMode repeat;
  final StellarMusicService service;

  const _PlayerControlsArea({
    required this.position,
    required this.duration,
    required this.playing,
    required this.repeat,
    required this.service,
  });

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
    final max =
        duration.inMilliseconds > 0
            ? duration.inMilliseconds.toDouble()
            : 1;

    final current = position.inMilliseconds
        .clamp(0, duration.inMilliseconds)
        .toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1050,
      ),
      child: Column(
        children: [
          Slider(
            value: current,
            max: max,
            onChanged:
                duration.inMilliseconds > 0
                    ? (value) {
                        service.seek(
                          Duration(
                            milliseconds: value.round(),
                          ),
                        );
                      }
                    : null,
          ),

          Row(
            children: [
              Text(
                _time(position),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _time(duration),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _Controls(
            playing: playing,
            repeat: repeat,
            onPrevious: service.previous,
            onNext: service.next,
            onPlayPause: service.togglePlayPause,
            onRepeat: service.cycleRepeatMode,
          ),
        ],
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
  final VoidCallback onRepeat;

  const _Controls({
    required this.playing,
    required this.repeat,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Button(
          onTap: onRepeat,
          size: 46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
            type: StellarMusicIconType.previous,
            size: 26,
          ),
        ),

        const SizedBox(width: 14),

        _Button(
          onTap: onPlayPause,
          size: 72,
          filled: true,
          child: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 220,
            ),
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
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
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
