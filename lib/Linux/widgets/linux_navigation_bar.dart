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
    final scheme = Theme.of(context).colorScheme;

    if (selectedStyle == AppThemeStyle.normal) {
      return _NormalLinuxNavigationBar(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
      );
    }

    return _LiquidGlassLinuxNavigationBar(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      isLight:
          selectedStyle == AppThemeStyle.liquidGlassLight,
    );
  }
}

class _NormalLinuxNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NormalLinuxNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: Container(
          width: 76,
          margin: const EdgeInsets.symmetric(
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(5, 8),
              ),
            ],
          ),
          child: _NavigationItems(
            currentIndex: currentIndex,
            onDestinationSelected:
                onDestinationSelected,
            isGlass: false,
            isLight: false,
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassLinuxNavigationBar
    extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isLight;

  const _LiquidGlassLinuxNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    return SafeArea(
      child: Center(
        child: Container(
          width: 76,
          margin: const EdgeInsets.symmetric(
            vertical: 24,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
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
                offset: const Offset(5, 10),
              ),
              BoxShadow(
                color: accent.withOpacity(0.10),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 30,
                sigmaY: 30,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 8,
                    right: 8,
                    height: 1.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
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
                  _NavigationItems(
                    currentIndex: currentIndex,
                    onDestinationSelected:
                        onDestinationSelected,
                    isGlass: true,
                    isLight: isLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItems extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isGlass;
  final bool isLight;

  const _NavigationItems({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isGlass,
    required this.isLight,
  });

  static const _items = [
    (
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Home',
    ),
    (
      Icons.memory_outlined,
      Icons.memory,
      'System',
    ),
    (
      Icons.monitor_heart_outlined,
      Icons.monitor_heart,
      'Monitor',
    ),
    (
      Icons.note_outlined,
      Icons.note,
      'Notes',
    ),
    (
      Icons.info_outline,
      Icons.info,
      'App',
    ),
    (
      Icons.storage_outlined,
      Icons.storage,
      'Storage',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight =
            constraints.maxHeight / _items.length;

        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(
                milliseconds: 500,
              ),
              curve: Curves.easeOutCubic,
              left: 7,
              right: 7,
              top:
                  itemHeight * currentIndex + 4,
              height: itemHeight - 8,
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(23),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(23),
                        color: isGlass
                            ? (isLight
                                ? Colors.white
                                    .withOpacity(0.16)
                                : Colors.white
                                    .withOpacity(0.08))
                            : accent.withOpacity(0.12),
                        border: isGlass
                            ? Border.all(
                                color: isLight
                                    ? Colors.white
                                        .withOpacity(
                                        0.72,
                                      )
                                    : Colors.white
                                        .withOpacity(
                                        0.32,
                                      ),
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(
                              isGlass
                                  ? 0.18
                                  : 0.14,
                            ),
                            blurRadius: 18,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: List.generate(
                _items.length,
                (index) {
                  final item = _items[index];

                  return Expanded(
                    child: _NavigationItem(
                      index: index,
                      currentIndex: currentIndex,
                      icon: item.$1,
                      selectedIcon: item.$2,
                      label: item.$3,
                      accent: accent,
                      isLight: isLight,
                      onTap: () =>
                          onDestinationSelected(
                        index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color accent;
  final bool isLight;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.accent,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;

    final mutedColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withOpacity(0.82);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.06 : 1.0,
              duration: const Duration(
                milliseconds: 300,
              ),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 220,
                ),
                transitionBuilder:
                    (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
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
                      : mutedColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(
                milliseconds: 220,
              ),
              style: TextStyle(
                fontSize: selected ? 9.5 : 9,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: selected
                    ? accent
                    : mutedColor,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
