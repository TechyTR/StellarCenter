import 'package:flutter/material.dart';

enum StellarRepeatMode {
  playlistOnce,
  songForever,
  albumOnce,
  albumForever,
}

extension StellarRepeatModeX on StellarRepeatMode {
  String get label {
    switch (this) {
      case StellarRepeatMode.playlistOnce:
        return '1×';

      case StellarRepeatMode.songForever:
        return '∞';

      case StellarRepeatMode.albumOnce:
        return 'ALB 1×';

      case StellarRepeatMode.albumForever:
        return 'ALB ∞';
    }
  }

  IconData get icon {
    switch (this) {
      case StellarRepeatMode.playlistOnce:
        return Icons.repeat;

      case StellarRepeatMode.songForever:
        return Icons.repeat_one;

      case StellarRepeatMode.albumOnce:
        return Icons.album;

      case StellarRepeatMode.albumForever:
        return Icons.album_outlined;
    }
  }
}
