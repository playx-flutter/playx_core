import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An abstract class that provides an asynchronous interface for accessing
/// and manipulating SharedPreferences data.
///
/// This class encapsulates methods for storing and retrieving various data
/// types such as `String`, `int`, `double`, and `bool` using a shared preferences
/// instance, which is managed asynchronously.
abstract class PlayxAsyncPrefs {
  // Private constructor to prevent instantiation.
  PlayxAsyncPrefs._();

  // Private field to hold the instance of SharedPreferencesAsync.
  static SharedPreferencesAsync? _sharedPrefs;

  /// Getter for the [SharedPreferencesAsync] instance.
  ///
  /// Throws an exception if `create()` has not been called to initialize the
  /// SharedPreferencesAsync instance.
  static SharedPreferencesAsync get sharedPrefs {
    if (_sharedPrefs == null) {
      throw Exception(
          'SharedPreferencesAsync is not initialized. Please call create() first.');
    }
    return _sharedPrefs!;
  }

  /// Initializes and returns a new instance of [SharedPreferencesAsync].
  ///
  /// This method must be called before accessing [sharedPrefs].
  static Future<SharedPreferencesAsync> create() async {
    try {
      _sharedPrefs = SharedPreferencesAsync();
    } catch (e) {
      rethrow;
    }
    return _sharedPrefs!;
  }

  /// Sets mock initial values for testing purposes.
  ///
  /// This method is protected and visible only for testing, allowing
  /// the setup of mock values in SharedPreferences.
  ///
  /// - [values]: A map of key-value pairs to set as the initial values.
  @protected
  @visibleForTesting
  static void setMockInitialValues(
    Map<String, Object> values,
  ) =>
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(values);

  /***************************String***************************/

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<String?> maybeGetString(
    String key,
  ) async {
    try {
      return sharedPrefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns [fallback] (default is an empty string) if the key does not exist
  /// or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  /// - [fallback]: The value to return if the key does not exist or an error occurs.
  static Future<String> getString(
    String key, {
    String fallback = '',
  }) async =>
      (await maybeGetString(key)) ?? fallback;

  /// Sets the value associated with the given [key] as a `String`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `String` value to store.
  static Future<void> setString(
    String key,
    String value,
  ) =>
      sharedPrefs.setString(key, value);

  /***************************int***************************/

  /// Retrieves the value associated with the given [key] as an `int`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<int?> maybeGetInt(
    String key,
  ) async {
    try {
      return sharedPrefs.getInt(key);
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
  static Future<int> getInt(
    String key, {
    int fallback = -1,
  }) async =>
      (await maybeGetInt(key)) ?? fallback;

  /// Sets the value associated with the given [key] as an `int`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `int` value to store.
  static Future<void> setInt(
    String key,
    int value,
  ) =>
      sharedPrefs.setInt(key, value);

  /***************************double***************************/

  /// Retrieves the value associated with the given [key] as a `double`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<double?> maybeGetDouble(
    String key,
  ) async {
    try {
      return sharedPrefs.getDouble(key);
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
  static Future<double> getDouble(
    String key, {
    double fallback = -1,
  }) async =>
      (await maybeGetDouble(key)) ?? fallback;

  /// Sets the value associated with the given [key] as a `double`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `double` value to store.
  static Future<void> setDouble(
    String key,
    double value,
  ) =>
      sharedPrefs.setDouble(key, value);

  /***************************bool***************************/

  /// Retrieves the value associated with the given [key] as a `bool`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<bool?> maybeGetBool(
    String key,
  ) async {
    try {
      return sharedPrefs.getBool(key);
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
  static Future<bool> getBool(
    String key, {
    bool fallback = false,
  }) async =>
      (await maybeGetBool(key)) ?? fallback;

  /// Sets the value associated with the given [key] as a `bool`.
  ///
  /// - [key]: The key under which the value will be stored.
  /// - [value]: The `bool` value to store.
  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      sharedPrefs.setBool(key, value);

  /// Finds and returns the value associated with the given [key] as an `Object`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<Object?> find(
    String key,
  ) async {
    try {
      final map = await sharedPrefs.getAll(allowList: {key});
      return map[key];
    } catch (_) {
      return null;
    }
  }

  /// Clears all data in the shared preferences.
  ///
  /// This removes all key-value pairs stored in the shared preferences.
  static Future<void> clear() => sharedPrefs.clear();

  /// Removes the value associated with the given [key].
  ///
  /// - [key]: The key of the value to remove.
  static Future<void> remove(
    String key,
  ) =>
      sharedPrefs.remove(key);

  /// Disposes the [SharedPreferencesAsync] instance.
  ///
  /// Call this method when you want to reset the preferences instance.
  static Future<void> dispose() async {
    _sharedPrefs = null;
  }
}
