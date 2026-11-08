import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/safe_json_convert.dart';
import '../../../crypto/secure_cipher.dart';
import '../crypto/web_crypto_key_store.dart';
import '../secure_log.dart';
import '../settings/encrypted_prefs_options.dart';
import '../settings/secure_storage_type.dart';
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
///
/// With [PlayxSecurePrefsSettings.encryptKeys], key names are replaced by
/// a keyed hash and stored inside the encrypted payload instead.
class EncryptedPrefsBackend implements PlayxSecureStorageBackend {
  final SharedPreferencesAsync _prefs;
  final SecureCipher? _primary;
  final SecureCipher _fallback;
  final String _keyPrefix;
  final bool _encryptKeys;

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

  // Payload key ids. Lowercase: the payload is the value. Uppercase: the
  // payload is a [_NamedEntry] (encryptKeys).
  static const _primaryKeyId = 'p';
  static const _fallbackKeyId = 'f';
  static const _namedPrimaryKeyId = 'P';
  static const _namedFallbackKeyId = 'F';

  final Map<(SecureCipher, String), String> _hashedNames = {};

  /// Whether entries encrypted with the unavailable primary key exist. Only
  /// then must removals be recorded instead of applied.
  bool _hasHiddenPrimaryEntries = false;

  EncryptedPrefsBackend._(
    this._prefs,
    this._primary,
    this._fallback,
    this._keyPrefix,
    this._encryptKeys,
    this.keyStore,
  );

