import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show Parser;

import 'env_log.dart';
import 'env_values.dart';
import 'loader/env_loader.dart';
import 'playx_env_exception.dart';
import 'playx_env_settings.dart';

/// Application configuration from `.env` files, flavors and `--dart-define`.
///
/// Call [load] once at startup (done by `PlayxCore.bootCore` when
/// `envSettings` is provided), then read values synchronously:
///
/// ```dart
/// final apiUrl = PlayxEnv.getUri('API_URL', fallback: Uri.parse('https://api.example.com'));
/// final retries = PlayxEnv.getInt('RETRIES', fallback: 3);
/// ```
///
/// The getters are shortcuts for the same getters on [values]. See
/// [PlayxEnvSettings] for how files and values are layered.
///
/// **Security:** `.env` files ship as plain text inside the app. Never put
/// secrets in them.
abstract class PlayxEnv {
  static EnvLoadResult? _result;
  static bool _warnedNotLoaded = false;

  // Lifecycle

  /// Loads the configuration described by [settings].
  ///
  /// Throws a [PlayxEnvException] if [PlayxEnvSettings.requiredKeys] are
  /// missing, or if a file is missing and [PlayxEnvSettings.isOptional] is
  /// `false`. Loaded values remain available when required keys are missing.
  static Future<void> load([
    PlayxEnvSettings settings = const PlayxEnvSettings(),
  ]) async {
    _setResult(await EnvLoader.load(settings));
    EnvLoader.checkRequiredKeys(values, settings.requiredKeys);
  }

  /// Loads values from [content] in `.env` format, then [mergeWith],
  /// `PLAYX_DEFINES` (if [usePlayxDefines]) and [dartDefines]. Useful in
  /// tests, or for config fetched at runtime.
  static void loadFromString(
    String content, {
    Map<String, String> mergeWith = const {},
    Map<String, String> dartDefines = const {},
    List<String> requiredKeys = const [],
    bool usePlayxDefines = true,
    Parser parser = const Parser(),
  }) {
    _setResult(
      EnvLoader.loadFromString(
        content,
        mergeWith: mergeWith,
        dartDefines: dartDefines,
        usePlayxDefines: usePlayxDefines,
        parser: parser,
      ),
    );
    EnvLoader.checkRequiredKeys(values, requiredKeys);
  }

  /// Replaces all values with [values], for tests.
  @visibleForTesting
  static void setMockValues(Map<String, String> values) =>
      _setResult(EnvLoadResult(EnvValues(values)));

  /// Clears all values. [load] must be called again before use.
  static Future<void> dispose() async => _setResult(null);

  static void _setResult(EnvLoadResult? result) {
    _result = result;
    _warnedNotLoaded = false;
  }

  // State

  /// Whether [load], [loadFromString] or [setMockValues] has been called.
  static bool get isLoaded => _result != null;

  /// The environment resolved by [load] (e.g. `prod`), if any.
  static String? get environment => _result?.environment;

  /// The files that were found and loaded, in order.
  static List<String> get loadedFiles => _result?.loadedFiles ?? const [];

  /// The loaded values. Empty, with a logged warning, before [load].
  static EnvValues get values {
    final result = _result;
    if (result == null) {
      if (!_warnedNotLoaded) {
        _warnedNotLoaded = true;
        envLogWarning('PlayxEnv was read before load(): no values are set.');
      }
      return _empty;
    }
    return result.values;
  }

  static final _empty = EnvValues();

  /// Every loaded value except secure ones, safe to log or display.
  static Map<String, String> get all => values.all;

  /// Whether [key] has a value.
  static bool containsKey(String key) => values.containsKey(key);

  /// Whether [key] holds a secure value (see [PlayxEnvSettings.secureEnv]).
  static bool isSecure(String key) => values.isSecure(key);

  // Getters, see [EnvValues].

  /// {@macro playx_env.maybeGetString}
  static String? maybeGetString(String key) => values.maybeGetString(key);

  /// {@macro playx_env.getString}
  static String getString(String key, {String fallback = ''}) =>
      values.getString(key, fallback: fallback);

  /// {@macro playx_env.maybeGetInt}
  static int? maybeGetInt(String key) => values.maybeGetInt(key);

  /// {@macro playx_env.getInt}
  static int getInt(String key, {int fallback = -1}) =>
      values.getInt(key, fallback: fallback);

  /// {@macro playx_env.maybeGetDouble}
  static double? maybeGetDouble(String key) => values.maybeGetDouble(key);

  /// {@macro playx_env.getDouble}
  static double getDouble(String key, {double fallback = -1}) =>
      values.getDouble(key, fallback: fallback);

  /// {@macro playx_env.maybeGetNum}
  static num? maybeGetNum(String key) => values.maybeGetNum(key);

  /// {@macro playx_env.getNum}
  static num getNum(String key, {num fallback = -1}) =>
      values.getNum(key, fallback: fallback);

  /// {@macro playx_env.maybeGetBool}
  static bool? maybeGetBool(String key) => values.maybeGetBool(key);

  /// {@macro playx_env.getBool}
  static bool getBool(String key, {bool fallback = false}) =>
      values.getBool(key, fallback: fallback);

  /// {@macro playx_env.maybeGetUri}
  static Uri? maybeGetUri(String key) => values.maybeGetUri(key);

  /// {@macro playx_env.getUri}
  static Uri getUri(String key, {required Uri fallback}) =>
      values.getUri(key, fallback: fallback);

  /// {@macro playx_env.maybeGetEnum}
  static T? maybeGetEnum<T extends Enum>(String key, List<T> enumValues) =>
      values.maybeGetEnum(key, enumValues);

  /// {@macro playx_env.getEnum}
  static T getEnum<T extends Enum>(
    String key,
    List<T> enumValues, {
    required T fallback,
  }) => values.getEnum(key, enumValues, fallback: fallback);

  /// {@macro playx_env.maybeGetDuration}
  static Duration? maybeGetDuration(String key) => values.maybeGetDuration(key);

  /// {@macro playx_env.getDuration}
  static Duration getDuration(String key, {required Duration fallback}) =>
      values.getDuration(key, fallback: fallback);

  /// {@macro playx_env.maybeGetList}
  static List<T>? maybeGetList<T>(
    String key, {
    T Function(dynamic json)? fromJson,
    String separator = ',',
  }) => values.maybeGetList<T>(key, fromJson: fromJson, separator: separator);

  /// {@macro playx_env.getList}
  static List<T> getList<T>(
    String key, {
    List<T> fallback = const [],
    T Function(dynamic json)? fromJson,
    String separator = ',',
  }) => values.getList<T>(
    key,
    fallback: fallback,
    fromJson: fromJson,
    separator: separator,
  );

  /// {@macro playx_env.maybeGetMap}
  static Map<String, dynamic>? maybeGetMap(String key) =>
      values.maybeGetMap(key);

  /// {@macro playx_env.getMap}
  static Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> fallback = const {},
  }) => values.getMap(key, fallback: fallback);

  /// {@macro playx_env.maybeGetObject}
  static T? maybeGetObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
  }) => values.maybeGetObject<T>(key, fromJson: fromJson);

  /// {@macro playx_env.getObject}
  static T getObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
    required T fallback,
  }) => values.getObject<T>(key, fromJson: fromJson, fallback: fallback);
}
