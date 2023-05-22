library playx_core;

import '../playx_core.dart';

export '../playx_core.dart';

/// Core of playx_core plugin.
/// used setup and disposing required dependencies needed for playx_core.
abstract class PlayXCore {
  /// used initialize and install dependencies needed for playx_core.
  static Future<void> bootCore() async {
    /// inject SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
  }

  ///Dispose PlayxCore
  static Future<void> dispose() async {
    Get.reset();
  }
}
