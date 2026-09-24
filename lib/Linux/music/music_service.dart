import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'music_track.dart';

class StellarMusicService {
  StellarMusicService._();

  static final StellarMusicService instance =
      StellarMusicService._();

  final AudioPlayer player = AudioPlayer();

  final StreamController<StellarMusicTrack?> _trackController =
      StreamController<StellarMusicTrack?>.broadcast();

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  StellarMusicTrack? currentTrack;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool playing = false;

  Stream<StellarMusicTrack?> get trackStream =>
      _trackController.stream;

  Stream<Duration> get positionStream =>
      _positionController.stream;

  Stream<Duration> get durationStream =>
      _durationController.stream;

  Stream<bool> get playingStream =>
      _playingController.stream;

  bool _initialized = false;

  void initialize() {
    if (_initialized) {
      return;
    }

    _initialized = true;

    player.onPositionChanged.listen((value) {
      position = value;
      _positionController.add(value);
    });

    player.onDurationChanged.listen((value) {
      duration = value;
      _durationController.add(value);
    });

    player.onPlayerStateChanged.listen((state) {
      playing = state == PlayerState.playing;
      _playingController.add(playing);
    });

    player.onPlayerComplete.listen((_) {
      playing = false;
      position = Duration.zero;

      _playingController.add(false);
      _positionController.add(Duration.zero);
    });
  }

  Future<void> play(
    StellarMusicTrack track,
  ) async {
    initialize();

    if (currentTrack?.path == track.path) {
      await player.resume();
      return;
    }

    await player.stop();

    currentTrack = track;
    position = Duration.zero;
    duration = Duration.zero;

    _trackController.add(track);

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

  Future<void> toggle() async {
    if (playing) {
      await pause();
    } else {
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

    playing = false;
    position = Duration.zero;

    _playingController.add(false);
    _positionController.add(Duration.zero);
  }
}
