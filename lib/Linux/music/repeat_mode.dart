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
}
