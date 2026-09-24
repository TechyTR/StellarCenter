import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'music_track.dart';
import 'repeat_mode.dart';

class StellarMusicService {
  StellarMusicService._();

  static final StellarMusicService instance =
      StellarMusicService._();

  final AudioPlayer player = AudioPlayer();

  final _trackController =
      StreamController<StellarMusicTrack?>.broadcast();

  final _positionController =
      StreamController<Duration>.broadcast();

  final _durationController =
      StreamController<Duration>.broadcast();

  final _playingController =
      StreamController<bool>.broadcast();

  final _repeatController =
      StreamController<StellarRepeatMode>.broadcast();

  final List<StellarMusicTrack> _tracks = [];

  StellarMusicTrack? _currentTrack;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  int _currentIndex = -1;

  bool _playing = false;
  bool _initialized = false;
  bool _operationInProgress = false;

  StellarRepeatMode _repeatMode =
      StellarRepeatMode.playlistOnce;

  Stream<StellarMusicTrack?>
      get currentTrackStream =>
          _trackController.stream;

  Stream<Duration> get positionStream =>
      _positionController.stream;

  Stream<Duration> get durationStream =>
      _durationController.stream;

  Stream<bool> get playingStream =>
      _playingController.stream;

  Stream<StellarRepeatMode>
      get repeatModeStream =>
          _repeatController.stream;

  StellarMusicTrack? get currentTrack =>
      _currentTrack;

  Duration get position => _position;

  Duration get duration => _duration;

  bool get isPlaying => _playing;

  int get currentIndex => _currentIndex;

  StellarRepeatMode get repeatMode =>
      _repeatMode;

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    player.onPositionChanged.listen(
      (value) {
        _position = value;
        _positionController.add(value);
      },
    );

    player.onDurationChanged.listen(
      (value) {
        _duration = value;
        _durationController.add(value);
      },
    );

    player.onPlayerStateChanged.listen(
      (state) {
        final value =
            state == PlayerState.playing;

        if (_playing == value) return;

        _playing = value;
        _playingController.add(value);
      },
    );

    player.onPlayerComplete.listen(
      (_) => _handleComplete(),
    );
  }

  void setTracks(
    List<StellarMusicTrack> tracks,
  ) {
    final currentPath =
        _currentTrack?.path;

    _tracks
      ..clear()
      ..addAll(tracks);

    if (currentPath == null) return;

    final index = _tracks.indexWhere(
      (track) => track.path == currentPath,
    );

    if (index >= 0) {
      _currentIndex = index;
      _currentTrack = _tracks[index];
    }
  }

  Future<void> playIndex(int index) async {
    if (_operationInProgress ||
        index < 0 ||
        index >= _tracks.length) {
      return;
    }

    _operationInProgress = true;

    try {
      final track = _tracks[index];

      _currentIndex = index;
      _currentTrack = track;
      _position = Duration.zero;
      _duration = Duration.zero;

      _trackController.add(track);
      _positionController.add(Duration.zero);
      _durationController.add(Duration.zero);

      await player.stop();

      await player.play(
        DeviceFileSource(track.path),
      );
    } finally {
      _operationInProgress = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (_playing) {
      await player.pause();
      return;
    }

    if (_currentTrack != null) {
      await player.resume();
    }
  }

  Future<void> pause() => player.pause();

  Future<void> resume() => player.resume();

  Future<void> stop() async {
    await player.stop();

    _position = Duration.zero;

    if (_playing) {
      _playing = false;
      _playingController.add(false);
    }

    _positionController.add(Duration.zero);
  }

  Future<void> seek(Duration position) {
    final safe = position < Duration.zero
        ? Duration.zero
        : position > _duration
            ? _duration
            : position;

    return player.seek(safe);
  }

  Future<void> next() async {
    if (_tracks.isEmpty ||
        _currentIndex < 0) {
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    final indexes =
        _activeIndexes();

    if (indexes.isEmpty) return;

    final local =
        indexes.indexOf(_currentIndex);

    if (local < 0) return;

    if (local + 1 < indexes.length) {
      await playIndex(indexes[local + 1]);
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.albumForever) {
      await playIndex(indexes.first);
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.albumOnce) {
      await stop();
      return;
    }

    if (_currentIndex + 1 <
        _tracks.length) {
      await playIndex(_currentIndex + 1);
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (_currentIndex < 0) return;

    if (_position >
        const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    final indexes =
        _activeIndexes();

    if (indexes.isEmpty) return;

    final local =
        indexes.indexOf(_currentIndex);

    if (local > 0) {
      await playIndex(indexes[local - 1]);
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.albumForever) {
      await playIndex(indexes.last);
      return;
    }

    if (_repeatMode ==
            StellarRepeatMode.playlistOnce &&
        _currentIndex > 0) {
      await playIndex(_currentIndex - 1);
    }
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case StellarRepeatMode.playlistOnce:
        _repeatMode =
            StellarRepeatMode.songForever;
        break;

      case StellarRepeatMode.songForever:
        _repeatMode =
            StellarRepeatMode.albumOnce;
        break;

      case StellarRepeatMode.albumOnce:
        _repeatMode =
            StellarRepeatMode.albumForever;
        break;

      case StellarRepeatMode.albumForever:
        _repeatMode =
            StellarRepeatMode.playlistOnce;
        break;
    }

    _repeatController.add(_repeatMode);
  }

  List<int> _activeIndexes() {
    if (_currentIndex < 0 ||
        _currentIndex >= _tracks.length) {
      return const [];
    }

    final current =
        _tracks[_currentIndex];

    if (_repeatMode ==
            StellarRepeatMode.albumOnce ||
        _repeatMode ==
            StellarRepeatMode.albumForever) {
      return [
        for (var i = 0;
            i < _tracks.length;
            i++)
          if (_tracks[i].artist ==
                  current.artist &&
              _tracks[i].album ==
                  current.album)
            i,
      ];
    }

    return [
      for (var i = 0;
          i < _tracks.length;
          i++)
        i,
    ];
  }

  Future<void> _handleComplete() async {
    await next();
  }
}
