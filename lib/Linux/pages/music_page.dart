import 'dart:ui';

import 'package:flutter/material.dart';

class LinuxMusicPage extends StatelessWidget {
  const LinuxMusicPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    final bool light =
        Theme.of(context).brightness ==
            Brightness.light;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Music',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 70,
                sigmaY: 70,
              ),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary
                      .withOpacity(
                    light ? 0.12 : 0.10,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _musicPanel(
                context,
                light,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _musicPanel(
    BuildContext context,
    bool light,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary
                .withOpacity(0.12),
          ),
          child: Icon(
            Icons.music_note_rounded,
            size: 58,
            color: scheme.primary,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Music',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Müzik merkezi yakında burada olacak.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            _controlButton(
              context,
              Icons.skip_previous_rounded,
              false,
            ),
            const SizedBox(width: 14),
            _controlButton(
              context,
              Icons.play_arrow_rounded,
              true,
            ),
            const SizedBox(width: 14),
            _controlButton(
              context,
              Icons.skip_next_rounded,
              false,
            ),
          ],
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30,
          sigmaY: 30,
        ),
        child: Container(
          padding: const EdgeInsets.all(42),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(32),
            color: light
                ? Colors.white.withOpacity(0.28)
                : Colors.black.withOpacity(0.25),
            border: Border.all(
              color: light
                  ? Colors.white.withOpacity(0.60)
                  : Colors.white.withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  light ? 0.08 : 0.25,
                ),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _controlButton(
    BuildContext context,
    IconData icon,
    bool primary,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    return Material(
      color: primary
          ? scheme.primary
          : scheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(
            primary ? 18 : 14,
          ),
          child: Icon(
            icon,
            size: primary ? 30 : 24,
            color: primary
                ? scheme.onPrimary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
