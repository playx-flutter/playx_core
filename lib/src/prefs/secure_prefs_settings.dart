import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefsSettings {
  final IOSOptions iosOptions;
  final AndroidOptions androidOptions;
  final LinuxOptions linuxOptions;
  final WindowsOptions windowsOptions;
  final WebOptions webOptions;
  final MacOsOptions macOsOptions;

  const SecurePrefsSettings({
    this.iosOptions =
        const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    this.androidOptions = const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    this.linuxOptions = LinuxOptions.defaultOptions,
    this.windowsOptions = WindowsOptions.defaultOptions,
    this.webOptions = WebOptions.defaultOptions,
    this.macOsOptions = MacOsOptions.defaultOptions,
  });
}
