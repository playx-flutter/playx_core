import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

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
  /// fallback key is used (see [PlayxEncryptedPrefsOptions.fallbackEncryptionKey]).
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

/// Options used to initialize `simple_secure_storage`.
class PlayxSimpleSecureStorageOptions {
  /// Your app name.
  final String? appName;

  /// Your app namespace (e.g. `com.example.app`).
  final String? namespace;

  /// Prefix automatically prepended to keys to avoid conflicts on some platforms.
  final String? prefix;

  /// Keychain accessibility on iOS and macOS.
  final DarwinAccessibility darwinAccessibility;

  const PlayxSimpleSecureStorageOptions({
    this.appName,
    this.namespace,
    this.prefix = 'sss_',
    this.darwinAccessibility = DarwinAccessibility.afterFirstUnlock,
  });
}

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

/// `flutter_secure_storage` platform options.
///
/// Not used on web.
class PlayxFlutterSecureStorageOptions {
  final IOSOptions iosOptions;
  final AndroidOptions androidOptions;
  final LinuxOptions linuxOptions;
  final WindowsOptions windowsOptions;
  final MacOsOptions macOsOptions;

  const PlayxFlutterSecureStorageOptions({
    this.iosOptions = const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    this.androidOptions = const AndroidOptions(),
    this.linuxOptions = LinuxOptions.defaultOptions,
    this.windowsOptions = WindowsOptions.defaultOptions,
    this.macOsOptions = MacOsOptions.defaultOptions,
  });
}

///Settings for [PlayxSecurePrefs].
class PlayxSecurePrefsSettings {
  /// Which backend to use. Defaults to [PlayxSecureStorageType.flutterSecureStorage].
  final PlayxSecureStorageType storageType;

  /// Order in which [PlayxSecureStorageType.auto] tries backends.
  ///
  /// Supported values: [PlayxSecureStorageType.simpleSecureStorage],
  /// [PlayxSecureStorageType.flutterSecureStorage] and
  /// [PlayxSecureStorageType.encryptedPrefs].
  /// [PlayxSecureStorageType.memory] is always used as the last resort.
  ///
  /// The first entry is the preferred backend: data written to a fallback is
  /// moved back to it once it works again.
  ///
  /// Note: native crashes (as opposed to Dart exceptions) can't be caught, so
  /// put backends known to crash on your target devices last or remove them.
  final List<PlayxSecureStorageType> autoOrder;

  /// When `false`, errors while reading, writing, removing or clearing are
  /// logged instead of thrown: reads return `null` and writes are ignored.
  /// If the selected backend can't be created, [PlayxSecureStorageType.memory]
  /// is used instead of throwing.
  ///
  /// Defaults to `true`.
  final bool throwOnError;

  /// Whether to hide key names where the storage would otherwise expose them:
  ///
  /// - [PlayxSecureStorageType.encryptedPrefs] (on every platform, so all of
  ///   web), whose names would be visible in the preferences file;
  /// - [PlayxSecureStorageType.flutterSecureStorage] on Android, which keeps
  ///   names in plain text in a private preferences file.
  ///
  /// Each value is stored under a keyed hash (HMAC-SHA256) of its name, and
  /// the real name is kept inside the encrypted value. The hashing key is kept
  /// in secure storage, so names can't be guessed from the files alone.
  ///
  /// `simple_secure_storage` already encrypts names on Android, and the
  /// Keychain keeps them out of app files on iOS and macOS.
  ///
  /// Can be turned on or off at any time: stored values are converted. Costs
  /// an extra hash per operation.
  ///
  /// Defaults to `false`.
  final bool encryptKeys;

  /// `flutter_secure_storage` options.
  final PlayxFlutterSecureStorageOptions flutterSecureStorageOptions;

  /// `simple_secure_storage` options.
  final PlayxSimpleSecureStorageOptions simpleSecureStorageOptions;

  /// Encrypted preferences options.
  final PlayxEncryptedPrefsOptions encryptedPrefsOptions;

  /// If `true`, the storage is cleared on the first start after a reinstall.
  ///
  /// Useful on iOS and macOS, where the Keychain survives uninstalling the app.
  final bool clearOnReinstall;

  /// If [createSecurePrefs] is set to `true`, the storage will be created on boot.
  final bool createSecurePrefs;

  const PlayxSecurePrefsSettings({
    this.storageType = PlayxSecureStorageType.flutterSecureStorage,
    this.autoOrder = const [
      PlayxSecureStorageType.simpleSecureStorage,
      PlayxSecureStorageType.flutterSecureStorage,
      PlayxSecureStorageType.encryptedPrefs,
    ],
    this.throwOnError = true,
    this.encryptKeys = false,
    this.flutterSecureStorageOptions = const PlayxFlutterSecureStorageOptions(),
    this.simpleSecureStorageOptions = const PlayxSimpleSecureStorageOptions(),
    this.encryptedPrefsOptions = const PlayxEncryptedPrefsOptions(),
    this.clearOnReinstall = true,
    this.createSecurePrefs = true,
  });
}
