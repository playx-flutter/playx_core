library playx_core;

import '../playx_core.dart';

/// Core of playx_core plugin.
/// used setup and disposing required dependencies needed for playx_core.
abstract class PlayXCore {
  /// used initialize and install dependencies needed for playx_core.
  static Future<void> bootCore({
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxEnvSettings? envSettings,
  }) async {
    /// inject SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    final securePrefs = FlutterSecureStorage(
      iOptions: securePrefsSettings.iosOptions,
      aOptions: securePrefsSettings.androidOptions,
      lOptions: securePrefsSettings.linuxOptions,
      wOptions: securePrefsSettings.windowsOptions,
      webOptions: securePrefsSettings.webOptions,
      mOptions: securePrefsSettings.macOsOptions,
    );
    Get.put<FlutterSecureStorage>(securePrefs, permanent: true);
    if (envSettings != null) {
      await PlayxEnv.load(
        fileName: envSettings.fileName,
        parser: envSettings.parser,
        mergeWith: envSettings.mergeWith,
        isOptional: envSettings.isOptional,
      );
    }
  }

  ///Dispose PlayxCore
  static Future<void> dispose() async {
    Get.reset();
  }
}
