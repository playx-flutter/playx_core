import 'encrypted_prefs_options.dart';
import 'flutter_secure_storage_options.dart';
import 'secure_storage_type.dart';
import 'simple_secure_storage_options.dart';

export 'encrypted_prefs_options.dart';
export 'flutter_secure_storage_options.dart';
export 'secure_storage_type.dart';
export 'simple_secure_storage_options.dart';

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
