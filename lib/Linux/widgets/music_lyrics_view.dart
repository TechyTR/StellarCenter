import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/lrc_service.dart';
import '../services/music_sync_service.dart';

class MusicLyricsView extends StatefulWidget {
  final File? file;
  final Duration position;
  final String trackPath;

  const MusicLyricsView({
    super.key,
    required this.file,
    required this.position,
    required this.trackPath,
  });

  @override
  State<MusicLyricsView> createState() =>
      _MusicLyricsViewState();
}

class _MusicLyricsViewState
    extends State<MusicLyricsView> {
  final MusicSyncService _syncService =
      const MusicSyncService();

  List<LyricLine> _lines = const [];

  Duration _offset = Duration.zero;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void didUpdateWidget(
    covariant MusicLyricsView oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.file?.path !=
        widget.file?.path) {
      _loadLyrics();
    }
  }

  Future<void> _loadLyrics() async {
    final file = widget.file;

    if (file == null ||
        !await file.exists()) {
      if (!mounted) return;

      setState(() {
        _lines = const [];
        _loading = false;
      });

      return;
    }

    try {
      final content = await file.readAsString();

      final lines = LrcService.parse(content);

      final offset =
          await _syncService.getOffset(
        widget.trackPath,
      );

      if (!mounted) return;

      setState(() {
        _lines = lines;
        _offset = offset;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _lines = const [];
        _loading = false;
      });
    }
  }

  Future<void> _changeOffset(
    Duration amount,
  ) async {
    final next = _offset + amount;

    await _syncService.setOffset(
      widget.trackPath,
      next,
    );

    if (!mounted) return;

    setState(() {
      _offset = next;
    });
  }

  int get _currentIndex {
    return LrcService.currentIndex(
      _lines,
      widget.position,
      offset: _offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = _currentIndex;

    final previous =
        current > 0 ? _lines[current - 1] : null;

    final active =
        current >= 0 &&
                current < _lines.length
            ? _lines[current]
            : null;

    final next =
        current + 1 < _lines.length
            ? _lines[current + 1]
            : null;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Senkronizasyonu geri al',
              onPressed: () {
                _changeOffset(
                  const Duration(
                    milliseconds: -500,
                  ),
                );
              },
              icon: const Icon(
                Icons.keyboard_double_arrow_left,
              ),
            ),
            Text(
              '${_offset.inMilliseconds} ms',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              tooltip: 'Senkronizasyonu ileri al',
              onPressed: () {
                _changeOffset(
                  const Duration(
                    milliseconds: 500,
                  ),
                );
              },
              icon: const Icon(
                Icons.keyboard_double_arrow_right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 420),
            transitionBuilder:
                (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slide,
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(current),
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (previous != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      previous.text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.42),
                      ),
                    ),
                  ),
                AnimatedScale(
                  scale: active == null ? 1 : 1.03,
                  duration:
                      const Duration(milliseconds: 350),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Text(
                      active?.text ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),
                ),
                if (next != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      next.text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.42),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
