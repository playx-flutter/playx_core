import '../../playx_core.dart';

/// Wrapper for handling secure preferences to save and get preferences.
///
/// This class provides a secure storage solution for key-value pairs using
/// [FlutterSecureStorage]. It supports storing and retrieving data of types
/// `String`, `int`, `double`, and `bool` securely, with the data being encrypted
/// and decrypted as needed.
///
/// The class includes methods for creating the secure storage instance, setting,
/// getting, and removing preferences, and clearing all stored data. It also
/// provides functionality to clear the secure storage on app reinstall.
abstract class PlayxSecurePrefs {
  static FlutterSecureStorage? _securePrefs;

  /// Getter for the [FlutterSecureStorage] instance.
  ///
  /// Throws an exception if [create()] has not been called to initialize the
  /// [FlutterSecureStorage] instance.
  static FlutterSecureStorage get securePrefs {
    if (_securePrefs == null) {
      throw Exception(
          'FlutterSecureStorage is not initialized. Please call create() first.');
    }
    return _securePrefs!;
  }

  /// Creates a new instance of [FlutterSecureStorage] with the given settings.
  ///
  /// - [securePrefsSettings]: The settings to configure the secure storage behavior.
  /// - If [clearOnReinstall] is set to `true`, the storage is cleared on app reinstall.
  static Future<FlutterSecureStorage> create({
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
  }) async {
    _securePrefs = FlutterSecureStorage(
      iOptions: securePrefsSettings.iosOptions,
      aOptions: securePrefsSettings.androidOptions,
      lOptions: securePrefsSettings.linuxOptions,
      wOptions: securePrefsSettings.windowsOptions,
      webOptions: securePrefsSettings.webOptions,
      mOptions: securePrefsSettings.macOsOptions,
    );
    if (securePrefsSettings.clearOnReinstall) {
      await PlayxSecurePrefs.clearOnReinstall();
    }
    return _securePrefs!;
  }

  static const String _hasRunBefore = 'hasRunBefore';

  /***************************String***************************/

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns `null` if the key does not exist.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<String?> maybeGetString(String key) async =>
      await securePrefs.read(key: key);

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns [fallback] (default is an empty string) if the key does not exist.
  ///
  /// - [key]: The key of the value to retrieve.
  /// - [fallback]: The value to return if the key does not exist.
  static Future<String> getString(String key, {String fallback = ''}) async =>
      await maybeGetString(key) ?? fallback;

  /// Sets the value associated with the given [key] as a `String`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `String` value to store.
  static Future<void> setString(
    String key,
    String value,
  ) =>
      securePrefs.write(key: key, value: value);

  /***************************int***************************/

  /// Retrieves the value associated with the given [key] as an `int`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<int?> maybeGetInt(String key) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return int.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the value associated with the given [key] as an `int`.
  ///
  /// Returns [fallback] (default is `-1`) if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  /// - [fallback]: The value to return if the key does not exist or an error occurs.
  static Future<int> getInt(String key, {int fallback = -1}) async =>
      await maybeGetInt(key) ?? fallback;

  /// Sets the value associated with the given [key] as an `int`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `int` value to store.
  static Future<void> setInt(
    String key,
    int value,
  ) =>
      setString(key, value.toString());

  /***************************double***************************/

  /// Retrieves the value associated with the given [key] as a `double`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<double?> maybeGetDouble(String key) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return double.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the value associated with the given [key] as a `double`.
  ///
  /// Returns [fallback] (default is `-1`) if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  /// - [fallback]: The value to return if the key does not exist or an error occurs.
  static Future<double> getDouble(String key, {double fallback = -1}) async =>
      await maybeGetDouble(key) ?? fallback;

  /// Sets the value associated with the given [key] as a `double`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `double` value to store.
  static Future<void> setDouble(
    String key,
    double value,
  ) =>
      setString(key, value.toString());

  /***************************bool***************************/

  /// Retrieves the value associated with the given [key] as a `bool`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<bool?> maybeGetBool(String key) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return value.toLowerCase() == 'true' || value.toLowerCase() == '1';
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the value associated with the given [key] as a `bool`.
  ///
  /// Returns [fallback] (default is `false`) if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  /// - [fallback]: The value to return if the key does not exist or an error occurs.
  static Future<bool> getBool(String key, {bool fallback = false}) async =>
      await maybeGetBool(key) ?? fallback;

  /// Sets the value associated with the given [key] as a `bool`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `bool` value to store.
  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      setString(key, value.toString());

  /***************************General***************************/

  /// Clears all data in the secure preferences.
  ///
  /// This removes all key-value pairs stored in the secure storage.
  static Future<void> clear() => securePrefs.deleteAll();

  /// Removes the value associated with the given [key].
  ///
  /// - [key]: The key of the value to remove.
  static Future<void> remove(String key) => securePrefs.delete(key: key);

  /// Clears Secure Storage on Reinstall.
  ///
  /// This method is used to clear the secure storage when the app is reinstalled.
  /// As the secure storage is not cleared on app reinstall on iOS, this method
  /// ensures that secure storage is cleared if the app is being run for the
  /// first time after reinstalling.
  static Future<void> clearOnReinstall() async {
    if (!PlayxPrefs.getBool(_hasRunBefore)) {
      await clear();
      PlayxPrefs.setBool(_hasRunBefore, true);
    }
  }
}
