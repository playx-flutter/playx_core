library playx_core;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playx_core.dart';

export 'exports.dart';

abstract class PlayXCore {
  static Future<void> bootCore() async {
    /// inject SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
  }

  @visibleForTesting
  static Future<void> disbose() async {
    Get.reset();
  }
}
