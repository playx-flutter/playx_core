import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Wrapper for handling shared preferences to save and get preferences.
abstract class PlayxPrefs {
  static SharedPreferences get instance => Get.find<SharedPreferences>();

  @protected
  @visibleForTesting
  static void setMockInitialValues(
    Map<String, Object> values,
  ) =>
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(values);

  /***************************String***************************/

  /// return the shared preferences value in String else returns null.
  static String? maybeGetString(
      String key,
      ) {
    try {
      return instance.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// return the shared preferences value in String else returns [fallback] which default to empty String.
  static String getString(
    String key, {
    String fallback = '',
  }) => maybeGetString(key) ?? fallback;

  /// Set the shared preferences value in [String].
  static Future<void> setString(
    String key,
    String value,
  ) =>
      instance.setString(key, value);



  /***************************int***************************/

  /// return the shared preferences value in [int] else returns null
  static int? maybeGetInt(
    String key,
  ) {
    try {
      return instance.getInt(key);
    } catch (_) {
      return null;
    }
  }

  /// return the shared preferences non null value in [int] else returns [fallback] which default to -1.
  static int getInt(
    String key, {
    int fallback = -1,
  }) => maybeGetInt(key) ?? fallback;

  /// Set the shared preferences value in [int].
  static Future<void> setInt(
    String key,
    int value,
  ) =>
      instance.setInt(key, value);

  /***************************double***************************/

  /// return the shared preferences value in [double] else returns null
  static double? maybeGetDouble(
    String key,
  ) {
    try {
      return instance.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  /// return the shared preferences non null value in [double] else returns [fallback] which default to -1.
  static double? getDouble(
    String key, {
    double fallback = -1,
  }) =>maybeGetDouble(key) ?? fallback;

  /// Set the shared preferences value in [double].
  static Future<void> setDouble(
    String key,
    double value,
  ) =>
      instance.setDouble(key, value);


  /***************************bool***************************/


  /// return the shared preferences value in [bool] else returns null.
  static bool? maybeGetBool(
      String key,
      ) {
    try {
      return instance.getBool(key);
    } catch (_) {
      return null;
    }
  }

  /// return the shared preferences non null value in [bool] else returns [fallback] which default to false.
  static bool getBool(
    String key, {
    bool fallback = false,
  }) =>maybeGetBool(key) ?? fallback;

  /// Set the shared preferences value in [bool].
  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      instance.setBool(key, value);

  /// return the shared preferences value as [Object].
  static Object? find(
    String key,
  ) =>
      instance.get(key);

  /// clear the preferences
  static Future<void> clear() => instance.clear();

  /// remove the given preferences key.
  static Future<void> remove(
    String key,
  ) =>
      instance.remove(key);
}
