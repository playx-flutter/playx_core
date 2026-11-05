import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

import '../../models/secure_prefs_settings.dart';

/// Key used by write/read health checks. Never returned by [readAll].
const secureHealthCheckKey = '_playx_secure_storage_health_check_';

/// A key/value string store used by `PlayxSecurePrefs`.
abstract class PlayxSecureStorageBackend {
  /// The type of this backend.
  PlayxSecureStorageType get type;

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  /// Removes every value written through this backend.
  ///
  /// Internal keys (such as an encryption key kept in this store) are preserved.
  Future<void> clear();

  /// Returns every value written through this backend, without internal keys.
  Future<Map<String, String>> readAll();
}

/// Writes, reads back and deletes a random value. Throws if anything fails.
Future<void> runSecureHealthCheck({
  required Future<void> Function(String key, String value) write,
  required Future<String?> Function(String key) read,
  required Future<void> Function(String key) delete,
}) async {
  // Random bytes rather than `nextInt(1 << 32)`, which is 0 on web.
  final random = Random.secure();
  final value = base64Encode(List.generate(16, (_) => random.nextInt(256)));
  try {
    await write(secureHealthCheckKey, value);
    final readValue = await read(secureHealthCheckKey);
    if (readValue != value) {
      throw StateError(
        'Secure storage health check failed: '
        'read value does not match written value.',
      );
    }
  } finally {
    await delete(secureHealthCheckKey);
  }
}

/// Backend powered by `flutter_secure_storage`.
class FlutterSecureStorageBackend implements PlayxSecureStorageBackend {
  final FlutterSecureStorage storage;

  /// Keys that belong to playx (e.g. the encrypted prefs key) and are never
  /// cleared or returned by [readAll].
  final Set<String> reservedKeys;

  const FlutterSecureStorageBackend(
    this.storage, {
    this.reservedKeys = const {},
  });

  Future<void> healthCheck() => runSecureHealthCheck(
    write: (k, v) => storage.write(key: k, value: v),
    read: (k) => storage.read(key: k),
    delete: (k) => storage.delete(key: k),
  );

  @override
  PlayxSecureStorageType get type =>
      PlayxSecureStorageType.flutterSecureStorage;

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);

  @override
  Future<void> clear() async {
    if (reservedKeys.isEmpty) return storage.deleteAll();
    for (final key in (await readAll()).keys) {
      await storage.delete(key: key);
    }
  }

  @override
  Future<Map<String, String>> readAll() async =>
      (await storage.readAll())..removeWhere((k, _) => _isInternal(k));

  bool _isInternal(String key) =>
      key == secureHealthCheckKey || reservedKeys.contains(key);
}

/// Backend powered by `simple_secure_storage`.
class SimpleSecureStorageBackend implements PlayxSecureStorageBackend {
  /// Keys that belong to playx and are never cleared or returned by [readAll].
  final Set<String> reservedKeys;

  const SimpleSecureStorageBackend({this.reservedKeys = const {}});

  /// Initializes `simple_secure_storage` with platform specific options.
  static Future<void> initialize(PlayxSimpleSecureStorageOptions options) {
    // Never used on web, where PlayxSecurePrefs relies on WebCrypto instead.
    final InitializationOptions initOptions;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      initOptions = DarwinInitializationOptions(
        appName: options.appName,
        namespace: options.namespace,
        prefix: options.prefix,
        accessibility: options.darwinAccessibility,
      );
    } else {
      initOptions = InitializationOptions(
        appName: options.appName,
        namespace: options.namespace,
        prefix: options.prefix,
      );
    }
    return SimpleSecureStorage.initialize(initOptions);
  }

  Future<void> healthCheck() => runSecureHealthCheck(
    write: SimpleSecureStorage.write,
    read: SimpleSecureStorage.read,
    delete: SimpleSecureStorage.delete,
  );

  @override
  PlayxSecureStorageType get type => PlayxSecureStorageType.simpleSecureStorage;

  @override
  Future<String?> read(String key) async =>
      await SimpleSecureStorage.has(key) ? SimpleSecureStorage.read(key) : null;

  @override
  Future<void> write(String key, String value) =>
      SimpleSecureStorage.write(key, value);

  @override
  Future<void> delete(String key) => SimpleSecureStorage.delete(key);

  @override
  Future<void> clear() async {
    if (reservedKeys.isEmpty) return SimpleSecureStorage.clear();
    for (final key in (await readAll()).keys) {
      await SimpleSecureStorage.delete(key);
    }
  }

  @override
  Future<Map<String, String>> readAll() async =>
      (await SimpleSecureStorage.list())..removeWhere((k, _) => _isInternal(k));

  bool _isInternal(String key) =>
      key == secureHealthCheckKey || reservedKeys.contains(key);
}

/// Backend that keeps values in memory only.
class MemorySecureStorageBackend implements PlayxSecureStorageBackend {
  final Map<String, String> _values = {};

  @override
  PlayxSecureStorageType get type => PlayxSecureStorageType.memory;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<Map<String, String>> readAll() async => Map.of(_values);
}
