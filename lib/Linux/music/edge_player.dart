import 'dart:async';

import 'package:flutter/material.dart';

import 'fullscreen_player.dart';
import 'lyrics_overlay.dart';
import 'music_cover.dart';
import 'music_service.dart';
import 'music_track.dart';

class StellarEdgePlayer extends StatefulWidget {
  final List<StellarMusicTrack> tracks;
  const StellarEdgePlayer({super.key, required this.tracks});

  @override
  State<StellarEdgePlayer> createState() => _StellarEdgePlayerState();
}

class _StellarEdgePlayerState extends State<StellarEdgePlayer> {
  final StellarMusicService service = StellarMusicService.instance;
  StreamSubscription<StellarMusicTrack?>? _trackSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  StellarMusicTrack? _track;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _track = service.currentTrack;
    _playing = service.isPlaying;
    _position = service.position;
    _duration = service.duration;
    _trackSub = service.currentTrackStream.listen((value) {
      if (mounted) setState(() { _track = value; _position = Duration.zero; _duration = Duration.zero; });
    });
    _playingSub = service.playingStream.listen((value) {
      if (mounted) setState(() => _playing = value);
    });
    _positionSub = service.positionStream.listen((value) {
      if (mounted) setState(() => _position = value);
    });
    _durationSub = service.durationStream.listen((value) {
      if (mounted) setState(() => _duration = value);
    });
  }

  @override
  void dispose() {
    _trackSub?.cancel();
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StellarFullscreenPlayer(tracks: widget.tracks),
    ));
  }

  String _time(Duration value) {
    final m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return value.inHours > 0 ? '${value.inHours}:$m:$s' : '$m:$s';
  }

  Widget _progress({required bool compact}) {
    final total = _duration.inMilliseconds;
    final value = total > 0
        ? _position.inMilliseconds.clamp(0, total).toDouble()
        : 0.0;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: compact ? 2.5 : 4,
        activeTrackColor: const Color(0xFF4CDB85),
        inactiveTrackColor: Colors.white.withOpacity(.13),
        thumbColor: const Color(0xFF75F0A5),
        overlayColor: const Color(0x224CDB85),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: compact ? 4 : 7),
        overlayShape: RoundSliderOverlayShape(overlayRadius: compact ? 10 : 17),
      ),
      child: Slider(
        min: 0,
        max: total > 0 ? total.toDouble() : 1,
        value: value,
        onChanged: total > 0 ? (v) => service.seek(Duration(milliseconds: v.round())) : null,
      ),
    );
  }

  Widget _mini(StellarMusicTrack track) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171D19),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        StellarMusicCover(artwork: track.artwork, size: 48, radius: 9),
        const SizedBox(width: 10),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 3),
            Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              minHeight: 2,
              value: _duration.inMilliseconds > 0
                  ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CDB85)),
            ),
          ],
        )),
        IconButton(onPressed: service.previous, tooltip: 'Önceki', icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70)),
        IconButton(onPressed: service.togglePlayPause, tooltip: _playing ? 'Duraklat' : 'Oynat',
            icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF75F0A5), size: 29)),
        IconButton(onPressed: _openFullscreen, tooltip: 'Tam ekran', icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 19)),
      ]),
    );
  }

  Widget _expanded(StellarMusicTrack track) {
    return Container(
      color: const Color(0xFF111713),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
            child: Row(children: [
              const Expanded(child: Text('ŞİMDİ ÇALIYOR',
                  style: TextStyle(color: Color(0xFF75F0A5), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800))),
              IconButton(tooltip: 'Tam ekran aç', onPressed: _openFullscreen,
                  icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 19)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 270, maxHeight: 270),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'stellar-cover-${track.path}',
                      child: StellarMusicCover(artwork: track.artwork, size: 260, radius: 18),
                    ),
                  ),
                )),
                const SizedBox(height: 22),
                Text(track.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.15)),
                const SizedBox(height: 6),
                Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 5),
                Text(track.album, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 18),
                Container(
                  height: 176,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.045),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(.07)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('ŞARKI SÖZLERİ', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(child: StellarLyricsOverlay(track: track, position: _position)),
                  ]),
                ),
                const SizedBox(height: 12),
                _progress(compact: false),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(children: [
                    Text(_time(_position), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    const Spacer(),
                    Text(_time(_duration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(onPressed: service.previous, icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 30)),
                  const SizedBox(width: 14),
                  Material(
                    color: const Color(0xFF75F0A5),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: service.togglePlayPause,
                      icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF101510), size: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton(onPressed: service.next, icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30)),
                ]),
                const SizedBox(height: 6),
                Center(child: Text(track.hasLyrics ? 'Sözler zamanlamayla eşleşir' : 'Bu parça için söz bulunamadı',
                    style: const TextStyle(color: Colors.white30, fontSize: 10))),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final track = _track;
      if (track == null) {
        return const Center(child: Text('Bir şarkı seç', style: TextStyle(color: Colors.white38)));
      }
      if (constraints.maxHeight < 180) {
        return _mini(track);
      }
      return _expanded(track);
    });
  }
}
