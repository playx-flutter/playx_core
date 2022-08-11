import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Prefs {
  static SharedPreferences get instance => Get.find<SharedPreferences>();

  @protected
  @visibleForTesting
  static void setMockInitialValues(
    Map<String, Object> values,
  ) =>
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(values);

  static String? getString(
    String key,
  ) =>
      instance.getString(key);

  static Future<void> setString(
    String key,
    String value,
  ) =>
      instance.setString(key, value);

  static int? getInt(
    String key,
  ) =>
      instance.getInt(key);

  static Future<void> setInt(
    String key,
    int value,
  ) =>
      instance.setInt(key, value);

  static bool getBool(
    String key,
  ) =>
      instance.getBool(key) ?? false;

  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      instance.setBool(key, value);

  static Object? find(
    String key,
  ) =>
      instance.get(key);

  /// clear the preferences
  static Future<void> clear() => instance.clear();

  static Future<void> remove(
    String key,
  ) =>
      instance.remove(key);
}
