import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's language choice. A null locale follows the device language.
class LocaleService {
  LocaleService._();

  static const _preferenceKey = 'app_locale';
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static const supportedLanguageNames = <String, String>{
    'system': 'System default',
    'tr': 'Türkçe',
    'en': 'English',
    'it': 'Italiano',
    'es': 'Español',
    'fr': 'Français',
    'ja': '日本語',
    'zh': '简体中文',
    'ar': 'العربية',
    'ru': 'Русский',
    'de': 'Deutsch',
  };

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_preferenceKey);
    locale.value = code == null || code == 'system' ? null : Locale(code);
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, code);
    locale.value = code == 'system' ? null : Locale(code);
  }

  static String get selectedCode => locale.value?.languageCode ?? 'system';
}
