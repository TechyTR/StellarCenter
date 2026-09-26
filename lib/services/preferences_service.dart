import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeColorKey = 'theme_color';
  static const String _themeStyleKey = 'theme_style';

  static Future<String> getThemeColor() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_themeColorKey) ?? 'purple';
  }

  static Future<void> saveThemeColor(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeColorKey,
      value,
    );
  }

  static Future<String> getThemeStyle() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_themeStyleKey) ?? 'normal';
  }

  static Future<void> saveThemeStyle(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeStyleKey,
      value,
    );
  }

  static Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey('stellar_password_hash');
  }

  static Future<void> savePasswordHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'stellar_password_hash',
      hash,
    );
  }

  static Future<String?> getPasswordHash() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('stellar_password_hash');
  }

  static Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('stellar_password_hash');
  }
}
