import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RepeatMode {
  off,
  once,
  infinite,
}

class MusicRepeatService extends ChangeNotifier {
  RepeatMode _albumMode = RepeatMode.off;

  final Map<String, RepeatMode> _trackModes = {};

  RepeatMode get albumMode => _albumMode;

  RepeatMode trackMode(String path) {
    return _trackModes[path] ?? RepeatMode.off;
  }

  void cycleAlbum() {
    switch (_albumMode) {
      case RepeatMode.off:
        _albumMode = RepeatMode.once;
        break;

      case RepeatMode.once:
        _albumMode = RepeatMode.infinite;
        break;

      case RepeatMode.infinite:
        _albumMode = RepeatMode.off;
        break;
    }

    notifyListeners();
  }

  void cycleTrack(String path) {
    final current =
        _trackModes[path] ?? RepeatMode.off;

    switch (current) {
      case RepeatMode.off:
        _trackModes[path] = RepeatMode.once;
        break;

      case RepeatMode.once:
        _trackModes[path] =
            RepeatMode.infinite;
        break;

      case RepeatMode.infinite:
        _trackModes[path] = RepeatMode.off;
        break;
    }

    notifyListeners();
  }

  void clearTrack(String path) {
    _trackModes.remove(path);
    notifyListeners();
  }

  IconData get albumIcon {
    switch (_albumMode) {
      case RepeatMode.off:
        return Icons.repeat;

      case RepeatMode.once:
        return Icons.repeat_one;

      case RepeatMode.infinite:
        return Icons.all_inclusive;
    }
  }

  IconData trackIcon(String path) {
    switch (trackMode(path)) {
      case RepeatMode.off:
        return Icons.repeat;

      case RepeatMode.once:
        return Icons.repeat_one;

      case RepeatMode.infinite:
        return Icons.all_inclusive;
    }
  }

  bool get albumRepeating =>
      _albumMode != RepeatMode.off;

  bool trackRepeating(String path) =>
      trackMode(path) != RepeatMode.off;
}
