import 'dart:io';

import 'package:flutter/material.dart';

import '../services/music_library_service.dart';
import 'music_progress_bar.dart';

class MusicNowPlayingPanel
    extends StatelessWidget {
  final MusicTrack? track;
  final bool playing;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<Duration> onSeek;
  final Widget lyrics;

  const MusicNowPlayingPanel({
    super.key,
    required this.track,
    required this.playing,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSeek,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    if (track == null) {
      return Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 60,
          color: scheme.primary
              .withValues(alpha: 0.35),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(26),
          child: SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 1,
              child: track!.cover != null
                  ? Image.file(
                      track!.cover!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: scheme
                          .surfaceContainerHighest,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 80,
                        color: scheme.primary,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          track!.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${track!.artist} • ${track!.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface
                .withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 10),
        MusicProgressBar(
          position: position,
          duration: duration,
          onSeek: onSeek,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(
                Icons.skip_previous_rounded,
              ),
              iconSize: 34,
            ),
            const SizedBox(width: 8),
            Material(
              color: scheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder:
                    const CircleBorder(),
                onTap: onPlayPause,
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: scheme.onPrimary,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onNext,
              icon: const Icon(
                Icons.skip_next_rounded,
              ),
              iconSize: 34,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: lyrics,
        ),
      ],
    );
  }
}
