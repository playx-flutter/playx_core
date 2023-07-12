library playx_core;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playx_core/src/prefs/secure_prefs_settings.dart';
import '../playx_core.dart';

/// Core of playx_core plugin.
/// used setup and disposing required dependencies needed for playx_core.
abstract class PlayXCore {
  /// used initialize and install dependencies needed for playx_core.
  static Future<void> bootCore({SecurePrefsSettings? securePrefsSettings}) async {
    /// inject SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    final securePrefs =   FlutterSecureStorage(
      iOptions : securePrefsSettings?.iosOptions ?? IOSOptions.defaultOptions,
      aOptions : securePrefsSettings?.androidOptions ?? AndroidOptions.defaultOptions,
      lOptions :securePrefsSettings?.linuxOptions ?? LinuxOptions.defaultOptions,
      wOptions : securePrefsSettings?.windowsOptions ??WindowsOptions.defaultOptions,
      webOptions :securePrefsSettings?.webOptions ?? WebOptions.defaultOptions,
      mOptions :securePrefsSettings?.macOsOptions ?? MacOsOptions.defaultOptions,
    );
    Get.put<FlutterSecureStorage>(securePrefs, permanent: true);

  }

  ///Dispose PlayxCore
  static Future<void> dispose() async {
    Get.reset();
  }
}
