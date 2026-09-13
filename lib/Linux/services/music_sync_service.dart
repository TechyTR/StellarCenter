import 'package:shared_preferences/shared_preferences.dart';

class MusicSyncService {
  const MusicSyncService();

  String _key(String path) {
    return 'music_sync_offset_${path.hashCode}';
  }

  Future<Duration> getOffset(
    String path,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final milliseconds =
        prefs.getInt(_key(path)) ?? 0;

    return Duration(
      milliseconds: milliseconds,
    );
  }

  Future<void> setOffset(
    String path,
    Duration offset,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      _key(path),
      offset.inMilliseconds,
    );
  }

  Future<void> addOffset(
    String path,
    Duration amount,
  ) async {
    final current =
        await getOffset(path);

    await setOffset(
      path,
      current + amount,
    );
  }

  Future<void> reset(
    String path,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key(path));
  }
}
