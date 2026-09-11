import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LinuxNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final AppThemeStyle selectedStyle;

  const LinuxNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.selectedStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    final isGlass =
        selectedStyle != AppThemeStyle.normal;

    final isLight =
        selectedStyle ==
        AppThemeStyle.liquidGlassLight;

    return SafeArea(
      child: Container(
        width: 96,
        margin: const EdgeInsets.fromLTRB(
          12,
          12,
          0,
          12,
        ),
        decoration: BoxDecoration(
          color: isGlass
              ? (isLight
                  ? Colors.white.withOpacity(0.22)
                  : Colors.black.withOpacity(0.28))
              : scheme.surface,
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color: isGlass
                ? (isLight
                    ? Colors.white.withOpacity(0.65)
                    : Colors.white.withOpacity(0.25))
                : scheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isLight ? 0.10 : 0.25,
              ),
              blurRadius: 28,
              offset: const Offset(6, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(30),
          child: BackdropFilter(
            filter: isGlass
                ? ImageFilter.blur(
                    sigmaX: 24,
                    sigmaY: 24,
                  )
                : ImageFilter.blur(
                    sigmaX: 0,
                    sigmaY: 0,
                  ),
            child: Column(
              children: [
                const SizedBox(height: 14),

                Expanded(
                  child: Column(
                    children: [
                      _navigationItem(
                        context,
                        index: 0,
                        icon:
                            Icons.dashboard_outlined,
                        selectedIcon:
                            Icons.dashboard,
                        label: 'Home',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                      _navigationItem(
                        context,
                        index: 1,
                        icon:
                            Icons.memory_outlined,
                        selectedIcon:
                            Icons.memory,
                        label: 'System',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                      _navigationItem(
                        context,
                        index: 2,
                        icon: Icons
                            .monitor_heart_outlined,
                        selectedIcon:
                            Icons.monitor_heart,
                        label: 'Monitor',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                      _navigationItem(
                        context,
                        index: 3,
                        icon:
                            Icons.notes_outlined,
                        selectedIcon:
                            Icons.notes,
                        label: 'Notes',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                      _navigationItem(
                        context,
                        index: 4,
                        icon:
                            Icons.info_outline,
                        selectedIcon:
                            Icons.info,
                        label: 'App',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                      _navigationItem(
                        context,
                        index: 5,
                        icon:
                            Icons.storage_outlined,
                        selectedIcon:
                            Icons.storage,
                        label: 'Storage',
                        isGlass: isGlass,
                        isLight: isLight,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navigationItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isGlass,
    required bool isLight,
  }) {
    final scheme =
        Theme.of(context).colorScheme;

    final selected =
        currentIndex == index;

    final accent = scheme.primary;

    final muted = scheme
        .onSurfaceVariant
        .withOpacity(0.82);

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(22),
            onTap: () {
              onDestinationSelected(index);
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 280,
              ),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(22),
                color: selected
                    ? (isGlass
                        ? Colors.white
                            .withOpacity(
                            isLight
                                ? 0.18
                                : 0.08,
                          )
                        : accent.withOpacity(0.12))
                    : Colors.transparent,
                border:
                    selected && isGlass
                        ? Border.all(
                            color: isLight
                                ? Colors.white
                                    .withOpacity(
                                    0.70,
                                  )
                                : Colors.white
                                    .withOpacity(
                                    0.30,
                                  ),
                          )
                        : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent
                              .withOpacity(
                            0.16,
                          ),
                          blurRadius: 18,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    AnimatedScale(
                      scale: selected
                          ? 1.08
                          : 1.0,
                      duration:
                          const Duration(
                        milliseconds: 220,
                      ),
                      child: Icon(
                        selected
                            ? selectedIcon
                            : icon,
                        size: 22,
                        color: selected
                            ? accent
                            : muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? accent
                            : muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
