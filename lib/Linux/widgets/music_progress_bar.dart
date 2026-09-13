import 'package:flutter/material.dart';

class MusicProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const MusicProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  String _format(Duration value) {
    final minutes =
        value.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        value.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final total = duration.inMilliseconds;

    final current =
        position.inMilliseconds.clamp(
      0,
      total > 0 ? total : 1,
    );

    final progress = total <= 0
        ? 0.0
        : current / total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape:
                const RoundSliderThumbShape(
              enabledThumbRadius: 6,
            ),
            overlayShape:
                const RoundSliderOverlayShape(
              overlayRadius: 14,
            ),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: total <= 0
                ? null
                : (value) {
                    final milliseconds =
                        (total * value).round();

                    onSeek(
                      Duration(
                        milliseconds: milliseconds,
                      ),
                    );
                  },
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _format(duration),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
