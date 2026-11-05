import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

import '../../models/secure_prefs_settings.dart';
import 'cipher/secure_cipher.dart';
import 'secure_log.dart';

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

/// An entry read from `flutter_secure_storage`, with its real name.
typedef FlutterSecureStorageEntry = ({
  String storageKey,
  String name,
  String value,
  bool hashed,
});

/// Backend powered by `flutter_secure_storage`.
///
/// With [hideNames], each value is stored under a keyed hash of its name, with
/// the real name kept inside the (encrypted) value. Used on Android, where the
/// plugin otherwise keeps names in plain text in a preferences file. The
/// hashing key is kept in `flutter_secure_storage` itself.
///
/// Stored entries are converted lazily, on the first operation, so creating
/// the backend does no I/O.
class FlutterSecureStorageBackend implements PlayxSecureStorageBackend {
  final FlutterSecureStorage storage;

  /// Keys that belong to playx (e.g. the encrypted prefs key). They are never
  /// cleared, hashed or returned by [readAll].
  final Set<String> reservedKeys;

  /// Whether to store values under hashed names.
  final bool hideNames;

  /// Name of the key used to hash names. Its presence means names were hidden.
  static const hashKeyName = '_playx_secure_key_names_key_';

  static const _hashedPrefix = '_playx_k_';

  FlutterSecureStorageBackend(
    this.storage, {
    this.reservedKeys = const {},
    this.hideNames = false,
  });

  Future<SecureCipher?>? _ready;
  final Map<String, String> _hashedNames = {};

  Future<void> healthCheck() => runSecureHealthCheck(
    write: (k, v) => storage.write(key: k, value: v),
    read: (k) => storage.read(key: k),
    delete: (k) => storage.delete(key: k),
  );

  @override
  PlayxSecureStorageType get type =>
      PlayxSecureStorageType.flutterSecureStorage;

  bool _isInternal(String key) =>
      key == secureHealthCheckKey ||
      key == hashKeyName ||
      reservedKeys.contains(key);

  /// Loads the hashing key and converts stored entries to the selected
  /// format, once. Returns the hashing cipher, or `null` if names aren't hidden.
  Future<SecureCipher?> _prepare() => _ready ??= () async {
    try {
      return hideNames ? await _hideStoredNames() : await _revealStoredNames();
    } catch (_) {
      _ready = null;
      rethrow;
    }
  }();

  Future<SecureCipher> _hideStoredNames() async {
    final entries = await readEntries();
    var key = _decodeKey(await storage.read(key: hashKeyName));
    final rehash = key == null;
    if (key == null) {
      // Safe even if hashed entries exist: their names are inside the values.
      key = secureRandomBytes(secureKeyLength);
      final encoded = base64Encode(key);
      await storage.write(key: hashKeyName, value: encoded);
      if (await storage.read(key: hashKeyName) != encoded) {
        throw StateError('Name hashing key read back does not match.');
      }
    }
    final cipher = RawKeySecureCipher(key);

    var converted = 0;
    if (rehash) {
      for (final entry in entries.where((e) => e.hashed)) {
        final target = await _hashedKey(cipher, entry.name);
        if (target == entry.storageKey) continue;
        await storage.write(
          key: target,
          value: _encode(entry.name, entry.value),
        );
        await storage.delete(key: entry.storageKey);
      }
    }
    // Plain entries last: they were written while names weren't hidden.
    for (final entry in entries.where((e) => !e.hashed)) {
      await storage.write(
        key: await _hashedKey(cipher, entry.name),
        value: _encode(entry.name, entry.value),
      );
      await storage.delete(key: entry.storageKey);
      converted++;
    }
    if (converted > 0) {
      secureLog('flutter_secure_storage: hid $converted key name(s).');
    }
    return cipher;
  }

  Future<SecureCipher?> _revealStoredNames() async {
    if (await storage.read(key: hashKeyName) == null) return null;
    final entries = await readEntries();
    final plainNames = {
      for (final entry in entries)
        if (!entry.hashed) entry.name,
    };
    for (final entry in entries.where((e) => e.hashed)) {
      if (!plainNames.contains(entry.name)) {
        await storage.write(key: entry.name, value: entry.value);
      }
      await storage.delete(key: entry.storageKey);
    }
    await storage.delete(key: hashKeyName);
    secureLog('flutter_secure_storage: restored plain key names.');
    return null;
  }

  static Uint8List? _decodeKey(String? encoded) {
    if (encoded == null) return null;
    try {
      final key = base64Decode(encoded);
      return key.length == secureKeyLength ? key : null;
    } on FormatException {
      return null;
    }
  }

  Future<String> _hashedKey(SecureCipher cipher, String name) async {
    final cached = _hashedNames[name];
    if (cached != null) return cached;
    final hash = await cipher.keyedHash(Uint8List.fromList(utf8.encode(name)));
    return _hashedNames[name] =
        '$_hashedPrefix${base64Url.encode(hash.sublist(0, 16)).replaceAll('=', '')}';
  }

  static String _encode(String name, String value) =>
      jsonEncode({'n': name, 'v': value});

  /// Every stored entry with its real name, without internal keys. Doesn't
  /// require the hashing key.
  Future<List<FlutterSecureStorageEntry>> readEntries() async {
    final entries = <FlutterSecureStorageEntry>[];
    for (final MapEntry(:key, :value) in (await storage.readAll()).entries) {
      if (_isInternal(key)) continue;
      if (!key.startsWith(_hashedPrefix)) {
        entries.add((storageKey: key, name: key, value: value, hashed: false));
        continue;
      }
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        entries.add((
          storageKey: key,
          name: map['n'] as String,
          value: map['v'] as String,
          hashed: true,
        ));
      } catch (e, s) {
        secureLogError('Invalid hashed flutter_secure_storage entry', e, s);
      }
    }
    return entries;
  }

  @override
  Future<String?> read(String key) async {
    final cipher = _isInternal(key) ? null : await _prepare();
    if (cipher != null) {
      final stored = await storage.read(key: await _hashedKey(cipher, key));
      if (stored != null) {
        final map = jsonDecode(stored) as Map<String, dynamic>;
        if (map['n'] == key) return map['v'] as String;
      }
    }
    return storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    final cipher = _isInternal(key) ? null : await _prepare();
    if (cipher == null) return storage.write(key: key, value: value);
    await storage.write(
      key: await _hashedKey(cipher, key),
      value: _encode(key, value),
    );
  }

  @override
  Future<void> delete(String key) async {
    final cipher = _isInternal(key) ? null : await _prepare();
    if (cipher != null) {
      await storage.delete(key: await _hashedKey(cipher, key));
    }
    await storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    if (reservedKeys.isEmpty) {
      await storage.deleteAll();
      _ready = null;
      _hashedNames.clear();
      return;
    }
    for (final entry in await readEntries()) {
      await storage.delete(key: entry.storageKey);
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    await _prepare();
    final values = <String, String>{};
    final entries = await readEntries();
    for (final entry in entries.where((e) => !e.hashed)) {
      values[entry.name] = entry.value;
    }
    // Values written by playx take precedence over plain ones written directly.
    for (final entry in entries.where((e) => e.hashed)) {
      values[entry.name] = entry.value;
    }
    return values;
  }
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
