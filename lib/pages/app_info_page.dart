import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/app_version.dart';
import '../both/theme/app_theme.dart';
import '../both/widgets/update_button.dart';
import 'battery_lab_page.dart';
import 'benchmark_page.dart';
import 'network_lab_page.dart';
import 'sensor_lab_page.dart';
import 'storage_manager_page.dart';

class AppInfoPage extends StatelessWidget {
  final AppThemeColor selectedTheme;
  final AppThemeStyle selectedStyle;

  final Future<void> Function(
    AppThemeColor,
  ) onThemeChanged;

  final Future<void> Function(
    AppThemeStyle,
  ) onStyleChanged;

  const AppInfoPage({
    super.key,
    required this.selectedTheme,
    required this.selectedStyle,
    required this.onThemeChanged,
    required this.onStyleChanged,
  });

  bool get _isGlass =>
      selectedStyle !=
      AppThemeStyle.normal;

  bool get _isLightGlass =>
      selectedStyle ==
      AppThemeStyle.liquidGlassLight;

  bool get _isAurora =>
      selectedStyle ==
      AppThemeStyle.stellarAurora;

  Color get _accent =>
      AppTheme.colorOf(selectedTheme);

  Color _surfaceColor() {
    if (_isLightGlass) {
      return Colors.white.withOpacity(.34);
    }

    if (_isAurora) {
      return Colors.white.withOpacity(.055);
    }

    return Colors.white.withOpacity(.065);
  }

  Color _borderColor() {
    if (_isLightGlass) {
      return Colors.white.withOpacity(.58);
    }

    if (_isAurora) {
      return _accent.withOpacity(.24);
    }

    return Colors.white.withOpacity(.17);
  }

