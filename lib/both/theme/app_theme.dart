import 'package:flutter/material.dart';

enum AppThemeColor {
  purple,
  blue,
  green,
  orange,
  red,
  pink,
  yellow,
  brown,
}

enum AppThemeStyle {
  normal,
  liquidGlassLight,
  liquidGlassDark,
  stellarAurora,
}

extension AppThemeColorExtension
    on AppThemeColor {
  Color get seed {
    switch (this) {
      case AppThemeColor.purple:
        return const Color(0xFF8B5CF6);
      case AppThemeColor.blue:
        return const Color(0xFF3B82F6);
      case AppThemeColor.green:
        return const Color(0xFF22C55E);
      case AppThemeColor.orange:
        return const Color(0xFFF97316);
      case AppThemeColor.red:
        return const Color(0xFFEF4444);
      case AppThemeColor.pink:
        return const Color(0xFFEC4899);
      case AppThemeColor.yellow:
        return const Color(0xFFEAB308);
      case AppThemeColor.brown:
        return const Color(0xFFA16207);
    }
  }

  String get label {
    switch (this) {
      case AppThemeColor.purple:
        return 'Mor';
      case AppThemeColor.blue:
        return 'Mavi';
      case AppThemeColor.green:
        return 'Yeşil';
      case AppThemeColor.orange:
        return 'Turuncu';
      case AppThemeColor.red:
        return 'Kırmızı';
      case AppThemeColor.pink:
        return 'Pembe';
      case AppThemeColor.yellow:
        return 'Sarı';
      case AppThemeColor.brown:
        return 'Kahverengi';
    }
  }
}

class AppTheme {
  static ThemeData build(
    AppThemeColor color,
    AppThemeStyle style,
  ) {
    switch (style) {
      case AppThemeStyle.normal:
        return _normal(color);

      case AppThemeStyle.liquidGlassLight:
        return _liquidGlassLight(color);

      case AppThemeStyle.liquidGlassDark:
        return _liquidGlassDark(color);

      case AppThemeStyle.stellarAurora:
        return _stellarAurora(color);
    }
  }

