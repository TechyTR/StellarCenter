import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'music_track.dart';
import 'repeat_mode.dart';

class StellarMusicService {
  StellarMusicService._();

  static final StellarMusicService instance =
      StellarMusicService._();

  final AudioPlayer player = AudioPlayer();

  final StreamController<StellarMusicTrack?>
      _trackController =
      StreamController<StellarMusicTrack?>.broadcast();

  final StreamController<Duration>
      _positionController =
      StreamController<Duration>.broadcast();

  final StreamController<Duration>
      _durationController =
      StreamController<Duration>.broadcast();

  final StreamController<bool>
      _playingController =
      StreamController<bool>.broadcast();

  final StreamController<StellarRepeatMode>
      _repeatController =
      StreamController<StellarRepeatMode>.broadcast();

  final List<StellarMusicTrack> _tracks = [];

  int _currentIndex = -1;

  StellarMusicTrack? _currentTrack;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _playing = false;
  bool _initialized = false;

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

  StellarRepeatMode get repeatMode =>
      _repeatMode;

  List<StellarMusicTrack> get tracks =>
      List.unmodifiable(_tracks);

  int get currentIndex => _currentIndex;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    player.onPositionChanged.listen(
      (position) {
        _position = position;
        _positionController.add(position);
      },
    );

    player.onDurationChanged.listen(
      (duration) {
        _duration = duration;
        _durationController.add(duration);
      },
    );

    player.onPlayerStateChanged.listen(
      (state) {
        _playing =
            state == PlayerState.playing;

        _playingController.add(_playing);
      },
    );

    player.onPlayerComplete.listen(
      (_) {
        _handleSongComplete();
      },
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

    if (currentPath == null) {
      return;
    }

    final index = _tracks.indexWhere(
      (track) =>
          track.path == currentPath,
    );

    if (index >= 0) {
      _currentIndex = index;
      _currentTrack = _tracks[index];
    }
  }

  Future<void> playIndex(
    int index,
  ) async {
    if (index < 0 ||
        index >= _tracks.length) {
      return;
    }

    final track = _tracks[index];

    _currentIndex = index;
    _currentTrack = track;

    _position = Duration.zero;
    _duration = Duration.zero;

    _trackController.add(track);
    _positionController.add(
      Duration.zero,
    );
    _durationController.add(
      Duration.zero,
    );

    await player.stop();

    await player.play(
      DeviceFileSource(track.path),
    );
  }

  Future<void> play(
    StellarMusicTrack track,
  ) async {
    final index = _tracks.indexWhere(
      (item) =>
          item.path == track.path,
    );

    if (index >= 0) {
      await playIndex(index);
      return;
    }

    _currentTrack = track;
    _currentIndex = -1;

    _trackController.add(track);

    await player.stop();

    await player.play(
      DeviceFileSource(track.path),
    );
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    await player.resume();
  }

  Future<void> togglePlayPause() async {
    if (_playing) {
      await pause();
      return;
    }

    if (_currentTrack != null) {
      await resume();
    }
  }

  Future<void> seek(
    Duration position,
  ) async {
    await player.seek(position);
  }

  Future<void> stop() async {
    await player.stop();

    _playing = false;
    _position = Duration.zero;

    _playingController.add(false);
    _positionController.add(
      Duration.zero,
    );
  }

  Future<void> next() async {
    if (_tracks.isEmpty ||
        _currentIndex < 0) {
      return;
    }

    switch (_repeatMode) {
      case StellarRepeatMode.playlistOnce:
      case StellarRepeatMode.songForever:
        final nextIndex =
            _currentIndex + 1;

        if (nextIndex >= _tracks.length) {
          if (_repeatMode ==
              StellarRepeatMode.songForever) {
            await playIndex(
              _currentIndex,
            );
          }

          return;
        }

        await playIndex(nextIndex);
        return;

      case StellarRepeatMode.albumOnce:
      case StellarRepeatMode.albumForever:
        final indexes =
            _albumIndexes();

        if (indexes.isEmpty) {
          return;
        }

        final current =
            indexes.indexOf(
          _currentIndex,
        );

        if (current < 0) {
          await playIndex(
            indexes.first,
          );
          return;
        }

        final next =
            current + 1;

        if (next >= indexes.length) {
          if (_repeatMode ==
              StellarRepeatMode.albumForever) {
            await playIndex(
              indexes.first,
            );
          }

          return;
        }

        await playIndex(
          indexes[next],
        );
        return;
    }
  }

  Future<void> previous() async {
    if (_tracks.isEmpty ||
        _currentIndex < 0) {
      return;
    }

    if (_position >
        const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    switch (_repeatMode) {
      case StellarRepeatMode.playlistOnce:
        if (_currentIndex > 0) {
          await playIndex(
            _currentIndex - 1,
          );
        }
        return;

      case StellarRepeatMode.songForever:
        await playIndex(
          _currentIndex,
        );
        return;

      case StellarRepeatMode.albumOnce:
      case StellarRepeatMode.albumForever:
        final indexes =
            _albumIndexes();

        if (indexes.isEmpty) {
          return;
        }

        final current =
            indexes.indexOf(
          _currentIndex,
        );

        if (current > 0) {
          await playIndex(
            indexes[current - 1],
          );
        } else if (
            _repeatMode ==
            StellarRepeatMode.albumForever) {
          await playIndex(
            indexes.last,
          );
        }

        return;
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

    _repeatController.add(
      _repeatMode,
    );
  }

  List<int> _albumIndexes() {
    if (_currentIndex < 0 ||
        _currentIndex >= _tracks.length) {
      return const [];
    }

    final album =
        _tracks[_currentIndex].album;

    final artist =
        _tracks[_currentIndex].artist;

    return [
      for (var i = 0;
          i < _tracks.length;
          i++)
        if (_tracks[i].album == album &&
            _tracks[i].artist == artist)
          i,
    ];
  }

  Future<void> _handleSongComplete() async {
    if (_tracks.isEmpty ||
        _currentIndex < 0) {
      return;
    }

    switch (_repeatMode) {
      case StellarRepeatMode.playlistOnce:
        final nextIndex =
            _currentIndex + 1;

        if (nextIndex <
            _tracks.length) {
          await playIndex(nextIndex);
        } else {
          await stop();
        }
        break;

      case StellarRepeatMode.songForever:
        await playIndex(
          _currentIndex,
        );
        break;

      case StellarRepeatMode.albumOnce:
        final indexes =
            _albumIndexes();

        if (indexes.isEmpty) {
          await stop();
          return;
        }

        final current =
            indexes.indexOf(
          _currentIndex,
        );

        if (current >= 0 &&
            current + 1 <
                indexes.length) {
          await playIndex(
            indexes[current + 1],
          );
        } else {
          await stop();
        }
        break;

      case StellarRepeatMode.albumForever:
        final indexes =
            _albumIndexes();

        if (indexes.isEmpty) {
          await stop();
          return;
        }

        final current =
            indexes.indexOf(
          _currentIndex,
        );

        if (current >= 0 &&
            current + 1 <
                indexes.length) {
          await playIndex(
            indexes[current + 1],
          );
        } else {
          await playIndex(
            indexes.first,
          );
        }
        break;
    }
  }
}
