import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper for handling shared preferences to save and retrieve data.
///
/// This class provides an easy interface for storing and retrieving primitive
/// data types such as `String`, `int`, `double`, and `bool` in shared preferences.
/// It also includes methods to clear and remove specific preferences.
///
/// This class will be deprecated in the future in favor of [PlayxAsyncPrefs] and [PlayxPrefsWithCache].
abstract class PlayxPrefs {
  // Private constructor to prevent instantiation.
  PlayxPrefs._();

  static SharedPreferences? _sharedPrefs;

  /// Returns the initialized `SharedPreferences` instance.
  ///
  /// Throws an [Exception] if the instance has not been created using [create].
  static SharedPreferences get sharedPrefs {
    if (_sharedPrefs == null) {
      throw Exception(
          'SharedPreferences is not initialized. Please call create() first.');
    }
    return _sharedPrefs!;
  }

  /// Initializes the [SharedPreferences] instance.
  ///
  /// This method must be called before attempting to access shared preferences.
  static Future<SharedPreferences> create() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs!;
  }

  /// Sets mock initial values for testing purposes.
  ///
  /// This method is marked as `protected` and is only visible for testing.
  @protected
  @visibleForTesting
  static void setMockInitialValues(
    Map<String, Object> values,
  ) =>
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(values);

  /*************************** String ***************************/

  /// Returns the shared preferences value for the given [key] as a `String`,
  /// or `null` if it doesn't exist.
  static String? maybeGetString(String key) {
    try {
      return sharedPrefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// Returns the shared preferences value for the given [key] as a `String`,
  /// or [fallback] (defaults to an empty string) if it doesn't exist.
  static String getString(String key, {String fallback = ''}) =>
      maybeGetString(key) ?? fallback;

  /// Sets the shared preferences value for the given [key] to the provided [value] of type `String`.
  static Future<void> setString(String key, String value) =>
      sharedPrefs.setString(key, value);

  /*************************** int ***************************/

  /// Returns the shared preferences value for the given [key] as an `int`,
  /// or `null` if it doesn't exist.
  static int? maybeGetInt(String key) {
    try {
      return sharedPrefs.getInt(key);
    } catch (_) {
      return null;
    }
  }

  /// Returns the shared preferences value for the given [key] as a non-null `int`,
  /// or [fallback] (defaults to -1) if it doesn't exist.
  static int getInt(String key, {int fallback = -1}) =>
      maybeGetInt(key) ?? fallback;

  /// Sets the shared preferences value for the given [key] to the provided [value] of type `int`.
  static Future<void> setInt(String key, int value) =>
      sharedPrefs.setInt(key, value);

  /*************************** double ***************************/

  /// Returns the shared preferences value for the given [key] as a `double`,
  /// or `null` if it doesn't exist.
  static double? maybeGetDouble(String key) {
    try {
      return sharedPrefs.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  /// Returns the shared preferences value for the given [key] as a non-null `double`,
  /// or [fallback] (defaults to -1.0) if it doesn't exist.
  static double? getDouble(String key, {double fallback = -1}) =>
      maybeGetDouble(key) ?? fallback;

  /// Sets the shared preferences value for the given [key] to the provided [value] of type `double`.
  static Future<void> setDouble(String key, double value) =>
      sharedPrefs.setDouble(key, value);

  /*************************** bool ***************************/

  /// Returns the shared preferences value for the given [key] as a `bool`,
  /// or `null` if it doesn't exist.
  static bool? maybeGetBool(String key) {
    try {
      return sharedPrefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  /// Returns the shared preferences value for the given [key] as a non-null `bool`,
  /// or [fallback] (defaults to `false`) if it doesn't exist.
  static bool getBool(String key, {bool fallback = false}) =>
      maybeGetBool(key) ?? fallback;

  /// Sets the shared preferences value for the given [key] to the provided [value] of type `bool`.
  static Future<void> setBool(String key, bool value) =>
      sharedPrefs.setBool(key, value);

  /*************************** Other Methods ***************************/

  /// Returns the shared preferences value for the given [key] as an `Object`,
  /// or `null` if it doesn't exist.
  static Object? find(String key) => sharedPrefs.get(key);

  /// Clears all stored preferences.
  static Future<void> clear() => sharedPrefs.clear();

  /// Removes the preference with the given [key].
  static Future<void> remove(String key) => sharedPrefs.remove(key);

  /// Disposes the `SharedPreferences` instance`.
  ///
  /// Call this method when you want to reset the preferences instance.
  static Future<void> dispose() async {
    _sharedPrefs = null;
  }
}
