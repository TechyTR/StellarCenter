import 'dart:math';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<String> _queuePaths = [];
  final Set<String> _favoritePaths = {};
  final List<String> _historyPaths = [];
  bool _shuffle = false;
  final Random _random = Random();

  StellarMusicTrack? _currentTrack;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  int _currentIndex = -1;

  bool _playing = false;
  bool _initialized = false;
  bool _changingTrack = false;

  int _playRequest = 0;

  StellarRepeatMode _repeatMode =
      StellarRepeatMode.playlistOnce;

  Stream<StellarMusicTrack?> get currentTrackStream =>
      _trackController.stream;

  Stream<Duration> get positionStream =>
      _positionController.stream;

  Stream<Duration> get durationStream =>
      _durationController.stream;

  Stream<bool> get playingStream =>
      _playingController.stream;

  Stream<StellarRepeatMode> get repeatModeStream =>
      _repeatController.stream;

  StellarMusicTrack? get currentTrack =>
      _currentTrack;

  Duration get position => _position;

  Duration get duration => _duration;

  bool get isPlaying => _playing;

  int get currentIndex => _currentIndex;

  StellarRepeatMode get repeatMode =>
      _repeatMode;

  List<StellarMusicTrack> get queue => _queuePaths.map(_trackForPath).whereType<StellarMusicTrack>().toList(growable: false);
  List<StellarMusicTrack> get history => _historyPaths.map(_trackForPath).whereType<StellarMusicTrack>().toList(growable: false);
  Set<String> get favoritePaths => Set.unmodifiable(_favoritePaths);
  bool isFavorite(StellarMusicTrack track) => _favoritePaths.contains(track.path);
  bool get shuffleEnabled => _shuffle;

  StellarMusicTrack? _trackForPath(String path) {
    for (final track in _tracks) { if (track.path == path) return track; }
    return null;
  }

  Future<void> loadLibraryState() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritePaths
      ..clear()
      ..addAll(prefs.getStringList('stellar_music_favorites') ?? const []);
    _historyPaths
      ..clear()
      ..addAll(prefs.getStringList('stellar_music_history') ?? const []);
    _queuePaths
      ..clear()
      ..addAll(prefs.getStringList('stellar_music_queue') ?? const []);
  }

  Future<void> toggleFavorite(StellarMusicTrack track) async {
    if (!_favoritePaths.add(track.path)) _favoritePaths.remove(track.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stellar_music_favorites', _favoritePaths.toList());
  }

  Future<void> addToQueue(StellarMusicTrack track) async {
    if (_queuePaths.contains(track.path)) return;
    _queuePaths.add(track.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stellar_music_queue', _queuePaths);
  }

  Future<void> removeFromQueue(StellarMusicTrack track) async {
    _queuePaths.remove(track.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stellar_music_queue', _queuePaths);
  }

  Future<void> clearQueue() async {
    _queuePaths.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stellar_music_queue');
  }

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
  }

  Future<void> _recordHistory(StellarMusicTrack track) async {
    _historyPaths.remove(track.path);
    _historyPaths.insert(0, track.path);
    if (_historyPaths.length > 100) _historyPaths.removeRange(100, _historyPaths.length);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stellar_music_history', _historyPaths);
  }

  List<StellarMusicTrack> get tracks =>
      List.unmodifiable(_tracks);

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    player.onPositionChanged.listen((value) {
      _position = value;
      _positionController.add(value);
    });

    player.onDurationChanged.listen((value) {
      _duration = value;
      _durationController.add(value);
    });

    player.onPlayerStateChanged.listen((state) {
      final playing =
          state == PlayerState.playing;

      if (_playing == playing) return;

      _playing = playing;
      _playingController.add(playing);
    });

    player.onPlayerComplete.listen((_) {
      _handleComplete();
    });
  }

  void setTracks(
    List<StellarMusicTrack> tracks,
  ) {
    final currentPath = _currentTrack?.path;

    _tracks
      ..clear()
      ..addAll(tracks);

    if (_tracks.isEmpty) {
      _currentIndex = -1;
      _currentTrack = null;
      _position = Duration.zero;
      _duration = Duration.zero;

      _trackController.add(null);
      _positionController.add(Duration.zero);
      _durationController.add(Duration.zero);
      return;
    }

    if (currentPath == null) return;

    final index = _tracks.indexWhere(
      (track) => track.path == currentPath,
    );

    if (index >= 0) {
      _currentIndex = index;
      _currentTrack = _tracks[index];
    } else {
      _currentIndex = -1;
      _currentTrack = null;
    }
  }

  Future<void> playIndex(int index) async {
    if (index < 0 ||
        index >= _tracks.length) {
      return;
    }

    final request = ++_playRequest;
    final track = _tracks[index];

    _changingTrack = true;

    try {
      await player.stop();

      if (request != _playRequest) return;

      _currentIndex = index;
      _currentTrack = track;

      _position = Duration.zero;
      _duration = Duration.zero;

      _trackController.add(track);
      await _recordHistory(track);
      _positionController.add(Duration.zero);
      _durationController.add(Duration.zero);

      await player.play(
        DeviceFileSource(track.path),
      );
    } catch (_) {
      if (request == _playRequest) {
        _playing = false;
        _playingController.add(false);
      }
    } finally {
      if (request == _playRequest) {
        _changingTrack = false;
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;

    if (_playing) {
      await player.pause();
      return;
    }

    await player.resume();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    if (_currentTrack == null) return;

    await player.resume();
  }

  Future<void> stop() async {
    ++_playRequest;

    await player.stop();

    _position = Duration.zero;

    _playing = false;
    _playingController.add(false);
    _positionController.add(Duration.zero);
  }

  Future<void> seek(Duration position) async {
    final safe = position < Duration.zero
        ? Duration.zero
        : position > _duration
            ? _duration
            : position;

    await player.seek(safe);
  }

  Future<void> next() async {
    if (_changingTrack ||
        _tracks.isEmpty ||
        _currentIndex < 0) {
      return;
    }

    if (_repeatMode ==
        StellarRepeatMode.songForever) {
      await playIndex(_currentIndex);
      return;
    }

    if (_queuePaths.isNotEmpty) {
      final nextPath = _shuffle
          ? _queuePaths[_random.nextInt(_queuePaths.length)]
          : _queuePaths.first;
      final queuedIndex = _tracks.indexWhere((track) => track.path == nextPath);
      _queuePaths.remove(nextPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('stellar_music_queue', _queuePaths);
      if (queuedIndex >= 0) { await playIndex(queuedIndex); return; }
    }

    final indexes = _activeIndexes();

    if (indexes.isEmpty) return;

    if (_shuffle && indexes.length > 1) {
      final candidates = indexes.where((index) => index != _currentIndex).toList();
      await playIndex(candidates[_random.nextInt(candidates.length)]);
      return;
    }

    final local =
        indexes.indexOf(_currentIndex);

    if (local < 0) return;

    if (local + 1 < indexes.length) {
      await playIndex(
        indexes[local + 1],
      );
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
      await playIndex(
        _currentIndex + 1,
      );
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (_changingTrack ||
        _currentIndex < 0) {
      return;
    }

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

    final indexes = _activeIndexes();

    if (indexes.isEmpty) return;

    final local =
        indexes.indexOf(_currentIndex);

    if (local > 0) {
      await playIndex(
        indexes[local - 1],
      );
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
      await playIndex(
        _currentIndex - 1,
      );
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
    if (_changingTrack) return;

    await next();
  }
}