  /// Loads the keys and creates the backend. Throws if preferences are unavailable.
  static Future<EncryptedPrefsBackend> create(
    PlayxEncryptedPrefsOptions options, {
    required SharedPreferencesAsync prefs,
    required SecureKeyStoreProvider keyStoreProvider,
    bool encryptKeys = false,
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
    final backend = EncryptedPrefsBackend._(
      prefs,
      primary,
      fallback,
      options.keyPrefix,
      encryptKeys,
      keyStore,
    );
    try {
      await backend._convertKeyFormat();
    } catch (e, s) {
      secureLogError('Failed to convert stored key names', e, s);
    }
    return backend;
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
        _prefs.setString(_healthCheckName, await _encrypt(v, named: false)),
    read: (_) async {
      final payload = await _prefs.getString(_healthCheckName);
      return payload == null ? null : (await _decrypt(payload)).$2;
    },
    delete: (_) => _prefs.remove(_healthCheckName),
  );

  static bool _isOwnKey(String prefix, String storageKey) =>
      storageKey.startsWith(prefix) &&
      storageKey != _fallbackKeyName &&
      storageKey != _keyStoreMarkerName &&
      storageKey != _missingKeyCountName &&
      storageKey != _healthCheckName;

  static Future<Set<String>> _ownKeys(
    SharedPreferencesAsync prefs,
    String prefix,
  ) async => (await prefs.getKeys()).where((k) => _isOwnKey(prefix, k)).toSet();

  @override
  PlayxSecureStorageType get type => PlayxSecureStorageType.encryptedPrefs;

  @override
  Future<String?> read(String key) async {
    if (!_encryptKeys) {
      final payload = await _prefs.getString('$_keyPrefix$key');
      return payload == null ? null : _tryDecryptValue(key, payload);
    }
    return (await _newestEntry(key))?.value;
  }

  @override
  Future<void> write(String key, String value) async {
    if (!_encryptKeys) {
      return _prefs.setString(
        '$_keyPrefix$key',
        await _encrypt(value, named: false),
      );
    }
    await _writeNamed(
      _NamedEntry(key, value, DateTime.now().microsecondsSinceEpoch),
    );
  }

  @override
  Future<void> delete(String key) async {
    if (!_encryptKeys) return _prefs.remove('$_keyPrefix$key');
    if (_primary != null || !_hasHiddenPrimaryEntries) {
      for (final storageKey in await _storageKeysFor(key)) {
        await _prefs.remove(storageKey);
      }
      await _prefs.remove('$_keyPrefix$key');
    } else {
      // An entry hashed with the primary key may exist but can't be located
      // this session: record the removal so it wins once the key is back.
      await _writeNamed(
        _NamedEntry(key, null, DateTime.now().microsecondsSinceEpoch),
      );
    }
  }

  @override
  Future<void> clear() async {
    final keys = await _ownKeys(_prefs, _keyPrefix);
    if (keys.isEmpty) return;
    await _prefs.clear(allowList: keys);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final (named, plain, _) = await _readStoredEntries();
    final values = <String, String>{};
    for (final MapEntry(:key, :value) in named.entries) {
      final newest = _newest(value);
      if (newest.value != null) values[key] = newest.value!;
    }
    // A plain entry coexisting with named ones is always the newest (see [_writeNamed]).
    for (final MapEntry(:key, :value) in plain.entries) {
      values[key] = value.value!;
    }
    return values;
  }

  /// Storage keys where [name] may be kept: hashed with the primary key (if
  /// available) and with the fallback key.
  Future<List<String>> _storageKeysFor(String name) async => [
    if (_primary case final primary?)
      '$_keyPrefix$_primaryKeyId${await _hashName(primary, name)}',
    '$_keyPrefix$_fallbackKeyId${await _hashName(_fallback, name)}',
  ];

  Future<String> _hashName(SecureCipher cipher, String name) async {
    final cached = _hashedNames[(cipher, name)];
    if (cached != null) return cached;
    final hash = await cipher.keyedHash(Uint8List.fromList(utf8.encode(name)));
    // 128 bits is plenty: the real name is checked after decryption.
    return _hashedNames[(cipher, name)] = base64Url
        .encode(hash.sublist(0, 16))
        .replaceAll('=', '');
  }

  /// Writes [entry] under the hash of its name and removes the entry's other
  /// locations, including any plain (non-hashed) entry. So a plain entry that
  /// coexists with named ones was written later, with `encryptKeys` off.
  Future<void> _writeNamed(_NamedEntry entry) async {
    final storageKeys = await _storageKeysFor(entry.name);
    // The primary-hashed key comes first when the primary key is available.
    final target = storageKeys.first;
    await _prefs.setString(target, await _encrypt(entry.encode(), named: true));
    for (final other in storageKeys.skip(1)) {
      await _prefs.remove(other);
    }
    await _prefs.remove('$_keyPrefix${entry.name}');
  }

  Future<_NamedEntry?> _newestEntry(String name) async {
    // Written with encryptKeys off and not converted yet: always the newest.
    final plain = await _prefs.getString('$_keyPrefix$name');
    if (plain != null) {
      final value = await _tryDecryptValue(name, plain);
      if (value != null) return _NamedEntry(name, value, 0);
    }
    final entries = <_NamedEntry>[];
    for (final storageKey in await _storageKeysFor(name)) {
      final payload = await _prefs.getString(storageKey);
      if (payload == null) continue;
      final entry = await _tryDecodeNamed(payload);
      if (entry != null && entry.name == name) entries.add(entry);
    }
    return entries.isEmpty ? null : _newest(entries);
  }

  static _NamedEntry _newest(List<_NamedEntry> entries) =>
      entries.reduce((a, b) => b.time > a.time ? b : a);

  /// Decrypts every stored entry: named entries grouped by name, plain
  /// (non-hashed) entries by name, and whether some named entries couldn't be
  /// decrypted because the primary key is unavailable.
  Future<(Map<String, List<_NamedEntry>>, Map<String, _NamedEntry>, bool)>
  _readStoredEntries() async {
    final named = <String, List<_NamedEntry>>{};
    final plain = <String, _NamedEntry>{};
    var hiddenPrimary = false;
    final keys = await _ownKeys(_prefs, _keyPrefix);
    if (keys.isEmpty) return (named, plain, hiddenPrimary);
    final payloads = await _prefs.getAll(allowList: keys);
    for (final MapEntry(:key, :value) in payloads.entries) {
      if (value is! String) continue;
      if (_primary == null && value.startsWith('$_namedPrimaryKeyId:')) {
        hiddenPrimary = true;
        continue;
      }
      try {
        final (isNamed, plainText) = await _decrypt(value);
        if (isNamed) {
          final entry = _NamedEntry.decode(plainText, storageKey: key);
          (named[entry.name] ??= []).add(entry);
        } else {
          final name = key.substring(_keyPrefix.length);
          plain[name] = _NamedEntry(name, plainText, 0, storageKey: key);
        }
      } catch (e, s) {
        secureLogError('Failed to decrypt a stored value', e, s);
      }
    }
    return (named, plain, hiddenPrimary);
  }

  /// Converts stored entries to the format selected by `encryptKeys`, and
  /// cleans up superseded entries. Entries that can't be decrypted this
  /// session are left for a later one.
  Future<void> _convertKeyFormat() async {
    final (named, plain, hiddenPrimary) = await _readStoredEntries();
    _hasHiddenPrimaryEntries = hiddenPrimary;
    var converted = 0;
    if (_encryptKeys) {
      // Plain entries are always the newest (see [_writeNamed]).
      final now = DateTime.now().microsecondsSinceEpoch;
      for (final MapEntry(:key, :value) in plain.entries) {
        await _writeNamed(_NamedEntry(key, value.value, now));
        named.remove(key);
        converted++;
      }
      for (final MapEntry(:key, :value) in named.entries) {
        final newest = _newest(value);
        if (newest.value == null) {
          // A recorded removal is only needed while hidden entries may exist.
          if (_primary != null || !hiddenPrimary) {
            for (final entry in value) {
              await _prefs.remove(entry.storageKey!);
            }
          }
        } else if (_primary != null &&
            (value.length > 1 ||
                newest.storageKey != (await _storageKeysFor(key)).first)) {
          // Keep a single entry, hashed with the primary key.
          await _writeNamed(newest);
        }
      }
    } else {
      for (final MapEntry(:key, :value) in named.entries) {
        final newest = _newest(value);
        if (!plain.containsKey(key) && newest.value != null) {
          await _prefs.setString(
            '$_keyPrefix$key',
            await _encrypt(newest.value!, named: false),
          );
          converted++;
        }
        for (final entry in value) {
          await _prefs.remove(entry.storageKey!);
        }
      }
    }
    if (converted > 0) {
      secureLog('Encrypted prefs: converted $converted stored key name(s).');
    }
  }

  Future<String?> _tryDecryptValue(String key, String payload) async {
    try {
      final (isNamed, plainText) = await _decrypt(payload);
      if (isNamed) throw const FormatException('Unexpected named entry');
      return plainText;
    } catch (e, s) {
      secureLogError('Failed to decrypt value for key "$key"', e, s);
      return null;
    }
  }

  Future<_NamedEntry?> _tryDecodeNamed(String payload) async {
    try {
      final (isNamed, plainText) = await _decrypt(payload);
      if (!isNamed) throw const FormatException('Expected a named entry');
      return _NamedEntry.decode(plainText);
    } catch (e, s) {
      secureLogError('Failed to decrypt a stored value', e, s);
      return null;
    }
  }

  /// Returns `keyId:base64(nonce):base64(ciphertext + auth tag)`.
  Future<String> _encrypt(String plainText, {required bool named}) async {
    final usePrimary = _primary != null;
    final keyId = switch ((usePrimary, named)) {
      (true, false) => _primaryKeyId,
      (false, false) => _fallbackKeyId,
      (true, true) => _namedPrimaryKeyId,
      (false, true) => _namedFallbackKeyId,
    };
    final cipher = _primary ?? _fallback;
    final nonce = secureRandomBytes(secureNonceLength);
    final cipherText = await cipher.encrypt(
      nonce,
      Uint8List.fromList(utf8.encode(plainText)),
    );
    return '$keyId:${base64Encode(nonce)}:${base64Encode(cipherText)}';
  }

  /// Returns whether the payload is a named entry, and its plain text.
  ///
  /// Throws if the payload is malformed, was tampered with, or its key is
  /// unavailable this session.
  Future<(bool, String)> _decrypt(String payload) async {
    final parts = payload.split(':');
    if (parts.length != 3) throw const FormatException('Invalid payload');
    final keyId = parts[0];
    final isNamed = keyId == _namedPrimaryKeyId || keyId == _namedFallbackKeyId;
    final cipher = switch (keyId) {
      _primaryKeyId || _namedPrimaryKeyId =>
        _primary ?? (throw StateError('Primary encryption key unavailable.')),
      _fallbackKeyId || _namedFallbackKeyId => _fallback,
      _ => throw const FormatException('Unknown key id'),
    };
    final plainText = await cipher.decrypt(
      base64Decode(parts[1]),
      base64Decode(parts[2]),
    );
    return (isNamed, utf8.decode(plainText));
  }
}

/// A value stored with its real key name, used when key names are hidden.
///
/// [value] is `null` for a removal recorded while the primary key was
/// unavailable. [time] (microseconds) decides which entry is the newest.
class _NamedEntry {
  final String name;
  final String? value;
  final int time;

  /// Where it is stored, when read from preferences.
  final String? storageKey;

  _NamedEntry(this.name, this.value, this.time, {this.storageKey});

  String encode() => jsonEncode({'n': name, 'v': value, 't': time});

  factory _NamedEntry.decode(String json, {String? storageKey}) {
    final map = jsonDecode(json);
    return _NamedEntry(
      asString(map, 'n'),
      asStringOrNull(map, 'v'),
      asInt(map, 't'),
      storageKey: storageKey,
    );
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
            (value.startsWith('${EncryptedPrefsBackend._primaryKeyId}:') ||
                value.startsWith(
                  '${EncryptedPrefsBackend._namedPrimaryKeyId}:',
                )))
          key,
    };
  }
}
