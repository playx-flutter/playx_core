import 'package:flutter/foundation.dart';

import '../utils/json_value_codec.dart';
import '../utils/safe_convert.dart';
import 'parsers/env_value_parser.dart';

/// A read-only set of configuration values with typed getters.
///
/// [PlayxEnv] keeps the loaded values in one (see [PlayxEnv.values]). It can
/// also wrap any other `Map<String, String>`, such as remote config:
///
/// ```dart
/// final config = EnvValues({'RETRIES': '3'});
/// config.getInt('RETRIES'); // 3
/// ```
///
/// Every type has a `maybeGet*` getter returning `null` when the key is
/// missing or the value can't be converted, and a `get*` getter returning a
/// fallback instead.
@immutable
class EnvValues {
  final Map<String, String> _values;

  /// Wraps a copy of [values].
  EnvValues([Map<String, String> values = const {}])
    : _values = Map.unmodifiable(values);

  /// Every value.
  Map<String, String> get all => _values;

  /// Whether [key] has a value.
  bool containsKey(String key) => _values.containsKey(key);

  /// Keys of [keys] without a non-empty value.
  List<String> missingKeys(Iterable<String> keys) => [
    for (final key in keys)
      if (_values[key]?.isNotEmpty != true) key,
  ];

  // String

  /// {@template playx_env.maybeGetString}
  /// Returns the value of [key], or `null` if it isn't set.
  /// {@endtemplate}
  String? maybeGetString(String key) => _values[key];

  /// {@template playx_env.getString}
  /// Returns the value of [key], or [fallback] if it isn't set.
  /// {@endtemplate}
  String getString(String key, {String fallback = ''}) =>
      maybeGetString(key) ?? fallback;

  // Numbers

  /// {@template playx_env.maybeGetInt}
  /// Returns the value of [key] as an `int`, or `null` if it isn't set or
  /// isn't a number. Decimals are truncated.
  /// {@endtemplate}
  int? maybeGetInt(String key) => toIntOrNull(maybeGetString(key));

  /// {@template playx_env.getInt}
  /// Returns the value of [key] as an `int`, or [fallback].
  /// {@endtemplate}
  int getInt(String key, {int fallback = -1}) => maybeGetInt(key) ?? fallback;

  /// {@template playx_env.maybeGetDouble}
  /// Returns the value of [key] as a `double`, or `null` if it isn't set or
  /// isn't a number.
  /// {@endtemplate}
  double? maybeGetDouble(String key) => toDoubleOrNull(maybeGetString(key));

  /// {@template playx_env.getDouble}
  /// Returns the value of [key] as a `double`, or [fallback].
  /// {@endtemplate}
  double getDouble(String key, {double fallback = -1}) =>
      maybeGetDouble(key) ?? fallback;

  /// {@template playx_env.maybeGetNum}
  /// Returns the value of [key] as a `num`, or `null` if it isn't set or isn't
  /// a number.
  /// {@endtemplate}
  num? maybeGetNum(String key) => toNumOrNull(maybeGetString(key));

  /// {@template playx_env.getNum}
  /// Returns the value of [key] as a `num`, or [fallback].
  /// {@endtemplate}
  num getNum(String key, {num fallback = -1}) => maybeGetNum(key) ?? fallback;

  // Bool

  /// {@template playx_env.maybeGetBool}
  /// Returns the value of [key] as a `bool`: `true`/`1` or `false`/`0`
  /// (case-insensitive). `null` if it isn't set or is anything else.
  /// {@endtemplate}
  bool? maybeGetBool(String key) => toBoolOrNull(maybeGetString(key));

  /// {@template playx_env.getBool}
  /// Returns the value of [key] as a `bool`, or [fallback].
  /// {@endtemplate}
  bool getBool(String key, {bool fallback = false}) =>
      maybeGetBool(key) ?? fallback;

  // Uri

  /// {@template playx_env.maybeGetUri}
  /// Returns the value of [key] as a [Uri], or `null` if it isn't set or
  /// can't be parsed.
  /// {@endtemplate}
  Uri? maybeGetUri(String key) => toUriOrNull(maybeGetString(key));