  static ThemeData _normal(
    AppThemeColor color,
  ) {
    final scheme = ColorScheme.fromSeed(
      seedColor: color.seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          const Color(0xFF101010),
      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF181818),
        elevation: 0,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
      ),
      dividerTheme:
          DividerThemeData(
        color:
            color.seed.withOpacity(.16),
      ),
      inputDecorationTheme:
          _inputTheme(
        color,
        false,
      ),
      filledButtonTheme:
          FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
          backgroundColor:
              color.seed,
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static ThemeData _liquidGlassLight(
    AppThemeColor color,
  ) {
    final scheme = ColorScheme.fromSeed(
      seedColor: color.seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          const Color(0xFFF3F4F8),
      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
      ),
      cardTheme: CardTheme(
        color:
            Colors.white.withOpacity(.40),
        surfaceTintColor:
            Colors.white.withOpacity(.10),
        elevation: 0,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
          side: BorderSide(
            color:
                Colors.white.withOpacity(.55),
          ),
        ),
      ),
      dividerTheme:
          DividerThemeData(
        color:
            color.seed.withOpacity(.16),
      ),
      inputDecorationTheme:
          _inputTheme(
        color,
        true,
      ),
      filledButtonTheme:
          FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
          backgroundColor:
              color.seed,
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static ThemeData _liquidGlassDark(
    AppThemeColor color,
  ) {
    final scheme = ColorScheme.fromSeed(
      seedColor: color.seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          const Color(0xFF08090D),
      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
      ),
      cardTheme: CardTheme(
        color:
            Colors.white.withOpacity(.065),
        surfaceTintColor:
            Colors.white.withOpacity(.025),
        elevation: 0,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
          side: BorderSide(
            color:
                Colors.white.withOpacity(.17),
          ),
        ),
      ),
      dividerTheme:
          DividerThemeData(
        color:
            Colors.white.withOpacity(.10),
      ),
      inputDecorationTheme:
          _inputTheme(
        color,
        false,
      ),
      filledButtonTheme:
          FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
          backgroundColor:
              color.seed,
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static ThemeData _stellarAurora(
    AppThemeColor color,
  ) {
    final primary = color.seed;
    final secondary =
        _auroraSecondary(color);
    final tertiary =
        _auroraTertiary(color);

    final scheme =
        ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface:
          const Color(0xFF0B0D18),
      surfaceContainerHighest:
          const Color(0xFF171A2A),
      outline:
          primary.withOpacity(.28),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          const Color(0xFF050711),
      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
      ),
      cardTheme: CardTheme(
        color:
            Colors.white.withOpacity(.055),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        shadowColor:
            primary.withOpacity(.22),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(26),
          side: BorderSide(
            color:
                primary.withOpacity(.24),
          ),
        ),
      ),
      dividerTheme:
          DividerThemeData(
        color:
            primary.withOpacity(.15),
        thickness: .7,
      ),
      inputDecorationTheme:
          _inputTheme(
        color,
        false,
        aurora: true,
      ),
      filledButtonTheme:
          FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
          backgroundColor:
              primary,
          foregroundColor:
              Colors.white,
          elevation: 0,
          shadowColor:
              primary.withOpacity(.40),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
        ),
      ),
      navigationBarTheme:
          NavigationBarThemeData(
        backgroundColor:
            const Color(0xCC080A13),
        indicatorColor:
            primary.withOpacity(.22),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor:
            primary.withOpacity(.12),
      ),
      sliderTheme:
          SliderThemeData(
        activeTrackColor:
            primary,
        inactiveTrackColor:
            primary.withOpacity(.15),
        thumbColor:
            Colors.white,
        overlayColor:
            primary.withOpacity(.16),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(
    AppThemeColor color,
    bool light, {
    bool aurora = false,
  }) {
    final borderColor = aurora
        ? color.seed.withOpacity(.22)
        : light
            ? Colors.white.withOpacity(.48)
            : Colors.white.withOpacity(.14);

    return InputDecorationTheme(
      filled: true,
      fillColor: aurora
          ? Colors.white.withOpacity(.045)
          : light
              ? Colors.white.withOpacity(.30)
              : Colors.white.withOpacity(.055),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(20),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(20),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(20),
        borderSide: BorderSide(
          color:
              color.seed.withOpacity(
            aurora ? .82 : .60,
          ),
          width:
              aurora ? 1.6 : 1.3,
        ),
      ),
    );
  }

  static Color _auroraSecondary(
    AppThemeColor color,
  ) {
    switch (color) {
      case AppThemeColor.purple:
        return const Color(0xFF22D3EE);
      case AppThemeColor.blue:
        return const Color(0xFF8B5CF6);
      case AppThemeColor.green:
        return const Color(0xFF06B6D4);
      case AppThemeColor.orange:
        return const Color(0xFFF43F5E);
      case AppThemeColor.red:
        return const Color(0xFFFF7A59);
      case AppThemeColor.pink:
        return const Color(0xFFA855F7);
      case AppThemeColor.yellow:
        return const Color(0xFF22D3EE);
      case AppThemeColor.brown:
        return const Color(0xFFF59E0B);
    }
  }

  static Color _auroraTertiary(
    AppThemeColor color,
  ) {
    switch (color) {
      case AppThemeColor.purple:
        return const Color(0xFFF472B6);
      case AppThemeColor.blue:
        return const Color(0xFF38BDF8);
      case AppThemeColor.green:
        return const Color(0xFF84CC16);
      case AppThemeColor.orange:
        return const Color(0xFFFACC15);
      case AppThemeColor.red:
        return const Color(0xFFFB7185);
      case AppThemeColor.pink:
        return const Color(0xFFF0ABFC);
      case AppThemeColor.yellow:
        return const Color(0xFFFDE047);
      case AppThemeColor.brown:
        return const Color(0xFFFBBF24);
    }
  }

  static AppThemeColor colorFromString(
    String value,
  ) {
    return AppThemeColor.values.firstWhere(
      (item) => item.name == value,
      orElse: () =>
          AppThemeColor.purple,
    );
  }

  static String colorToString(
    AppThemeColor color,
  ) {
    return color.name;
  }

  static AppThemeStyle styleFromString(
    String value,
  ) {
    return AppThemeStyle.values.firstWhere(
      (item) => item.name == value,
      orElse: () =>
          AppThemeStyle.normal,
    );
  }

  static String styleToString(
    AppThemeStyle style,
  ) {
    return style.name;
  }

  static Color colorOf(
    AppThemeColor color,
  ) {
    return color.seed;
  }

  static String labelOf(
    AppThemeColor color,
  ) {
    return color.label;
  }

  static String styleLabelOf(
    AppThemeStyle style,
  ) {
    switch (style) {
      case AppThemeStyle.normal:
        return 'Material Design';
      case AppThemeStyle.liquidGlassLight:
        return 'Liquid Glass Light';
      case AppThemeStyle.liquidGlassDark:
        return 'Liquid Glass Dark';
      case AppThemeStyle.stellarAurora:
        return 'Stellar Aurora';
    }
  }
}
