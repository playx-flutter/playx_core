import 'package:shared_preferences/shared_preferences.dart';

class PlayxPrefsSettings {
  /// If true, it will create a PlayxPrefs instance on boot
  final bool createPlayxPrefs;

  /// If true, it will create a PlayxAsyncPrefs instance on boot
  final bool createPlayxAsyncPrefs;

  /// If true, it will create a PlayxPrefsWithCache instance on boot
  final bool createPlayxPrefsWithCache;

  /// Options for [SharedPreferencesWithCache]
  final SharedPreferencesWithCacheOptions prefsWithCacheOptions;

  const PlayxPrefsSettings({
    this.createPlayxPrefs = true,
    this.createPlayxAsyncPrefs = true,
    this.createPlayxPrefsWithCache = false,
    this.prefsWithCacheOptions = const SharedPreferencesWithCacheOptions(),
  });
}
