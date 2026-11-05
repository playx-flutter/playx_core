import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/secure_prefs_settings.dart';
import 'cipher/secure_cipher.dart';
import 'cipher/web_crypto_key_store.dart';
import 'secure_log.dart';
import 'secure_storage_backend.dart';

/// Returns a healthy key store of [type], or `null` if it is unavailable.
typedef SecureKeyStoreProvider =
    Future<PlayxSecureStorageBackend?> Function(PlayxSecureStorageType type);

/// Backend that stores AES-GCM encrypted values in `SharedPreferencesAsync`.
///
/// Two keys are involved:
/// - the **primary key**: a non-extractable WebCrypto key in IndexedDB on web,
///   or random bytes kept in a secure key store elsewhere;
/// - the **fallback key**: random bytes kept in plain preferences, used when
///   the primary key is unavailable. It only obfuscates data.
///
/// Every payload records which key encrypted it, so values written with the
/// fallback key stay readable in later sessions where the primary key is back.
class EncryptedPrefsBackend implements PlayxSecureStorageBackend {
  final SharedPreferencesAsync _prefs;
  final SecureCipher? _primary;
  final SecureCipher _fallback;
  final String _keyPrefix;

  /// Name of the store holding the primary key, or `null` if it couldn't be loaded.
  final String? keyStore;

  /// Whether new values are encrypted with the fallback key.
  bool get isUsingFallbackKey => _primary == null;

  /// Key under which the primary key is kept in a native key store.
  static const encryptionKeyName = '_playx_secure_prefs_encryption_key_';

  /// Key store name used on web.
  static const webCryptoKeyStore = 'webCrypto';

  static const _fallbackKeyName = '_playx_secure_prefs_fallback_key_';
  static const _keyStoreMarkerName = '_playx_secure_prefs_key_store_';
  static const _missingKeyCountName = '_playx_secure_prefs_missing_key_count_';
  static const _healthCheckName = '_playx_secure_prefs_health_check_';

  /// Consecutive starts with a healthy key store but a missing key after
  /// which the key is considered lost and a new one is created.
  static const missingKeyThreshold = 3;

  static const _primaryKeyId = 'p';
  static const _fallbackKeyId = 'f';

  EncryptedPrefsBackend._(
    this._prefs,
    this._primary,
    this._fallback,
    this._keyPrefix,
    this.keyStore,
  );

  /// Loads the keys and creates the backend. Throws if preferences are unavailable.
  static Future<EncryptedPrefsBackend> create(
    PlayxEncryptedPrefsOptions options, {
    required SharedPreferencesAsync prefs,
    required SecureKeyStoreProvider keyStoreProvider,
  }) async {
    final fallback = await _loadFallbackKey(prefs);
    // New keys are only created in configured stores, but an existing key is
    // read from wherever it was created.
    final List<_PrimaryKeyStore> creationStores;
    final List<_PrimaryKeyStore> knownStores;
    if (kIsWeb) {
      creationStores = knownStores = [_WebCryptoKeyStore()];
    } else {
      knownStores = [
        for (final type in const [
          PlayxSecureStorageType.simpleSecureStorage,
          PlayxSecureStorageType.flutterSecureStorage,
        ])
          _BackendKeyStore(type, keyStoreProvider),
      ];
      creationStores = [
        for (final type in options.keyStores)
          knownStores.firstWhere((s) => s.name == type.name),
      ];
    }

    SecureCipher? primary;
    String? keyStore;
    try {
      (primary, keyStore) = await _PrimaryKeyLoader(
        prefs,
        options.keyPrefix,
        creationStores: creationStores,
        knownStores: knownStores,
      ).load();
    } catch (e, s) {
      secureLogError('Failed to load encryption key', e, s);
    }
    if (primary == null) {
      secureLog('Encrypted prefs: using the fallback encryption key.');
    }
    return EncryptedPrefsBackend._(
      prefs,
      primary,
      fallback,
      options.keyPrefix,
      keyStore,
    );
  }

