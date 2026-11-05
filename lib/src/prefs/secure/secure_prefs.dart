import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/safe_convert.dart';
import 'backends/encrypted_prefs_backend.dart';
import 'backends/flutter_secure_storage_backend.dart';
import 'backends/memory_secure_storage_backend.dart';
import 'backends/secure_storage_backend.dart';
import 'secure_log.dart';
import 'secure_storage_factory.dart';
import 'settings/secure_prefs_settings.dart';
import '../../utils/json_value_codec.dart';

/// Wrapper for handling secure preferences to save and get preferences.
///
/// This class provides a secure storage solution for key-value pairs. It
/// supports storing and retrieving data of types `String`, `int`, `double`,
/// and `bool` securely.
///
/// The storage backend is selected with [PlayxSecurePrefsSettings.storageType]:
/// - [PlayxSecureStorageType.flutterSecureStorage] (default): `flutter_secure_storage`.
/// - [PlayxSecureStorageType.simpleSecureStorage]: `simple_secure_storage`.
/// - [PlayxSecureStorageType.encryptedPrefs]: AES-GCM encrypted `SharedPreferencesAsync`.
/// - [PlayxSecureStorageType.auto]: the first healthy backend of
///   [PlayxSecurePrefsSettings.autoOrder].
/// - [PlayxSecureStorageType.memory]: in-memory only.
///
/// On web, every type except memory uses encrypted prefs with a
/// non-extractable WebCrypto key.
///
/// Set [PlayxSecurePrefsSettings.throwOnError] to `false` to log errors
/// instead of throwing them.
///
/// The class includes methods for creating the secure storage instance, setting,
/// getting, and removing preferences, and clearing all stored data. It also
/// provides functionality to clear the secure storage on app reinstall.
abstract class PlayxSecurePrefs {
  static FlutterSecureStorage? _securePrefs;
  static PlayxSecureStorageBackend? _backend;
  static bool _throwOnError = true;

  /// Getter for the [FlutterSecureStorage] instance.
  ///
  /// It is only used for reading and writing when the active
  /// [storageType] is [PlayxSecureStorageType.flutterSecureStorage].
  ///
  /// Throws an exception if [create()] has not been called to initialize the
  /// [FlutterSecureStorage] instance.
  static FlutterSecureStorage get securePrefs {
    if (_securePrefs == null) {
      throw Exception(
        'FlutterSecureStorage is not initialized. Please call create() first.',
      );
    }
    return _securePrefs!;
  }

  static PlayxSecureStorageBackend get _storage {
    if (_backend == null) {
      throw Exception(
        'PlayxSecurePrefs is not initialized. Please call create() first.',
      );
    }
    return _backend!;
  }

  /// The backend actually in use.
  ///
  /// With [PlayxSecureStorageType.auto] this is the first healthy backend of
  /// [PlayxSecurePrefsSettings.autoOrder], or [PlayxSecureStorageType.memory].
  static PlayxSecureStorageType get storageType => _storage.type;

  /// Whether [create()] has been called.
  static bool get isInitialized => _backend != null;

  /// Creates the secure storage with the given settings.
  ///
  /// - [securePrefsSettings]: The settings to configure the secure storage behavior.
  /// - If [clearOnReinstall] is set to `true`, the storage is cleared on app reinstall.
  ///
  /// Returns the [FlutterSecureStorage] instance for backward compatibility.
  static Future<FlutterSecureStorage> create({
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
  }) async {
    final fssOptions = securePrefsSettings.flutterSecureStorageOptions;
    _securePrefs = FlutterSecureStorage(
      iOptions: fssOptions.iosOptions,
      aOptions: fssOptions.androidOptions,
      lOptions: fssOptions.linuxOptions,
      wOptions: fssOptions.windowsOptions,
      mOptions: fssOptions.macOsOptions,
    );
    _throwOnError = securePrefsSettings.throwOnError;
    try {
      _backend = await createSecureStorageBackend(
        securePrefsSettings,
        flutterSecureStorage: _securePrefs!,
      );
    } catch (e, s) {
      if (_throwOnError) rethrow;
      secureLogError('Failed to create secure storage, using memory', e, s);
      _backend = MemorySecureStorageBackend();
    }
    if (securePrefsSettings.clearOnReinstall) {
      await _guard('clear on reinstall', clearOnReinstall, null);
    }
    if (kIsWeb) await _migrateWebFlutterSecureStorageOnce();
    return _securePrefs!;
  }

  static const _webMigrationMarker = '_playx_secure_prefs_web_fss_migrated_';

