import '../../playx_core.dart';

///Wrapper for handling secure preferences to save and get preferences.
abstract class PlayxSecurePrefs {
  static FlutterSecureStorage get instance => Get.find<FlutterSecureStorage>();

  static const String _hasRunBefore = 'hasRunBefore';

  /// return the secure preferences value in [String] else returns null.
  static Future<String?> maybeGetString(String key) async =>
      await instance.read(
        key: key,
      );

  /// return the secure preferences value in [String] else returns [fallback] which default to empty String.
  static Future<String> getString(String key, {String fallback = ''}) async =>
      await maybeGetString(key) ?? fallback;

  /// Set the secure preferences value in [String].
  static Future<void> setString(
    String key,
    String value,
  ) =>
      instance.write(key: key, value: value);

  /// return the secure preferences value in [int] else returns null.
  static Future<int?> maybeGetInt(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return int.parse(value);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the secure preferences value in [int] else returns [fallback] which default to -1.
  static Future<int> getInt(String key, {int fallback = -1}) async =>
      await maybeGetInt(key) ?? fallback;

  /// Set the secure preferences value in [int].
  static Future<void> setInt(
    String key,
    int value,
  ) =>
      setString(key, value.toString());

  /// return the secure preferences value in [double] else returns null.
  static Future<double?> maybeGetDouble(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return double.parse(value);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the secure preferences value in [double] else returns [fallback] which default to -1.
  static Future<double> getDouble(String key, {double fallback = -1}) async =>
      await maybeGetDouble(key) ?? fallback;

  /// Set the secure preferences value in [double].
  static Future<void> setDouble(
    String key,
    double value,
  ) =>
      setString(key, value.toString());

  /// return the secure preferences value in [bool] else returns defaultValue.
  static Future<bool?> maybeGetBool(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return value.toLowerCase() == 'true' || value.toLowerCase() == '1';
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the secure preferences value in [bool] else returns [fallback] which default to false.
  static Future<bool> getBool(String key, {bool fallback = false}) async =>
      await maybeGetBool(key) ?? fallback;

  /// Set the secure preferences value in [bool].
  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      setString(key, value.toString());

  /// clear the preferences
  static Future<void> clear() => instance.deleteAll();

  /// remove the given preferences key
  static Future<void> remove(
    String key,
  ) =>
      instance.delete(key: key);

  /// Clears Secure Storage On Reinstall
  /// This method is used to clear the secure storage when the app is reinstalled.
  /// As the secure storage is not cleared on app reinstall on ios.
  static Future<void> clearOnReinstall() async {
    if (!PlayxPrefs.getBool(_hasRunBefore)) {
      await clear();
      PlayxPrefs.setBool(_hasRunBefore, true);
    }
  }
}
