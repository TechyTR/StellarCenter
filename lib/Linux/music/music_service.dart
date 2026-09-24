import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'music_track.dart';
import 'repeat_mode.dart';

class StellarMusicService {
  StellarMusicService._();

  static final StellarMusicService instance = StellarMusicService._();

  final AudioPlayer player = AudioPlayer();

  final StreamController<StellarMusicTrack?> _trackController =
      StreamController<StellarMusicTrack?>.broadcast();

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  final StreamController<StellarRepeatMode> _repeatController =
      StreamController<StellarRepeatMode>.broadcast();

  List<StellarMusicTrack> _tracks = [];
  int _currentIndex = -1;

  StellarRepeatMode _repeatMode = StellarRepeatMode.playlistOnce;

  Stream<StellarMusicTrack?> get currentTrackStream =>
      _trackController.stream;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<Duration> get durationStream => _durationController.stream;

  Stream<bool> get playingStream => _playingController.stream;

  Stream<StellarRepeatMode> get repeatModeStream =>
      _repeatController.stream;

  StellarMusicTrack? get currentTrack {
    if (_currentIndex < 0 || _currentIndex >= _tracks.length) {
      return null;
    }

    return _tracks[_currentIndex];
  }

  int get currentIndex => _currentIndex;

  StellarRepeatMode get repeatMode => _repeatMode;

  List<StellarMusicTrack> get tracks =>
      List.unmodifiable(_tracks);

  void initialize() {
    player.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    player.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });

    player.onPlayerStateChanged.listen((state) {
      _playingController.add(state == PlayerState.playing);
    });

    player.onPlayerComplete.listen((_) {
      _handleSongComplete();
    });
  }

  void setTracks(List<StellarMusicTrack> tracks) {
    _tracks = List.from(tracks);

    if (_currentIndex >= _tracks.length) {
      _currentIndex = -1;
    }
  }

  Future<void> playIndex(int index) async {
    if (_tracks.isEmpty) return;
    if (index < 0 || index >= _tracks.length) return;

    _currentIndex = index;

    final track = _tracks[index];

    _trackController.add(track);

    await player.stop();

    await player.play(
      DeviceFileSource(track.path),
    );
  }

  Future<void> play(StellarMusicTrack track) async {
    final index = _tracks.indexWhere(
      (item) => item.path == track.path,
    );

    if (index >= 0) {
      await playIndex(index);
    }
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    await player.resume();
  }

  Future<void> toggle() async {
    if (player.state == PlayerState.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> next() async {
    if (_tracks.isEmpty) return;

    if (_repeatMode == StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    final nextIndex = _currentIndex + 1;

    if (nextIndex < _tracks.length) {
      await playIndex(nextIndex);
      return;
    }

    // Albüm modlarında albümün sonuna gelince
    // albümün ilk şarkısına dön.
    if (_repeatMode == StellarRepeatMode.albumForever) {
      final album = currentTrack?.album;

      if (album != null && album.isNotEmpty) {
        final albumTracks = _albumIndexes(album);

        if (albumTracks.isNotEmpty) {
          await playIndex(albumTracks.first);
          return;
        }
      }
    }

    // Playlist sonsuz modu yok:
    // 1× modunda listenin sonunda dur.
    await player.stop();
    _playingController.add(false);
  }

  Future<void> previous() async {
    if (_tracks.isEmpty) return;

    final position = await player.getCurrentPosition();

    // Şarkının başındaysak önceki şarkıya geç.
    // Ortasındaysak önce şarkının başına dön.
    if (position != null &&
        position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
      return;
    }

    if (_repeatMode == StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    final previousIndex = _currentIndex - 1;

    if (previousIndex >= 0) {
      await playIndex(previousIndex);
    }
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case StellarRepeatMode.playlistOnce:
        _repeatMode = StellarRepeatMode.songForever;
        break;

      case StellarRepeatMode.songForever:
        _repeatMode = StellarRepeatMode.albumOnce;
        break;

      case StellarRepeatMode.albumOnce:
        _repeatMode = StellarRepeatMode.albumForever;
        break;

      case StellarRepeatMode.albumForever:
        _repeatMode = StellarRepeatMode.playlistOnce;
        break;
    }

    _repeatController.add(_repeatMode);
  }

  List<int> _albumIndexes(String album) {
    final indexes = <int>[];

    for (int i = 0; i < _tracks.length; i++) {
      if (_tracks[i].album == album) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  Future<void> _handleSongComplete() async {
    if (_tracks.isEmpty || _currentIndex < 0) return;

    final current = currentTrack;

    // Aynı şarkı sonsuz
    if (_repeatMode == StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    // Albüm modları
    if ((_repeatMode == StellarRepeatMode.albumOnce ||
            _repeatMode == StellarRepeatMode.albumForever) &&
        current != null) {
      final album = current.album;

      if (album.isNotEmpty) {
        final albumIndexes = _albumIndexes(album);
        final albumPosition =
            albumIndexes.indexOf(_currentIndex);

        if (albumPosition >= 0 &&
            albumPosition < albumIndexes.length - 1) {
          await playIndex(
            albumIndexes[albumPosition + 1],
          );
          return;
        }

        // Albüm bitti.
        if (_repeatMode == StellarRepeatMode.albumForever) {
          await playIndex(albumIndexes.first);
          return;
        }

        await player.stop();
        _playingController.add(false);
        return;
      }
    }

    // Normal playlist 1×
    final nextIndex = _currentIndex + 1;

    if (nextIndex < _tracks.length) {
      await playIndex(nextIndex);
    } else {
      await player.stop();
      _playingController.add(false);
    }
  }

  Future<void> stop() async {
    await player.stop();
    _playingController.add(false);
  }
}
