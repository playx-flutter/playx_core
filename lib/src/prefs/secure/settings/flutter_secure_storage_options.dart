import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
