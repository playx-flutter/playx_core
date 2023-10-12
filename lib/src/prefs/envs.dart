import 'package:flutter_dotenv/flutter_dotenv.dart';

///Wrapper for configure any the application with global variables using a `.env` file.
abstract class PlayxEnv {
  static DotEnv get instance => dotenv;

 static Future<void> load(
      {String fileName = '.env',
      Parser parser = const Parser(),
      Map<String, String> mergeWith = const {},
      bool isOptional = true}) async {
    return dotenv.load(
        fileName: fileName,
        parser: parser,
        mergeWith: mergeWith,
        isOptional: isOptional);
  }

  /// return the [dotenv] value in [String] else returns null.
  static Future<String?> maybeGetString(String key) async {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }

  /// return the [dotenv] value in [String] else returns [fallback] which default to empty String.
  static Future<String> getString(String key, {String fallback = ''}) async =>
      await maybeGetString(key) ?? fallback;

  /// return the [dotenv] value in [int] else returns null.
  static Future<int?> maybeGetInt(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return int.parse(value);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the [dotenv] value in [String] else returns [fallback] which default to -1.
  static Future<int> getInt(String key, {int fallback = -1}) async =>
      await maybeGetInt(key) ?? fallback;

  /// return the [dotenv] value in [double] else returns null.
  static Future<double?> maybeGetDouble(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return double.parse(value);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the [dotenv] value in [String] else returns [fallback] which default to -1.
  static Future<double> getDouble(String key, {double fallback = -1}) async =>
      await maybeGetDouble(key) ?? fallback;

  /// return the [dotenv] value in [bool] else returns null.
  static Future<bool?> maybeGetBool(
    String key,
  ) async {
    final value = await maybeGetString(key);
    if (value == null) return null;
    try {
      return value.toLowerCase() == 'true' || value.toLowerCase() == '1';
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// return the [dotenv] value in [String] else returns [fallback] which default to -1.
  static Future<bool> getBool(String key, {bool fallback = false}) async =>
      await maybeGetBool(key) ?? fallback;
}
