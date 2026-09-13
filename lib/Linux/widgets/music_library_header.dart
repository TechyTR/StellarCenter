import 'package:flutter/material.dart';

class MusicLibraryHeader extends StatelessWidget {
  final int songCount;
  final int albumCount;
  final VoidCallback onRefresh;

  const MusicLibraryHeader({
    super.key,
    required this.songCount,
    required this.albumCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Müzik',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$songCount parça • $albumCount albüm',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Müziği yeniden tara',
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
