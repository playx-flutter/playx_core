import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

abstract class SecurePrefs {

  static FlutterSecureStorage get instance => Get.find<FlutterSecureStorage>();

  Future<String?> getString(
    String key) async =>
      await instance.read(
        key: key,
      );

  Future<void> setString(
    String key,
    String value,
  ) => instance.write(key: key, value: value);

  Future<int?> getInt(
    String key,) async {
    final value = await getString(key);
    if (value == null) return null;
    try {
      return int.parse(value);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  Future<void> setInt(
    String key,
    int value,
  ) => setString(key, value.toString());

  Future<bool> getBool(
    String key, {
    bool? defaultValue,
  }) async {
    final value = await getString(key);
    if (value == null) return false;
    try {
      return value.toLowerCase() == 'true' || value.toLowerCase() == '1';
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return false;
    }
  }

  Future<void> setBool(
    String key,
    bool value,
  ) =>
      setString(key, value.toString());

  /// clear the preferences
  Future<void> clear() => instance.deleteAll();

  Future<void> remove(
    String key,
  ) =>
      instance.delete(key: key);
}