  Widget _auroraAtmosphere(BuildContext context) {
    if (!_isAurora) {
      return const SizedBox.shrink();
    }

    final secondary =
        Theme.of(context).colorScheme.secondary;

    final tertiary =
        Theme.of(context).colorScheme.tertiary;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _AuroraOrb(
              color: _accent,
              size: 310,
            ),
          ),
          Positioned(
            top: 250,
            left: -150,
            child: _AuroraOrb(
              color: secondary,
              size: 290,
            ),
          ),
          Positioned(
            top: 620,
            right: -130,
            child: _AuroraOrb(
              color: tertiary,
              size: 270,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
    EdgeInsetsGeometry margin =
        const EdgeInsets.only(
      bottom: 12,
    ),
    BorderRadiusGeometry radius =
        const BorderRadius.all(
      Radius.circular(24),
    ),
  }) {
    if (!_isGlass && !_isAurora) {
      return Card(
        margin: margin,
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: _isAurora
                ? _accent.withOpacity(.10)
                : Colors.black.withOpacity(
                    _isLightGlass
                        ? .07
                        : .25,
                  ),
            blurRadius:
                _isAurora ? 35 : 25,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isAurora ? 30 : 26,
            sigmaY: _isAurora ? 30 : 26,
          ),
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 450,
            ),
            curve:
                Curves.easeOutCubic,
            padding: padding,
            decoration: BoxDecoration(
              color: _surfaceColor(),
              borderRadius: radius,
              border: Border.all(
                color: _borderColor(),
              ),
              gradient:
                  LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: _isAurora
                    ? [
                        _accent
                            .withOpacity(.11),
                        Colors.white
                            .withOpacity(.035),
                        Colors.transparent,
                      ]
                    : [
                        _isLightGlass
                            ? Colors.white
                                .withOpacity(.72)
                            : Colors.white
                                .withOpacity(.12),
                        Colors.transparent,
                        _isLightGlass
                            ? Colors.white
                                .withOpacity(.10)
                            : Colors.white
                                .withOpacity(.02),
                      ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _themeButton(
    BuildContext context,
    AppThemeColor theme,
  ) {
    final selected =
        selectedTheme == theme;

    final color =
        AppTheme.colorOf(theme);

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${AppTheme.labelOf(theme)} tema',
      child: GestureDetector(
        onTap: () =>
            onThemeChanged(theme),
        child: AnimatedScale(
          scale: selected ? 1.0 : .97,
          duration:
              const Duration(
            milliseconds: 280,
          ),
          curve:
              Curves.easeOutBack,
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 360,
            ),
            curve:
                Curves.easeOutCubic,
            margin:
                const EdgeInsets.only(
              right: 9,
              bottom: 9,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? color.withOpacity(
                      _isLightGlass
                          ? .14
                          : .17,
                    )
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(30),
              border: Border.all(
                color: selected
                    ? color
                    : color.withOpacity(.45),
                width:
                    selected ? 1.8 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color
                            .withOpacity(.28),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),
                  width:
                      selected ? 12 : 9,
                  height:
                      selected ? 12 : 9,
                  decoration:
                      BoxDecoration(
                    color: color,
                    shape:
                        BoxShape.circle,
                    boxShadow:
                        selected
                            ? [
                                BoxShadow(
                                  color: color
                                      .withOpacity(
                                    .65,
                                  ),
                                  blurRadius:
                                      10,
                                ),
                              ]
                            : null,
                  ),
                ),
                const SizedBox(
                  width: 9,
                ),
                Text(
                  AppTheme.labelOf(
                    theme,
                  ),
                  style: TextStyle(
                    color: selected
                        ? color
                        : Theme.of(
                            context,
                          )
                            .colorScheme
                            .onSurface,
                    fontWeight:
                        selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                  ),
                ),
                ClipRect(
                  child:
                      AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 260,
                    ),
                    transitionBuilder:
                        (
                      child,
                      animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: selected
                        ? Padding(
                            key:
                                const ValueKey(
                              'check',
                            ),
                            padding:
                                const EdgeInsets
                                    .only(
                              left: 7,
                            ),
                            child:
                                Icon(
                              Icons
                                  .check_circle_rounded,
                              color:
                                  color,
                              size: 17,
                            ),
                          )
                        : const SizedBox(
                            key:
                                ValueKey(
                              'empty',
                            ),
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

  Widget _styleButton(
    BuildContext context,
    AppThemeStyle style,
    IconData icon,
    String title,
  ) {
    final selected =
        selectedStyle == style;

    final scheme =
        Theme.of(context).colorScheme;

    final accent = style ==
            AppThemeStyle.stellarAurora
        ? _accent
        : scheme.primary;

    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      radius:
          BorderRadius.circular(22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(22),
          onTap: () =>
              onStyleChanged(style),
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 360,
            ),
            curve:
                Curves.easeOutCubic,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(22),
              color: selected
                  ? accent.withOpacity(.08)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 350,
                  ),
                  curve:
                      Curves.easeOutBack,
                  width:
                      selected ? 47 : 43,
                  height:
                      selected ? 47 : 43,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: selected
                        ? accent.withOpacity(.17)
                        : Colors.white
                            .withOpacity(
                            .055,
                          ),
                    border: Border.all(
                      color: selected
                          ? accent
                              .withOpacity(
                              .45,
                            )
                          : Colors.transparent,
                    ),
                    boxShadow:
                        selected
                            ? [
                                BoxShadow(
                                  color:
                                      accent.withOpacity(
                                    .20,
                                  ),
                                  blurRadius:
                                      18,
                                ),
                              ]
                            : null,
                  ),
                  child:
                      AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),
                    child: Icon(
                      icon,
                      key: ValueKey(
                        '$style-$selected',
                      ),
                      color: selected
                          ? accent
                          : scheme
                              .onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child:
                      AnimatedDefaultTextStyle(
                    duration:
                        const Duration(
                      milliseconds: 260,
                    ),
                    style: TextStyle(
                      color:
                          scheme.onSurface,
                      fontSize: 15,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    child:
                        Text(title),
                  ),
                ),
                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 260,
                  ),
                  transitionBuilder:
                      (
                    child,
                    animation,
                  ) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    selected
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .chevron_right_rounded,
                    key: ValueKey(
                      selected,
                    ),
                    color: selected
                        ? accent
                        : scheme
                            .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final scheme =
        Theme.of(context).colorScheme;

    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: scheme.primary
                        .withOpacity(.10),
                  ),
                  child: Icon(
                    icon,
                    color:
                        scheme.primary,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 15.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons
                      .chevron_right_rounded,
                  color: scheme
                      .onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(
    BuildContext context,
  ) {
    final heroAsset =
        Platform.isLinux
            ? 'assets/StellarVerseSchool.png'
            : 'assets/StellarVerse.png';

    final secondary =
        Theme.of(context)
            .colorScheme
            .secondary;

    return _glassCard(
      context,
      padding: EdgeInsets.zero,
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),
      radius:
          BorderRadius.circular(30),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 500,
        ),
        constraints:
            const BoxConstraints(
          minHeight: 225,
        ),
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(30),
          gradient: LinearGradient(
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
            colors: _isAurora
                ? [
                    _accent
                        .withOpacity(.18),
                    secondary
                        .withOpacity(.08),
                    Colors.transparent,
                  ]
                : [
                    _accent
                        .withOpacity(
                      _isLightGlass
                          ? .18
                          : .13,
                    ),
                    Colors.white
                        .withOpacity(
                      _isLightGlass
                          ? .11
                          : .025,
                    ),
                    Colors.transparent,
                  ],
          ),
        ),
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            if (_isAurora)
              Positioned.fill(
                child:
                    IgnorePointer(
                  child: CustomPaint(
                    painter:
                        _AuroraGridPainter(
                      color:
                          _accent,
                    ),
                  ),
                ),
              ),
            AspectRatio(
              aspectRatio: 991 / 644,
              child: Image.asset(
                heroAsset,
                fit: BoxFit.contain,
                filterQuality:
                    FilterQuality.high,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Icon(
                    Icons
                        .auto_awesome_rounded,
                    size: 72,
                    color:
                        _accent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar:
          _isGlass || _isAurora,

      appBar: Platform.isAndroid
          ? null
          : AppBar(
              title: const Text(
                'Stellar Center',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              centerTitle: true,
              backgroundColor:
                  Colors.transparent,
              surfaceTintColor:
                  Colors.transparent,
              elevation: 0,
            ),

      body: Stack(
        children: [
          _auroraAtmosphere(),

          ListView(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            children: [
              _hero(context),

              Text(
                'Tema Rengi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      scheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Wrap(
                children:
                    AppThemeColor.values
                        .map(
                          (theme) =>
                              _themeButton(
                            context,
                            theme,
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Görünüm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      scheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _styleButton(
                context,
                AppThemeStyle.normal,
                Icons.palette_outlined,
                'Material Design',
              ),

              _styleButton(
                context,
                AppThemeStyle
                    .liquidGlassLight,
                Icons.light_mode_rounded,
                'Liquid Glass Light',
              ),

              _styleButton(
                context,
                AppThemeStyle
                    .liquidGlassDark,
                Icons.dark_mode_rounded,
                'Liquid Glass Dark',
              ),

              _styleButton(
                context,
                AppThemeStyle
                    .stellarAurora,
                Icons.auto_awesome_rounded,
                'Stellar Aurora',
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Araçlar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      scheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _toolButton(
                context,
                icon:
                    Icons.speed_rounded,
                title: 'Benchmark',
                subtitle:
                    'Cihaz performansını detaylı test et',
                onTap: () {
                  _openPage(
                    context,
                    const BenchmarkPage(),
                  );
                },
              ),

              _toolButton(
                context,
                icon:
                    Icons.storage_rounded,
                title:
                    'Storage Manager',
                subtitle:
                    'Depolama kullanımını incele',
                onTap: () {
                  _openPage(
                    context,
                    const StorageManagerPage(),
                  );
                },
              ),

              _toolButton(
                context,
                icon:
                    Icons.sensors_rounded,
                title: 'SensorLab',
                subtitle:
                    'Sensörleri incele',
                onTap: () {
                  _openPage(
                    context,
                    const SensorLabPage(),
                  );
                },
              ),

              _toolButton(
                context,
                icon: Icons
                    .network_check_rounded,
                title: 'Network Lab',
                subtitle:
                    'Ağ bağlantısını incele',
                onTap: () {
                  _openPage(
                    context,
                    const NetworkLabPage(),
                  );
                },
              ),

              _toolButton(
                context,
                icon: Icons
                    .battery_full_rounded,
                title: 'Battery Lab',
                subtitle:
                    'Pil durumunu incele',
                onTap: () {
                  _openPage(
                    context,
                    const BatteryLabPage(),
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Güncelleme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      scheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _glassCard(
                context,
                child:
                    const UpdateButton(
                  currentVersion:
                      AppVersion.current,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Stellar Center',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: scheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Linux • v${AppVersion.current}',
                      style:
                          TextStyle(
                        color: scheme
                            .onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuroraOrb
    extends StatelessWidget {
  final Color color;
  final double size;

  const _AuroraOrb({
    required this.color,
    required this.size,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ImageFiltered(
      imageFilter:
          ImageFilter.blur(
        sigmaX: 70,
        sigmaY: 70,
      ),
      child: Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,
          color:
              color.withOpacity(.11),
        ),
      ),
    );
  }
}

class _AuroraGridPainter
    extends CustomPainter {
  final Color color;

  _AuroraGridPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color =
          color.withOpacity(.055)
      ..strokeWidth = .7
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;

    for (
      double x = 0;
      x <= size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (
      double y = 0;
      y <= size.height;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(.13),
          color.withOpacity(0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .72,
            size.height * .28,
          ),
          radius: 170,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .72,
        size.height * .28,
      ),
      170,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AuroraGridPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
