import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../pages/boot_screen.dart';
import '../services/preferences_service.dart';
import '../services/locale_service.dart';
import '../both/theme/app_theme.dart';

typedef HomeShellBuilder = Widget Function({
  required AppThemeColor selectedTheme,
  required AppThemeStyle selectedStyle,
  required Future<void> Function(AppThemeColor) onThemeChanged,
  required Future<void> Function(AppThemeStyle) onStyleChanged,
});

class StellarCenterApp extends StatefulWidget {
  final HomeShellBuilder homeShellBuilder;

  const StellarCenterApp({super.key, required this.homeShellBuilder});

  @override
  State<StellarCenterApp> createState() => _StellarCenterAppState();
}

class _StellarCenterAppState extends State<StellarCenterApp> {
  AppThemeColor _selectedTheme = AppThemeColor.purple;
  AppThemeStyle _selectedStyle = AppThemeStyle.normal;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    LocaleService.load();
  }

  Future<void> _loadPreferences() async {
    final colorValue = await PreferencesService.getThemeColor();
    final styleValue = await PreferencesService.getThemeStyle();
    if (!mounted) return;
    setState(() {
      _selectedTheme = AppTheme.colorFromString(colorValue);
      _selectedStyle = AppTheme.styleFromString(styleValue);
      _preferencesLoaded = true;
    });
  }

  Future<void> _changeTheme(AppThemeColor color) async {
    setState(() => _selectedTheme = color);
    await PreferencesService.saveThemeColor(AppTheme.colorToString(color));
  }

  Future<void> _changeStyle(AppThemeStyle style) async {
    setState(() => _selectedStyle = style);
    await PreferencesService.saveThemeStyle(AppTheme.styleToString(style));
  }

  @override
  Widget build(BuildContext context) {
    if (!_preferencesLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleService.locale,
      builder: (context, locale, child) => MaterialApp(
      locale: locale,
      title: 'Stellar Center',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(_selectedTheme, _selectedStyle),
      home: BootScreen(
        selectedTheme: _selectedTheme,
        selectedStyle: _selectedStyle,
        onThemeChanged: _changeTheme,
        onStyleChanged: _changeStyle,
        homeShellBuilder: widget.homeShellBuilder,
      ),
    ),
    );
  }
}
