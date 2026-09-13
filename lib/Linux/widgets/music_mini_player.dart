import 'dart:io';

import 'package:flutter/material.dart';

import '../services/music_library_service.dart';
import 'music_progress_bar.dart';

class MusicMiniPlayer extends StatelessWidget {
  final MusicTrack? track;
  final bool playing;
  final Duration position;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<Duration> onSeek;

  const MusicMiniPlayer({
    super.key,
    required this.track,
    required this.playing,
    required this.position,
    required this.duration,
    required this.onTap,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return const SizedBox.shrink();
    }

    final scheme =
        Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            12,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surface
                .withValues(alpha: 0.78),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: scheme.primary
                  .withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary
                    .withValues(alpha: 0.08),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: SizedBox(
                      width: 52,
                      height: 52,
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
                                color: scheme.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          track!.title,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          track!.artist,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onPrevious,
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                    ),
                  ),
                  Material(
                    color: scheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder:
                          const CircleBorder(),
                      onTap: onPlayPause,
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onNext,
                    icon: const Icon(
                      Icons.skip_next_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              MusicProgressBar(
                position: position,
                duration: duration,
                onSeek: onSeek,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
