import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/music_library_service.dart';
import 'music_now_playing_panel.dart';

class MusicEdgePanel extends StatefulWidget {
  final MusicTrack? track;
  final bool playing;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<Duration> onSeek;
  final Widget lyrics;

  const MusicEdgePanel({
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
  State<MusicEdgePanel> createState() =>
      _MusicEdgePanelState();
}

class _MusicEdgePanelState
    extends State<MusicEdgePanel> {
  bool _expanded = false;

  double _dragStart = 0;

  void _handleDragStart(
    DragStartDetails details,
  ) {
    _dragStart = details.globalPosition.dx;
  }

  void _handleDragEnd(
    DragEndDetails details,
  ) {
    final velocity =
        details.velocity.pixelsPerSecond.dx;

    if (velocity < -300) {
      setState(() {
        _expanded = true;
      });
      return;
    }

    if (velocity > 300) {
      setState(() {
        _expanded = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final panelWidth = _expanded
        ? size.width
        : 390.0.clamp(
            300.0,
            size.width,
          );

    return Stack(
      children: [
        AnimatedPositioned(
          duration:
              const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          top: 12,
          bottom: 12,
          right: 0,
          width: panelWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                _expanded ? 0 : 30,
              ),
              bottomLeft: Radius.circular(
                _expanded ? 0 : 30,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 30,
                sigmaY: 30,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.84),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _expanded ? 32 : 18,
                      right: _expanded ? 32 : 18,
                      top: 18,
                      bottom: 18,
                    ),
                    child: MusicNowPlayingPanel(
                      track: widget.track,
                      playing: widget.playing,
                      position: widget.position,
                      duration: widget.duration,
                      onPlayPause:
                          widget.onPlayPause,
                      onPrevious:
                          widget.onPrevious,
                      onNext: widget.onNext,
                      onSeek: widget.onSeek,
                      lyrics: widget.lyrics,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration:
              const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          top: size.height / 2 - 50,
          right: _expanded
              ? size.width - 30
              : panelWidth - 7,
          child: GestureDetector(
            onHorizontalDragStart:
                _handleDragStart,
            onHorizontalDragEnd:
                _handleDragEnd,
            child: Container(
              width: 14,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.20),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Center(
                child: Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.75),
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
