import 'package:flutter/foundation.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

import '../settings/secure_storage_type.dart';
import '../settings/simple_secure_storage_options.dart';
import 'secure_storage_backend.dart';

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
