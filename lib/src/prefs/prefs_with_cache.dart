import 'package:shared_preferences/shared_preferences.dart';

/// Provides a persistent store for simple data with caching capabilities.
///
/// This class is a wrapper around [SharedPreferencesWithCache], allowing for synchronous
/// data retrieval through a cache. It provides methods for storing and retrieving
/// various data types such as `String`, `int`, `double`, and `bool`.
///
/// If preferences on the platform may be altered by other means than through
/// this instance, consider using [PlayxAsyncPrefs] instead. You may also
/// refresh the cached data using [reloadCache] prior to a get request to prevent
/// missed changes that may have occurred since the cache was last updated.
abstract class PlayxPrefsWithCache {
  // Private constructor to prevent instantiation.
  PlayxPrefsWithCache._();

  // Private field to hold the instance of SharedPreferencesWithCache.
  static SharedPreferencesWithCache? _sharedPrefs;

  /// Getter for the [SharedPreferencesWithCache] instance.
  ///
  /// Throws an exception if [create()] has not been called to initialize the
  /// [SharedPreferencesWithCache] instance.
  static SharedPreferencesWithCache get sharedPrefs {
    if (_sharedPrefs == null) {
      throw Exception(
          'SharedPreferencesWithCache is not initialized. Please call create() first.');
    }
    return _sharedPrefs!;
  }

  /// Creates a new instance of [SharedPreferencesWithCache] with the given
  /// [options] and reloads the cache from the platform data.
  ///
  /// This method must be called before accessing [sharedPrefs].
  ///
  /// - [options]: The options to configure the cache behavior.
  static Future<SharedPreferencesWithCache> create({
    SharedPreferencesWithCacheOptions options =
        const SharedPreferencesWithCacheOptions(),
  }) async {
    _sharedPrefs =
        await SharedPreferencesWithCache.create(cacheOptions: options);
    return _sharedPrefs!;
  }

  /***************************String***************************/

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs.
  ///
  /// - [key]: The key of the value to retrieve.
  static String? maybeGetString(
    String key,
  ) {
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
  static String getString(
    String key, {
    String fallback = '',
  }) =>
      maybeGetString(key) ?? fallback;

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
  static int? maybeGetInt(
    String key,
  ) {
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
  static int getInt(
    String key, {
    int fallback = -1,
  }) =>
      maybeGetInt(key) ?? fallback;

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
  static double? maybeGetDouble(
    String key,
  ) {
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
  static double getDouble(
    String key, {
    double fallback = -1,
  }) =>
      maybeGetDouble(key) ?? fallback;

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
  static bool? maybeGetBool(
    String key,
  ) {
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
  static bool getBool(
    String key, {
    bool fallback = false,
  }) =>
      maybeGetBool(key) ?? fallback;

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
  static Object? find(
    String key,
  ) =>
      sharedPrefs.get(key);

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

  /// Updates the cache with the latest values from the platform.
  ///
  /// This should be called before reading any values if the values may have
  /// been changed by anything other than this cache instance,
  /// such as from another isolate or native code that changes the underlying
  /// preference storage directly.
  static Future<void> reloadCache() => sharedPrefs.reloadCache();

  /// Disposes the [SharedPreferencesWithCache] instance.
  ///
  /// Call this method when you want to reset the preferences instance.
  static Future<void> dispose() async {
    _sharedPrefs = null;
  }
}
