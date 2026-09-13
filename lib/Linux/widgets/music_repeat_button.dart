import 'package:flutter/material.dart';

import '../services/music_repeat_service.dart';

class MusicRepeatButton extends StatelessWidget {
  final RepeatMode mode;
  final VoidCallback onPressed;

  const MusicRepeatButton({
    super.key,
    required this.mode,
    required this.onPressed,
  });

  IconData get icon {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat;

      case RepeatMode.once:
        return Icons.repeat_one;

      case RepeatMode.infinite:
        return Icons.all_inclusive;
    }
  }

  String get tooltip {
    switch (mode) {
      case RepeatMode.off:
        return 'Tekrar kapalı';

      case RepeatMode.once:
        return 'Bir kez tekrar';

      case RepeatMode.infinite:
        return 'Sonsuz tekrar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final active =
        mode != RepeatMode.off;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: active
              ? colorScheme.primary
                  .withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? colorScheme.primary
                    .withValues(alpha: 0.45)
                : colorScheme.onSurface
                    .withValues(alpha: 0.12),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 220),
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: active
                  ? colorScheme.primary
                  : colorScheme.onSurface
                      .withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
