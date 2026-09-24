import 'package:flutter/material.dart';

import '../music/music_track.dart';
import '../music/stellar_edge_player.dart';
import '../music/stellar_music_background.dart';
import '../music/stellar_music_scanner.dart';
import '../music/stellar_music_service.dart';

class LinuxMusicPage extends StatefulWidget {
  const LinuxMusicPage({super.key});

  @override
  State<LinuxMusicPage> createState() => _LinuxMusicPageState();
}

class _LinuxMusicPageState extends State<LinuxMusicPage> {
  final StellarMusicService service = StellarMusicService.instance;

  List<StellarMusicTrack> _tracks = [];

  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    service.initialize();

    // Sayfa açıldığında yalnızca bir kez tarama yapılır.
    // Sürekli/periyodik tarama yoktur.
    _scan();
  }

  Future<void> _scan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final tracks = await StellarMusicScanner.scan();

      if (!mounted) return;

      setState(() {
        _tracks = tracks;
        _isScanning = false;
      });

      service.setTracks(tracks);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  void dispose() {
    // Müzik servisi dispose edilmiyor.
    //
    // Böylece:
    // Müzik sayfasından çıkılır
    // → servis yaşamaya devam eder
    // → AudioPlayer yaşamaya devam eder
    // → müzik kesilmez.
    super.dispose();
  }

  void _play(int index) {
    if (_tracks.isEmpty) return;

    service.setTracks(_tracks);
    service.playIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return StellarMusicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),

                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),

            // Edge player her zaman ekranın altında bulunur.
            // Fullscreen açma hareketi Edge Player tarafından yönetilir.
            if (_tracks.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: StellarEdgePlayer(
                    tracks: _tracks,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Müzik',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stellar Music',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isScanning
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 42,
                    height: 42,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    key: const ValueKey('refresh'),
                    tooltip: 'Yenile',
                    onPressed: _scan,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isScanning && _tracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Müzikler taranıyor...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '~/StellarCenter/Music',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_tracks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        150,
      ),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];

        return _SongTile(
          track: track,
          onTap: () => _play(index),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 44,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Henüz müzik bulunamadı',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '~/StellarCenter/Music',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: _scan,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 19,
              ),
              label: const Text('Tekrar tara'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final StellarMusicTrack track;
  final VoidCallback onTap;

  const _SongTile({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            child: Row(
              children: [
                _Artwork(track: track),
                const SizedBox(width: 13),
                Expanded(
                  child: _TrackInformation(track: track),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 30,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final StellarMusicTrack track;

  const _Artwork({
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    if (track.artwork != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.memory(
          track.artwork!,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _fallbackArtwork();
          },
        ),
      );
    }

    return _fallbackArtwork();
  }

  Widget _fallbackArtwork() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1769FF),
            Color(0xFF6A1B9A),
            Color(0xFFB5179E),
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _TrackInformation extends StatelessWidget {
  final StellarMusicTrack track;

  const _TrackInformation({
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final artist = track.artist.trim().isEmpty
        ? 'Bilinmeyen sanatçı'
        : track.artist.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (track.verifiedArtist) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                size: 17,
                color: Colors.lightBlueAccent,
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
