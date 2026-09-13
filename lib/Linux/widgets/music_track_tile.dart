import 'dart:io';

import 'package:flutter/material.dart';

import '../services/music_library_service.dart';
import '../services/music_repeat_service.dart';
import 'music_repeat_button.dart';

class MusicTrackTile extends StatelessWidget {
  final MusicTrack track;
  final bool playing;
  final RepeatMode repeatMode;
  final VoidCallback onTap;
  final VoidCallback onRepeat;

  const MusicTrackTile({
    super.key,
    required this.track,
    required this.playing,
    required this.repeatMode,
    required this.onTap,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: playing
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surface.withValues(alpha: 0.48),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: playing
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.onSurface
                  .withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: track.cover != null
                      ? Image.file(
                          track.cover!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: scheme
                              .surfaceContainerHighest,
                          child: Icon(
                            Icons.music_note,
                            color: scheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                              color: playing
                                  ? scheme.primary
                                  : null,
                            ),
                          ),
                        ),
                        if (track.verified)
                          Padding(
                            padding:
                                const EdgeInsets.only(
                              left: 6,
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 17,
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${track.artist} • ${track.album}',
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
              MusicRepeatButton(
                mode: repeatMode,
                onPressed: onRepeat,
              ),
              IconButton(
                tooltip: playing
                    ? 'Duraklat'
                    : 'Oynat',
                onPressed: onTap,
                icon: Icon(
                  playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
