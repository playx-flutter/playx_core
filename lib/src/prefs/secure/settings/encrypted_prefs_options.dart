import 'secure_storage_type.dart';

/// Options for the [PlayxSecureStorageType.encryptedPrefs] backend.
class PlayxEncryptedPrefsOptions {
  /// Prefix prepended to every key stored in preferences.
  ///
  /// It isolates secure values from your other preferences, so
  /// [PlayxSecurePrefs.clear] only removes keys starting with this prefix.
  /// Must not be empty.
  final String keyPrefix;

  /// Where to keep the generated AES key, in order of preference.
  ///
  /// Only [PlayxSecureStorageType.simpleSecureStorage] and
  /// [PlayxSecureStorageType.flutterSecureStorage] are supported. Each store is
  /// health checked before use. Once a key has been created, the store holding
  /// it is remembered and the key is not regenerated while values encrypted
  /// with it may still be readable.
  ///
  /// If no store is available, a random per-device fallback key kept in plain
  /// preferences is used. It only **obfuscates** data.
  ///
  /// Ignored on web, where a non-extractable WebCrypto key is used.
  final List<PlayxSecureStorageType> keyStores;

  const PlayxEncryptedPrefsOptions({
    this.keyPrefix = 'playx_secure_',
    this.keyStores = const [
      PlayxSecureStorageType.simpleSecureStorage,
      PlayxSecureStorageType.flutterSecureStorage,
    ],
  }) : assert(keyPrefix != '', 'keyPrefix must not be empty');
}