  /// {@template playx_env.getUri}
  /// Returns the value of [key] as a [Uri], or [fallback].
  /// {@endtemplate}
  Uri getUri(String key, {required Uri fallback}) =>
      maybeGetUri(key) ?? fallback;

  // Enum

  /// {@template playx_env.maybeGetEnum}
  /// Returns the enum value of [values] whose name matches the value of [key]
  /// (case-insensitive), or `null`.
  /// {@endtemplate}
  T? maybeGetEnum<T extends Enum>(String key, List<T> values) =>
      toEnumOrNull<T>(maybeGetString(key), values);

  /// {@template playx_env.getEnum}
  /// Returns the enum value of [values] matching the value of [key], or
  /// [fallback].
  /// {@endtemplate}
  T getEnum<T extends Enum>(
    String key,
    List<T> values, {
    required T fallback,
  }) => maybeGetEnum<T>(key, values) ?? fallback;

  // Duration

  /// {@template playx_env.maybeGetDuration}
  /// Returns the value of [key] as a [Duration], or `null` if it isn't set or
  /// can't be parsed.
  ///
  /// Accepts a number with a unit: `ms`, `s`, `m`, `h` or `d` (e.g. `250ms`,
  /// `30s`, `5m`, `1.5h`). A number without a unit is in milliseconds.
  /// {@endtemplate}
  Duration? maybeGetDuration(String key) =>
      parseEnvDuration(maybeGetString(key));

  /// {@template playx_env.getDuration}
  /// Returns the value of [key] as a [Duration], or [fallback].
  /// {@endtemplate}
  Duration getDuration(String key, {required Duration fallback}) =>
      maybeGetDuration(key) ?? fallback;

  // List

  /// {@template playx_env.maybeGetList}
  /// Returns the value of [key] as a list, or `null` if it isn't set or an
  /// item can't be converted.
  ///
  /// Accepts a JSON array (`[1, 2, 3]`) or [separator]-separated values
  /// (`a, b, c`; items are trimmed and empty ones skipped).
  ///
  /// Items are converted with [fromJson] if provided. Otherwise `String`,
  /// `int`, `double`, `num`, `bool` and `Uri` items are parsed.
  /// {@endtemplate}
  List<T>? maybeGetList<T>(
    String key, {
    T Function(dynamic json)? fromJson,
    String separator = ',',
  }) => parseEnvList<T>(
    maybeGetString(key),
    fromJson: fromJson,
    separator: separator,
  );

  /// {@template playx_env.getList}
  /// Returns the value of [key] as a list, or [fallback].
  /// {@endtemplate}
  List<T> getList<T>(
    String key, {
    List<T> fallback = const [],
    T Function(dynamic json)? fromJson,
    String separator = ',',
  }) =>
      maybeGetList<T>(key, fromJson: fromJson, separator: separator) ??
      fallback;

  // JSON

  /// {@template playx_env.maybeGetMap}
  /// Returns the value of [key] parsed as a JSON object, or `null`.
  /// {@endtemplate}
  Map<String, dynamic>? maybeGetMap(String key) =>
      decodeJsonMapOrNull(maybeGetString(key));

  /// {@template playx_env.getMap}
  /// Returns the value of [key] parsed as a JSON object, or [fallback].
  /// {@endtemplate}
  Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> fallback = const {},
  }) => maybeGetMap(key) ?? fallback;

  /// {@template playx_env.maybeGetObject}
  /// Returns the value of [key] parsed as JSON and converted with [fromJson],
  /// or `null` if it isn't set, isn't valid JSON, or [fromJson] throws.
  /// {@endtemplate}
  T? maybeGetObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
  }) => decodeJsonObjectOrNull<T>(maybeGetString(key), fromJson: fromJson);

  /// {@template playx_env.getObject}
  /// Returns the value of [key] converted with [fromJson], or [fallback].
  /// {@endtemplate}
  T getObject<T>(
    String key, {
    required T Function(dynamic json) fromJson,
    required T fallback,
  }) => maybeGetObject<T>(key, fromJson: fromJson) ?? fallback;
}