  static Future<SecureCipher> _loadFallbackKey(
    SharedPreferencesAsync prefs,
  ) async {
    final stored = await prefs.getString(_fallbackKeyName);
    if (stored != null) {
      return RawKeySecureCipher(
        _decodeKey(stored) ??
            (throw StateError('Stored fallback encryption key is invalid.')),
      );
    }
    final key = secureRandomBytes(secureKeyLength);
    await prefs.setString(_fallbackKeyName, base64Encode(key));
    return RawKeySecureCipher(key);
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

  /// Writes, reads back and removes an encrypted value. Throws if anything fails.
  Future<void> healthCheck() => runSecureHealthCheck(
    write: (_, v) async =>
        _prefs.setString(_healthCheckName, await _encrypt(v)),
    read: (_) async {
      final payload = await _prefs.getString(_healthCheckName);
      return payload == null ? null : _decrypt(payload);
    },
    delete: (_) => _prefs.remove(_healthCheckName),
  );

  String _storageKey(String key) => '$_keyPrefix$key';

  static bool _isOwnKey(String prefix, String storageKey) =>
      storageKey.startsWith(prefix) &&
      storageKey != _fallbackKeyName &&
      storageKey != _keyStoreMarkerName &&
      storageKey != _missingKeyCountName &&
      storageKey != _healthCheckName;

  @override
  PlayxSecureStorageType get type => PlayxSecureStorageType.encryptedPrefs;

  @override
  Future<String?> read(String key) async {
    final payload = await _prefs.getString(_storageKey(key));
    return payload == null ? null : _tryDecrypt(key, payload);
  }

  Future<String?> _tryDecrypt(String key, String payload) async {
    try {
      return await _decrypt(payload);
    } catch (e, s) {
      secureLogError('Failed to decrypt value for key "$key"', e, s);
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async =>
      _prefs.setString(_storageKey(key), await _encrypt(value));

  @override
  Future<void> delete(String key) => _prefs.remove(_storageKey(key));

  @override
  Future<void> clear() async {
    final keys = await _ownKeys(_prefs, _keyPrefix);
    if (keys.isEmpty) return;
    await _prefs.clear(allowList: keys);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final keys = await _ownKeys(_prefs, _keyPrefix);
    if (keys.isEmpty) return {};
    final payloads = await _prefs.getAll(allowList: keys);
    final values = <String, String>{};
    for (final MapEntry(:key, :value) in payloads.entries) {
      if (value is! String) continue;
      final name = key.substring(_keyPrefix.length);
      final decrypted = await _tryDecrypt(name, value);
      if (decrypted != null) values[name] = decrypted;
    }
    return values;
  }

  static Future<Set<String>> _ownKeys(
    SharedPreferencesAsync prefs,
    String prefix,
  ) async => (await prefs.getKeys()).where((k) => _isOwnKey(prefix, k)).toSet();

  /// Returns `keyId:base64(nonce):base64(ciphertext + auth tag)`.
  Future<String> _encrypt(String plainText) async {
    final keyId = _primary == null ? _fallbackKeyId : _primaryKeyId;
    final cipher = _primary ?? _fallback;
    final nonce = secureRandomBytes(secureNonceLength);
    final cipherText = await cipher.encrypt(
      nonce,
      Uint8List.fromList(utf8.encode(plainText)),
    );
    return '$keyId:${base64Encode(nonce)}:${base64Encode(cipherText)}';
  }

  /// Throws if the payload is malformed, was tampered with, or its key is
  /// unavailable this session.
  Future<String> _decrypt(String payload) async {
    final parts = payload.split(':');
    if (parts.length != 3) throw const FormatException('Invalid payload');
    final cipher = switch (parts[0]) {
      _primaryKeyId =>
        _primary ?? (throw StateError('Primary encryption key unavailable.')),
      _fallbackKeyId => _fallback,
      _ => throw const FormatException('Unknown key id'),
    };
    final plainText = await cipher.decrypt(
      base64Decode(parts[1]),
      base64Decode(parts[2]),
    );
    return utf8.decode(plainText);
  }
}

/// Thrown when a key store holds something that isn't a valid key.
class _InvalidKeyException implements Exception {
  const _InvalidKeyException();
}

/// A place where the primary key can be kept.
abstract class _PrimaryKeyStore {
  String get name;

  /// Whether the store can be used this session.
  Future<bool> isAvailable();

  /// Returns `null` if no key is stored. Throws [_InvalidKeyException] if the
  /// stored value isn't a valid key.
  Future<SecureCipher?> read();

  /// Creates, stores and verifies a new key, replacing any existing one.
  Future<SecureCipher> create();
}

/// Keeps random key bytes in `simple_secure_storage` or `flutter_secure_storage`.
class _BackendKeyStore implements _PrimaryKeyStore {
  final PlayxSecureStorageType type;
  final SecureKeyStoreProvider provider;

  _BackendKeyStore(this.type, this.provider);

  @override
  String get name => type.name;

  @override
  Future<bool> isAvailable() async => await provider(type) != null;

  Future<PlayxSecureStorageBackend> get _backend async =>
      await provider(type) ?? (throw StateError('$name is unavailable'));

  @override
  Future<SecureCipher?> read() async {
    final stored = await (await _backend).read(
      EncryptedPrefsBackend.encryptionKeyName,
    );
    if (stored == null) return null;
    final key = EncryptedPrefsBackend._decodeKey(stored);
    if (key == null) throw const _InvalidKeyException();
    return RawKeySecureCipher(key);
  }

  @override
  Future<SecureCipher> create() async {
    final backend = await _backend;
    final key = secureRandomBytes(secureKeyLength);
    final encoded = base64Encode(key);
    await backend.write(EncryptedPrefsBackend.encryptionKeyName, encoded);
    if (await backend.read(EncryptedPrefsBackend.encryptionKeyName) !=
        encoded) {
      throw StateError('Encryption key read back does not match.');
    }
    return RawKeySecureCipher(key);
  }
}

/// Keeps a non-extractable WebCrypto key in IndexedDB.
class _WebCryptoKeyStore implements _PrimaryKeyStore {
  @override
  String get name => EncryptedPrefsBackend.webCryptoKeyStore;

  @override
  Future<bool> isAvailable() async {
    try {
      await readWebCryptoKey();
      return true;
    } catch (e, s) {
      secureLogError('WebCrypto key store is unavailable', e, s);
      return false;
    }
  }

  @override
  Future<SecureCipher?> read() => readWebCryptoKey();

  @override
  Future<SecureCipher> create() async {
    final cipher = await createWebCryptoKey();
    // Verify the key round-trips before relying on it.
    final nonce = secureRandomBytes(secureNonceLength);
    final probe = Uint8List.fromList([1, 2, 3]);
    final decrypted = await cipher.decrypt(
      nonce,
      await cipher.encrypt(nonce, probe),
    );
    if (!listEquals(decrypted, probe)) {
      throw StateError('WebCrypto key verification failed.');
    }
    return cipher;
  }
}

/// Loads the primary key without ever discarding a key that may still be
/// needed to decrypt stored values.
class _PrimaryKeyLoader {
  final SharedPreferencesAsync prefs;
  final String keyPrefix;
  final List<_PrimaryKeyStore> creationStores;
  final List<_PrimaryKeyStore> knownStores;

  _PrimaryKeyLoader(
    this.prefs,
    this.keyPrefix, {
    required this.creationStores,
    required this.knownStores,
  });

  Future<(SecureCipher?, String?)> load() async {
    final markerName = await prefs.getString(
      EncryptedPrefsBackend._keyStoreMarkerName,
    );
    final marked = markerName == null
        ? null
        : knownStores.where((s) => s.name == markerName).firstOrNull;

    if (markerName != null && marked == null) {
      secureLog('Encrypted prefs: unknown key store "$markerName".');
      return (null, null);
    }
    if (marked != null) return _loadFromMarkedStore(marked);

    for (final store in creationStores) {
      if (!await store.isAvailable()) continue;
      try {
        // An existing key may be found if the marker was lost (e.g. after a
        // reinstall on iOS, where the Keychain survives).
        final cipher = await store.read() ?? await store.create();
        await _markStore(store.name);
        return (cipher, store.name);
      } on _InvalidKeyException {
        secureLog(
          'Encrypted prefs: invalid key found in "${store.name}". '
          'It is left untouched.',
        );
      } catch (e, s) {
        secureLogError(
          'Failed to create encryption key in ${store.name}',
          e,
          s,
        );
      }
    }
    return (null, null);
  }

  Future<(SecureCipher?, String?)> _loadFromMarkedStore(
    _PrimaryKeyStore store,
  ) async {
    if (!await store.isAvailable()) {
      secureLog(
        'Encrypted prefs: key store "${store.name}" is unavailable this session.',
      );
      return (null, null);
    }

    SecureCipher? cipher;
    try {
      cipher = await store.read();
    } on _InvalidKeyException {
      cipher = null;
    }
    if (cipher != null) {
      await prefs.remove(EncryptedPrefsBackend._missingKeyCountName);
      return (cipher, store.name);
    }

    // The store works but the key is missing or invalid.
    final primaryPayloads = await _primaryPayloadKeys();
    if (primaryPayloads.isEmpty) {
      secureLog(
        'Encrypted prefs: key missing with no data, creating a new one.',
      );
      return (await store.create(), store.name);
    }

    final count =
        (await prefs.getInt(EncryptedPrefsBackend._missingKeyCountName) ?? 0) +
        1;
    if (count < EncryptedPrefsBackend.missingKeyThreshold) {
      await prefs.setInt(EncryptedPrefsBackend._missingKeyCountName, count);
      secureLog(
        'Encrypted prefs: key in "${store.name}" is missing '
        '($count/${EncryptedPrefsBackend.missingKeyThreshold}). '
        'It is not recreated yet.',
      );
      return (null, null);
    }

    // Missing for several starts in a row: treat it as lost (e.g. the Android
    // Keystore was reset). Values encrypted with it can't be recovered.
    secureLog(
      'Encrypted prefs: key in "${store.name}" is lost. Removing '
      '${primaryPayloads.length} unreadable value(s) and creating a new key.',
    );
    await prefs.clear(allowList: primaryPayloads);
    final newCipher = await store.create();
    await prefs.remove(EncryptedPrefsBackend._missingKeyCountName);
    return (newCipher, store.name);
  }

  Future<void> _markStore(String name) async {
    await prefs.setString(EncryptedPrefsBackend._keyStoreMarkerName, name);
    await prefs.remove(EncryptedPrefsBackend._missingKeyCountName);
  }

  /// Keys of stored values encrypted with the primary key.
  Future<Set<String>> _primaryPayloadKeys() async {
    final keys = await EncryptedPrefsBackend._ownKeys(prefs, keyPrefix);
    if (keys.isEmpty) return {};
    final payloads = await prefs.getAll(allowList: keys);
    return {
      for (final MapEntry(:key, :value) in payloads.entries)
        if (value is String &&
            value.startsWith('${EncryptedPrefsBackend._primaryKeyId}:'))
          key,
    };
  }
}
