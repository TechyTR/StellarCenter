import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class LinuxMusicPage extends StatefulWidget {
  const LinuxMusicPage({
    super.key,
  });

  @override
  State<LinuxMusicPage> createState() => _LinuxMusicPageState();
}

class _LinuxMusicPageState extends State<LinuxMusicPage> {
  final AudioPlayer _player = AudioPlayer();

  final List<_MusicTrack> _tracks = [];

  Timer? _scanTimer;

  _MusicTrack? _currentTrack;

  bool _loading = true;
  bool _playing = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.onPositionChanged.listen((position) {
      if (!mounted) return;

      setState(() {
        _position = position;
      });
    });

    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;

      setState(() {
        _duration = duration;
      });
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _playing = state == PlayerState.playing;
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });

    _scanMusic();

    _scanTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _scanMusic(),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  String get _musicDirectory {
    final home = Platform.environment['HOME'];

    if (home != null && home.isNotEmpty) {
      return '$home/StellarCenter/Music';
    }

    return '/StellarCenter/Music';
  }

  Future<void> _scanMusic() async {
    final directory = Directory(_musicDirectory);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final List<_MusicTrack> found = [];

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final path = entity.path;
      final lower = path.toLowerCase();

      if (!lower.endsWith('.mp3')) {
        continue;
      }

      final file = File(path);

      final parent =
          file.parent.path;

      final baseName =
          path.split(Platform.pathSeparator).last;

      final nameWithoutExtension =
          baseName.replaceFirst(
        RegExp(r'\.mp3$', caseSensitive: false),
        '',
      );

      final lrcFile =
          File('$parent/$nameWithoutExtension.lrc');

      final pngFile =
          File('$parent/$nameWithoutExtension.png');

      final jpgFile =
          File('$parent/$nameWithoutExtension.jpg');

      final jpegFile =
          File('$parent/$nameWithoutExtension.jpeg');

      File? cover;

      if (await pngFile.exists()) {
        cover = pngFile;
      } else if (await jpgFile.exists()) {
        cover = jpgFile;
      } else if (await jpegFile.exists()) {
        cover = jpegFile;
      }

      final bool hasLyrics =
          await lrcFile.exists();

      final bool hasCover =
          cover != null;

      final bool verified =
          hasLyrics || hasCover;

      final folderName =
          file.parent.path
              .split(Platform.pathSeparator)
              .last;

      found.add(
        _MusicTrack(
          path: file.path,
          title: nameWithoutExtension,
          artist: folderName,
          cover: cover,
          lrc: hasLyrics ? lrcFile : null,
          verified: verified,
        ),
      );
    }

    found.sort(
      (a, b) => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _tracks
        ..clear()
        ..addAll(found);

      _loading = false;

      if (_currentTrack != null) {
        final currentPath =
            _currentTrack!.path;

        final updated =
            found.where(
          (track) =>
              track.path == currentPath,
        );

        _currentTrack =
            updated.isEmpty
                ? null
                : updated.first;
      }
    });
  }

  Future<void> _playTrack(
    _MusicTrack track,
  ) async {
    if (_currentTrack?.path == track.path) {
      if (_playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }

      return;
    }

    await _player.stop();

    setState(() {
      _currentTrack = track;
      _position = Duration.zero;
      _duration = Duration.zero;
      _playing = false;
    });

    await _player.play(
      DeviceFileSource(track.path),
    );
  }

  Future<void> _toggleCurrent() async {
    if (_currentTrack == null) {
      if (_tracks.isNotEmpty) {
        await _playTrack(_tracks.first);
      }

      return;
    }

    if (_playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> _previousTrack() async {
    if (_currentTrack == null ||
        _tracks.isEmpty) {
      return;
    }

    final index =
        _tracks.indexWhere(
      (track) =>
          track.path == _currentTrack!.path,
    );

    if (index <= 0) {
      await _playTrack(_tracks.last);
    } else {
      await _playTrack(
        _tracks[index - 1],
      );
    }
  }

  Future<void> _nextTrack() async {
    if (_currentTrack == null ||
        _tracks.isEmpty) {
      return;
    }

    final index =
        _tracks.indexWhere(
      (track) =>
          track.path == _currentTrack!.path,
    );

    if (index == -1 ||
        index >= _tracks.length - 1) {
      await _playTrack(_tracks.first);
    } else {
      await _playTrack(
        _tracks[index + 1],
      );
    }
  }

  String _formatDuration(
    Duration duration,
  ) {
    final minutes =
        duration.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        duration.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final bool light =
        theme.brightness ==
            Brightness.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Music',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        backgroundColor:
            Colors.transparent,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: ImageFiltered(
              imageFilter:
                  ImageFilter.blur(
                sigmaX: 70,
                sigmaY: 70,
              ),
              child: Container(
                width: 300,
                height: 300,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color: scheme.primary
                      .withOpacity(
                    light
                        ? 0.14
                        : 0.10,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 80,
            bottom: 150,
            child: _buildSongList(
              context,
            ),
          ),

          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            height: 112,
            child:
                _buildArtistAlbums(
              context,
            ),
          ),

          if (_currentTrack != null)
            _buildPlayerPanel(
              context,
            ),
        ],
      ),
    );
  }

  Widget _buildSongList(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_tracks.isEmpty) {
      return Center(
        child: _glassContainer(
          context,
          padding:
              const EdgeInsets.all(36),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.library_music_rounded,
                size: 56,
                color:
                    scheme.primary,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Müzik bulunamadı',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'MP3 dosyalarını\n'
                '$_musicDirectory\n'
                'klasörüne koy.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: scheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _scanMusic,
      child: ListView.builder(
        padding:
            const EdgeInsets.fromLTRB(
          24,
          20,
          390,
          24,
        ),
        itemCount:
            _tracks.length,
        itemBuilder:
            (context, index) {
          final track =
              _tracks[index];

          final selected =
              _currentTrack?.path ==
                  track.path;

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),
            child:
                _buildTrackTile(
              context,
              track,
              selected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackTile(
    BuildContext context,
    _MusicTrack track,
    bool selected,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return _glassContainer(
      context,
      padding:
          const EdgeInsets.all(10),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: () =>
            _playTrack(track),
        child: Row(
          children: [
            _coverWidget(
              context,
              track,
              size: 64,
              radius: 16,
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          track.title,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),

                      if (track.verified)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            left: 8,
                          ),
                          child: Icon(
                            Icons
                                .verified_rounded,
                            size: 19,
                            color:
                                scheme.primary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme
                          .onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () =>
                  _playTrack(track),
              icon: Icon(
                selected &&
                        _playing
                    ? Icons
                        .pause_rounded
                    : Icons
                        .play_arrow_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistAlbums(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    final Map<String, List<_MusicTrack>>
        artists = {};

    for (final track in _tracks) {
      artists
          .putIfAbsent(
            track.artist,
            () => [],
          )
          .add(track);
    }

    final entries =
        artists.entries.toList()
          ..sort(
            (a, b) =>
                a.key.toLowerCase()
                    .compareTo(
                  b.key.toLowerCase(),
                ),
          );

    return _glassContainer(
      context,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10,
      ),
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 14,
            ),
            child: Text(
              'Sanatçı Albümleri',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            child:
                ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount:
                  entries.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                width: 10,
              ),
              itemBuilder:
                  (context, index) {
                final artist =
                    entries[index];

                final firstTrack =
                    artist.value.first;

                return Container(
                  width: 86,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                    color: scheme
                        .surfaceContainerHighest
                        .withOpacity(
                      0.42,
                    ),
                  ),
                  clipBehavior:
                      Clip.antiAlias,
                  child: InkWell(
                    onTap: () =>
                        _playTrack(
                      firstTrack,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              _coverWidget(
                            context,
                            firstTrack,
                            size: 60,
                            radius: 0,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          child: Text(
                            artist.key,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerPanel(
    BuildContext context,
  ) {
    final track =
        _currentTrack!;

    final scheme =
        Theme.of(context)
            .colorScheme;

    return Positioned(
      top: 100,
      right: 18,
      bottom: 150,
      width: 330,
      child: _glassContainer(
        context,
        padding:
            const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.music_note_rounded,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    'Şimdi Çalıyor',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            _coverWidget(
              context,
              track,
              size: 210,
              radius: 24,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              track.title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              track.artist,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Slider(
              value: _duration.inMilliseconds >
                      0
                  ? _position.inMilliseconds
                      .clamp(
                      0,
                      _duration.inMilliseconds,
                    )
                      .toDouble()
                  : 0,
              max:
                  _duration.inMilliseconds >
                          0
                      ? _duration
                          .inMilliseconds
                          .toDouble()
                      : 1,
              onChanged:
                  (value) {
                _player.seek(
                  Duration(
                    milliseconds:
                        value.toInt(),
                  ),
                );
              },
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  _formatDuration(
                    _position,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 11,
                  ),
                ),
                Text(
                  _formatDuration(
                    _duration,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 6,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                IconButton(
                  onPressed:
                      _previousTrack,
                  icon: const Icon(
                    Icons
                        .skip_previous_rounded,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Material(
                  color:
                      scheme.primary,
                  shape:
                      const CircleBorder(),
                  child: InkWell(
                    customBorder:
                        const CircleBorder(),
                    onTap:
                        _toggleCurrent,
                    child:
                        Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        16,
                      ),
                      child: Icon(
                        _playing
                            ? Icons
                                .pause_rounded
                            : Icons
                                .play_arrow_rounded,
                        color: scheme
                            .onPrimary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                IconButton(
                  onPressed:
                      _nextTrack,
                  icon: const Icon(
                    Icons
                        .skip_next_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            if (track.lrc != null)
              Expanded(
                child:
                    _lyricsPreview(
                  context,
                  track,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lyricsPreview(
    BuildContext context,
    _MusicTrack track,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return FutureBuilder<String>(
      future:
          track.lrc!.readAsString(),
      builder:
          (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final lines =
            snapshot.data!
                .split('\n')
                .where(
                  (line) =>
                      line.trim().isNotEmpty,
                )
                .take(8)
                .toList();

        return ListView.builder(
          itemCount:
              lines.length,
          itemBuilder:
              (context, index) {
            final text =
                lines[index]
                    .replaceFirst(
                  RegExp(
                    r'^\[\d{2}:\d{2}(?:\.\d{1,3})?\]',
                  ),
                  '',
                )
                    .trim();

            return Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Text(
                text,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: index == 0
                      ? scheme.primary
                      : scheme
                          .onSurfaceVariant,
                  fontWeight:
                      index == 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _coverWidget(
    BuildContext context,
    _MusicTrack track, {
    required double size,
    required double radius,
  }) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    if (track.cover != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          radius,
        ),
        child: Image.file(
          track.cover!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  _defaultCover(
            scheme,
            size,
            radius,
          ),
        ),
      );
    }

    return _defaultCover(
      scheme,
      size,
      radius,
    );
  }

  Widget _defaultCover(
    ColorScheme scheme,
    double size,
    double radius,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          radius,
        ),
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            scheme.primary
                .withOpacity(0.35),
            scheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.38,
        color:
            scheme.primary,
      ),
    );
  }

  Widget _glassContainer(
    BuildContext context, {
    required Widget child,
    required EdgeInsets padding,
  }) {
    final theme =
        Theme.of(context);

    final light =
        theme.brightness ==
            Brightness.light;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        24,
      ),
      child: BackdropFilter(
        filter:
            ImageFilter.blur(
          sigmaX: 28,
          sigmaY: 28,
        ),
        child: Container(
          padding: padding,
          decoration:
              BoxDecoration(
            color: light
                ? Colors.white
                    .withOpacity(0.28)
                : Colors.black
                    .withOpacity(0.28),
            border:
                Border.all(
              color: light
                  ? Colors.white
                      .withOpacity(0.55)
                  : Colors.white
                      .withOpacity(0.16),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  light
                      ? 0.06
                      : 0.20,
                ),
                blurRadius: 30,
                offset:
                    const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MusicTrack {
  final String path;
  final String title;
  final String artist;
  final File? cover;
  final File? lrc;
  final bool verified;

  const _MusicTrack({
    required this.path,
    required this.title,
    required this.artist,
    required this.cover,
    required this.lrc,
    required this.verified,
  });
}
