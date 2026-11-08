import 'package:simple_secure_storage/simple_secure_storage.dart';

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
