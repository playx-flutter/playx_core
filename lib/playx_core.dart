library playx_core;

import 'exports.dart';
export 'exports.dart';

abstract class PlayXCore {
  static Future<void> bootCore() async {
    /// inject SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
  }

  static Future<void> dispose() async {
    Get.reset();
  }
}
