/// The storage backend used by [PlayxSecurePrefs].
///
/// **On web**, every type except [memory] uses [encryptedPrefs] with a
/// non-extractable WebCrypto key kept in IndexedDB: no password, salt or key
/// ships with the app, and the key bytes can't be read by JavaScript.
enum PlayxSecureStorageType {
  /// Uses `flutter_secure_storage` (Keystore / Keychain / libsecret / DPAPI / WebCrypto).
  ///
  /// This is the default and matches the behavior of previous versions.
  flutterSecureStorage,

  /// Uses `simple_secure_storage` (Keystore / Keychain / libsecret / DPAPI / IndexedDB).
  ///
  /// Initialization errors are rethrown unless
  /// [PlayxSecurePrefsSettings.throwOnError] is `false`. Prefer [auto] if you
  /// want the app to keep working on devices where it is broken.
  simpleSecureStorage,

  /// Stores values in `SharedPreferencesAsync`, encrypted with AES-GCM.
  ///
  /// The encryption key is generated on-device and kept in the first healthy
  /// store of [PlayxEncryptedPrefsOptions.keyStores]. If none is available, a
  /// random per-device fallback key kept in preferences is used, which only
  /// obfuscates data.
  ///
  /// If preferences themselves are unavailable, [memory] is used.
  encryptedPrefs,

  /// **Recommended when using `simple_secure_storage`.**
  ///
  /// Uses the first backend of [PlayxSecurePrefsSettings.autoOrder] that passes
  /// a write/read health check, and [memory] if none does.
  ///
  /// Values written while on a fallback backend are moved back to the
  /// preferred backend on a later start where it works again.
  auto,

  /// Keeps values in memory only. Nothing is persisted across restarts.
  ///
  /// Used as the last resort by [auto] and [encryptedPrefs]. It can also be
  /// selected directly, e.g. in tests.
  memory,
}