  /// Moves values saved by previous versions, which used
  /// `flutter_secure_storage` on web, into the WebCrypto storage once.
  static Future<void> _migrateWebFlutterSecureStorageOnce() async {
    if (_storage.type == PlayxSecureStorageType.memory) return;
    try {
      final prefs = SharedPreferencesAsync();
      if (await prefs.getBool(_webMigrationMarker) ?? false) return;
      await _migrateFrom(_securePrefs!, deleteFromSource: true);
      await prefs.setBool(_webMigrationMarker, true);
    } catch (e, s) {
      secureLogError('Failed to migrate flutter_secure_storage web data', e, s);
    }
  }

  /// Copies values stored by `flutter_secure_storage` into the current backend.
  ///
  /// Use it when switching an existing app from the default
  /// [PlayxSecureStorageType.flutterSecureStorage] to another type, so users
  /// keep their data. It is safe to call on every start: once the source is
  /// empty it does nothing.
  ///
  /// - Keys that already exist in the current backend are kept, as they are newer.
  /// - [from]: the `flutter_secure_storage` instance holding the data, if it was
  ///   created with custom options. Defaults to [securePrefs], built from
  ///   [PlayxSecurePrefsSettings.flutterSecureStorageOptions].
  /// - [deleteFromSource]: whether to delete the migrated values from
  ///   `flutter_secure_storage` afterwards.
  ///
  /// Returns the number of values copied. Does nothing when the current
  /// backend is itself `flutter_secure_storage`.
  ///
  /// Note: this reads `flutter_secure_storage`, so it can trigger native crashes
  /// on devices where that plugin is broken.
  static Future<int> migrateFromFlutterSecureStorage({
    FlutterSecureStorage? from,
    bool deleteFromSource = true,
  }) {
    final storage = _storage;
    if (storage.type == PlayxSecureStorageType.flutterSecureStorage) {
      return Future.value(0);
    }
    return _guard(
      'migrate from flutter_secure_storage',
      () =>
          _migrateFrom(from ?? securePrefs, deleteFromSource: deleteFromSource),
      0,
    );
  }

  static Future<int> _migrateFrom(
    FlutterSecureStorage source, {
    required bool deleteFromSource,
  }) async {
    final storage = _storage;
    // Decodes entries whose names were hidden, and skips internal keys such
    // as an encrypted prefs key kept in this store.
    final entries = await FlutterSecureStorageBackend(
      source,
      reservedKeys: {EncryptedPrefsBackend.encryptionKeyName},
    ).readEntries();
    var copied = 0;
    for (final entry in entries) {
      if (await storage.read(entry.name) != null) continue;
      await storage.write(entry.name, entry.value);
      copied++;
    }
    if (deleteFromSource) {
      for (final entry in entries) {
        await source.delete(key: entry.storageKey);
      }
    }
    if (entries.isNotEmpty) {
      secureLog('Migrated $copied value(s) from flutter_secure_storage.');
    }
    return copied;
  }

  /// Releases the secure storage. [create()] must be called again before use.
  static Future<void> dispose() async {
    _backend = null;
    _securePrefs = null;
    _throwOnError = true;
  }

  /// Runs [operation], logging errors and returning [fallback] instead of
  /// throwing when [PlayxSecurePrefsSettings.throwOnError] is `false`.
  static Future<T> _guard<T>(
    String action,
    Future<T> Function() operation,
    T fallback,
  ) async {
    try {
      return await operation();
    } catch (e, s) {
      if (_throwOnError) rethrow;
      secureLogError('Failed to $action', e, s);
      return fallback;
    }
  }

  static const String _hasRunBefore = 'hasRunBefore';

  /***************************String***************************/

