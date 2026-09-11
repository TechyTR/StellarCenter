import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final AppThemeStyle selectedStyle;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.selectedStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedStyle == AppThemeStyle.normal) {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.memory_outlined),
            selectedIcon: Icon(Icons.memory),
            label: 'System',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'App',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Storage',
          ),
        ],
      );
    }

    return _LiquidGlassNavigationBar(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      isLight:
          selectedStyle ==
          AppThemeStyle.liquidGlassLight,
    );
  }
}

class _LiquidGlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isLight;

  const _LiquidGlassNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    final accent = scheme.primary;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 30,
            sigmaY: 30,
          ),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(32),
              color: isLight
                  ? Colors.white.withOpacity(0.22)
                  : Colors.black.withOpacity(0.28),
              border: Border.all(
                color: isLight
                    ? Colors.white.withOpacity(0.68)
                    : Colors.white.withOpacity(0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    isLight ? 0.10 : 0.28,
                  ),
                  blurRadius: 28,
                  spreadRadius: -6,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  top: 0,
                  height: 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(
                            isLight ? 0.80 : 0.38,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(32),
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(
                              isLight ? 0.12 : 0.07,
                            ),
                            Colors.transparent,
                            Colors.black.withOpacity(
                              isLight ? 0.025 : 0.08,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth / 6;

                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration:
                              const Duration(
                            milliseconds: 500,
                          ),
                          curve:
                              Curves.easeOutCubic,
                          left:
                              itemWidth *
                                  currentIndex +
                              4,
                          top: 7,
                          width:
                              itemWidth - 8,
                          height: 56,
                          child: IgnorePointer(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                25,
                              ),
                              child:
                                  BackdropFilter(
                                filter:
                                    ImageFilter.blur(
                                  sigmaX: 18,
                                  sigmaY: 18,
                                ),
                                child:
                                    DecoratedBox(
                                  decoration:
                                      BoxDecoration(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      25,
                                    ),
                                    color: isLight
                                        ? Colors.white
                                            .withOpacity(
                                            0.16,
                                          )
                                        : Colors.white
                                            .withOpacity(
                                            0.08,
                                          ),
                                    border:
                                        Border.all(
                                      color: isLight
                                          ? Colors.white
                                              .withOpacity(
                                              0.72,
                                            )
                                          : Colors.white
                                              .withOpacity(
                                              0.32,
                                            ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent
                                            .withOpacity(
                                          isLight
                                              ? 0.18
                                              : 0.14,
                                        ),
                                        blurRadius: 18,
                                        spreadRadius:
                                            -2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            _item(
                              context,
                              Icons
                                  .dashboard_outlined,
                              Icons.dashboard,
                              'Home',
                              0,
                              accent,
                            ),
                            _item(
                              context,
                              Icons.memory_outlined,
                              Icons.memory,
                              'System',
                              1,
                              accent,
                            ),
                            _item(
                              context,
                              Icons
                                  .monitor_heart_outlined,
                              Icons.monitor_heart,
                              'Monitor',
                              2,
                              accent,
                            ),
                            _item(
                              context,
                              Icons.note_outlined,
                              Icons.note,
                              'Notes',
                              3,
                              accent,
                            ),
                            _item(
                              context,
                              Icons.info_outline,
                              Icons.info,
                              'App',
                              4,
                              accent,
                            ),
                            _item(
                              context,
                              Icons.storage_outlined,
                              Icons.storage,
                              'Storage',
                              5,
                              accent,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
    Color accent,
  ) {
    final selected =
        currentIndex == index;

    final mutedColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: () =>
            onDestinationSelected(index),
        child: SizedBox(
          height: 70,
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale:
                      selected ? 1.06 : 1.0,
                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),
                  curve:
                      Curves.easeOutCubic,
                  child:
                      AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 220,
                    ),
                    child: Icon(
                      selected
                          ? selectedIcon
                          : icon,
                      key: ValueKey(
                        '$index-$selected',
                      ),
                      size: 20,
                      color: selected
                          ? accent
                          : mutedColor
                              .withOpacity(
                              0.82,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration:
                      const Duration(
                    milliseconds: 220,
                  ),
                  child: Text(label),
                  style: TextStyle(
                    fontSize:
                        selected ? 9.5 : 9,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? accent
                        : mutedColor
                            .withOpacity(
                            0.82,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