  /// Retrieves the value associated with the given [key] as a `String`.
  ///
  /// Returns `null` if the key does not exist.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<String?> maybeGetString(String key) {
    final storage = _storage;
    return _guard('read "$key"', () => storage.read(key), null);
  }

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
  static Future<void> setString(String key, String value) {
    final storage = _storage;
    return _guard('write "$key"', () => storage.write(key, value), null);
  }

  /***************************int***************************/

  /// Retrieves the value associated with the given [key] as an `int`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<int?> maybeGetInt(String key) async =>
      toIntOrNull(await maybeGetString(key));

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
  static Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  /***************************double***************************/

  /// Retrieves the value associated with the given [key] as a `double`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<double?> maybeGetDouble(String key) async =>
      toDoubleOrNull(await maybeGetString(key));

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
  static Future<void> setDouble(String key, double value) =>
      setString(key, value.toString());

  /***************************bool***************************/

  /// Retrieves the value associated with the given [key] as a `bool`.
  ///
  /// Returns `null` if the key does not exist or if an error occurs during parsing.
  ///
  /// - [key]: The key of the value to retrieve.
  static Future<bool?> maybeGetBool(String key) async =>
      toBoolOrNull(await maybeGetString(key));

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
  static Future<void> setBool(String key, bool value) =>
      setString(key, value.toString());

  /***************************Map***************************/

  /// Retrieves the JSON map stored under [key].
  ///
  /// Returns `null` if the key does not exist or doesn't hold a JSON object.
  static Future<Map<String, dynamic>?> maybeGetMap(String key) async =>
      decodeJsonMapOrNull(await maybeGetString(key));

  /// Retrieves the JSON map stored under [key], or [fallback] if the key does
  /// not exist or doesn't hold a JSON object.
  static Future<Map<String, dynamic>> getMap(
    String key, {
    Map<String, dynamic> fallback = const {},
  }) async =>
      await maybeGetMap(key) ?? fallback;

  /// Stores [value] under [key] as a JSON string.
  ///
  /// Values must be JSON values or objects with a `toJson()` method.
  /// Throws a `JsonUnsupportedObjectError` otherwise.
  static Future<void> setMap(String key, Map<String, dynamic> value) =>
      setString(key, encodeJsonValue(value));

  /***************************List***************************/

  /// Retrieves the list stored under [key], converting each item with
  /// [fromJson] if provided.
  ///
  /// Returns `null` if the key does not exist, doesn't hold a JSON array, or
  /// an item can't be converted.
  static Future<List<T>?> maybeGetList<T>(
    String key, {
    T Function(dynamic json)? fromJson,
  }) async =>
      decodeJsonListOrNull<T>(await maybeGetString(key), fromJson: fromJson);

  /// Retrieves the list stored under [key], or [fallback] if it can't be read.
  ///
  /// See [maybeGetList].
  static Future<List<T>> getList<T>(
    String key, {
    List<T> fallback = const [],
    T Function(dynamic json)? fromJson,
  }) async =>
      await maybeGetList<T>(key, fromJson: fromJson) ?? fallback;

  /// Stores [value] under [key] as a JSON array, converting each item with
  /// [toJson] if provided.
  ///
  /// Without [toJson], items must be JSON values or objects with a `toJson()`
  /// method. Throws a `JsonUnsupportedObjectError` otherwise.
  static Future<void> setList<T>(
    String key,
    List<T> value, {
    Object? Function(T item)? toJson,
  }) =>
      setString(key, encodeJsonList(value, toJson));

  /***************************Object***************************/

  /// Retrieves the object stored under [key], created with [fromJson].
  ///
  /// Returns `null` if the key does not exist, doesn't hold valid JSON, or
  /// [fromJson] throws.
  static Future<T?> maybeGetObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
  }) async =>
      decodeJsonObjectOrNull<T>(await maybeGetString(key), fromJson: fromJson);

  /// Retrieves the object stored under [key], or [fallback] if it can't be read.
  ///
  /// See [maybeGetObject].
  static Future<T> getObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
    required T fallback,
  }) async =>
      await maybeGetObject<T>(key, fromJson: fromJson) ?? fallback;

  /// Stores [value] under [key] as the JSON returned by [toJson].
  ///
  /// Throws a `JsonUnsupportedObjectError` if the result can't be encoded.
  static Future<void> setObject<T>(
    String key,
    T value, {
    required Object? Function(T value) toJson,
  }) =>
      setString(key, encodeJsonValue(toJson(value)));

  /***************************General***************************/

  /// Clears all data in the secure preferences.
  ///
  /// This removes all key-value pairs stored in the secure storage.
  static Future<void> clear() {
    final storage = _storage;
    return _guard('clear', storage.clear, null);
  }

  /// Removes the value associated with the given [key].
  ///
  /// - [key]: The key of the value to remove.
  static Future<void> remove(String key) {
    final storage = _storage;
    return _guard('remove "$key"', () => storage.delete(key), null);
  }

  /// Clears Secure Storage on Reinstall.
  ///
  /// This method is used to clear the secure storage when the app is reinstalled.
  /// As the secure storage is not cleared on app reinstall on iOS, this method
  /// ensures that secure storage is cleared if the app is being run for the
  /// first time after reinstalling.
  ///
  /// The flag is kept in `SharedPreferences`, which is removed with the app.
  static Future<void> clearOnReinstall() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_hasRunBefore) ?? false)) {
      await clear();
      await prefs.setBool(_hasRunBefore, true);
    }
  }
}
