import 'package:playx_core/src/utils/safe_convert.dart';

/// Internal helper to safely get a value from a JSON map by key.
/// Returns null if the JSON is null, not a map, or if the key is missing.
dynamic _getJsonValueOrNull(dynamic json, String key) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return json[key];
}

/// ====================
/// int conversions
/// ====================

/// Returns an int if the value at [key] can be converted, otherwise null.
int? asIntOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toIntOrNull(value);
}

/// Returns an int for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
int asInt(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toInt(value);
}

/// Returns an int for the value at [key], or [fallback] if conversion fails.
int asIntOr(dynamic json, String key, {int fallback = 0}) {
  final value = _getJsonValueOrNull(json, key);
  return toIntOr(value, fallback: fallback);
}

/// ====================
/// double conversions
/// ====================

/// Returns a double if the value at [key] can be converted, otherwise null.
double? asDoubleOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toDoubleOrNull(value);
}

/// Returns a double for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
double asDouble(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toDouble(value);
}

/// Returns a double for the value at [key], or [fallback] if conversion fails.
double asDoubleOr(dynamic json, String key, {double fallback = 0.0}) {
  final value = _getJsonValueOrNull(json, key);
  return toDoubleOr(value, fallback: fallback);
}

/// ====================
/// num conversions
/// ====================

/// Returns a num (int or double) if the value at [key] can be converted, otherwise null.
num? asNumOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toNumOrNull(value);
}

/// Returns a num (int or double) for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
num asNum(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toNum(value);
}

/// Returns a num (int or double) for the value at [key], or [fallback] if conversion fails.
num asNumOr(dynamic json, String key, {num fallback = 0}) {
  final value = _getJsonValueOrNull(json, key);
  return toNumOr(value, fallback: fallback);
}

/// ====================
/// bool conversions
/// ====================

/// Returns a bool if the value at [key] can be converted, otherwise null.
bool? asBoolOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toBoolOrNull(value);
}

/// Returns a bool for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
bool asBool(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toBool(value);
}

/// Returns a bool for the value at [key], or [fallback] if conversion fails.
bool asBoolOr(dynamic json, String key, {bool fallback = false}) {
  final value = _getJsonValueOrNull(json, key);

  return toBoolOr(value, fallback: fallback);
}

/// ====================
/// String conversions
/// ====================

/// Returns a String if the value at [key] can be converted, otherwise null.
String? asStringOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toStringOrNull(value);
}

/// Returns a String for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
String asString(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toString(value);
}

/// Returns a String for the value at [key], or [fallback] if conversion fails.
String asStringOr(dynamic json, String key, {String fallback = ''}) {
  final value = _getJsonValueOrNull(json, key);
  return toStringOr(value, fallback: fallback);
}

/// ====================
/// DateTime conversions
/// ====================

/// Returns a DateTime if the value at [key] can be parsed, otherwise null.
DateTime? asDateTimeOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toDateTimeOrNull(value);
}

/// Returns a DateTime for the value at [key].
/// Throws a [FormatException] if the value cannot be parsed.
DateTime asDateTime(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toDateTime(value);
}

/// Returns a DateTime for the value at [key], or [fallback] if parsing fails.
DateTime asDateTimeOr(dynamic json, String key, {required DateTime fallback}) {
  final value = _getJsonValueOrNull(json, key);
  return toDateTimeOr(value, fallback: fallback);
}

/// Returns a local [DateTime] with current timezone if the value at [key] can be parsed, otherwise null.
DateTime? asLocalDateTimeOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toLocalDateTimeOrNull(value);
}

/// Returns a local [DateTime] for the value at [key].
/// Throws a [FormatException] if the value cannot be parsed.
DateTime asLocalDateTime(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toLocalDateTime(value);
}

/// Returns a local [DateTime] for the value at [key], or [fallback] if parsing fails.
DateTime asLocalDateTimeOr(dynamic json, String key,
    {required DateTime fallback}) {
  final value = _getJsonValueOrNull(json, key);
  return toLocalDateTimeOr(value, fallback: fallback);
}

/// ====================
/// Map conversions
/// ====================

/// Returns a Map if the value at [key] is a map, otherwise null.
Map<T, S>? asMapOrNull<T, S>(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toMapOrNull(value);
}

/// Returns a Map for the value at [key].
/// Throws a [FormatException] if the value is not a map.
Map<T, S> asMap<T, S>(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toMap(value);
}

/// Returns a Map for the value at [key], or [fallback] if conversion fails.
Map<T, S> asMapOr<T, S>(dynamic json, String key,
    {Map<T, S> fallback = const {}}) {
  final value = _getJsonValueOrNull(json, key);
  return toMapOr(value, fallback: fallback);
}

/// ====================
/// List[int] conversions
/// ====================

/// Returns a List[int] if the value at [key] is a list of ints, otherwise null.
List<int>? asListIntOrNull(dynamic json, String key,
    {int Function(dynamic json)? fromJson}) {
  final list = asListOrNull<dynamic>(json, key, fromJson: fromJson)
      ?.map(toIntOrNull)
      .toList();
  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<int>().toList();
}

/// Returns a List[int] for the value at [key].
/// Throws a [FormatException] if the value is not a list of ints.
List<int> asListInt(dynamic json, String key,
    {int Function(dynamic json)? fromJson}) {
  return asListOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid List<int> value for key: $key'));
}

/// Returns a List[int] for the value at [key], or [fallback] if conversion fails.
List<int> asListIntOr(dynamic json, String key,
    {List<int> fallback = const [], int Function(dynamic json)? fromJson}) {
  return asListOrNull(json, key, fromJson: fromJson) ?? fallback;
}

/// ====================
/// List[String] conversions
/// ====================

/// Returns a List if the value at [key] is a list of strings, otherwise null.
List<String>? asListStringOrNull(dynamic json, String key,
    {String Function(dynamic json)? fromJson}) {
  final list = asListOrNull<dynamic>(json, key, fromJson: fromJson)
      ?.map(toStringOrNull)
      .toList();
  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<String>().toList();
}

/// Returns a List for the value at [key].
/// Throws a [FormatException] if the value is not a list of strings.
List<String> asListString(dynamic json, String key,
    {String Function(dynamic json)? fromJson}) {
  return asListStringOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid List<String> value for key: $key'));
}

/// Returns a List for the value at [key], or [fallback] if conversion fails.
List<String> asListStringOr(dynamic json, String key,
    {List<String> fallback = const [],
    String Function(dynamic json)? fromJson}) {
  return asListStringOrNull(json, key, fromJson: fromJson) ?? fallback;
}

/// ====================
/// List conversions (generic)
/// ====================

/// Converts the value at [key] to a List? using [fromJson].
/// Returns null if conversion fails or any element cannot be converted.
List<T>? asListOrNull<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson}) {
  final value = _getJsonValueOrNull(json, key);
  final list = toListOrNull<T>(value, fromJson: fromJson);

  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<T>().toList();
}

/// Converts the value at [key] to a List.
List<T> asList<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson}) {
  return asListOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid List<$T> value for key: $key'));
}

/// Converts the value at [key] to a List.
List<T> asListOr<T>(dynamic json, String key,
    {List<T> fallback = const [], T Function(dynamic json)? fromJson}) {
  return asListOrNull(json, key, fromJson: fromJson) ?? fallback;
}

/// ====================
/// Generic conversion
/// ====================

/// Converts the value at [key] to type T.
/// Returns null if conversion fails.
/// Supports custom [fromJson] function to convert the value.
T? asTOrNull<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson}) {
  final value = _getJsonValueOrNull(json, key);
  try {
    if (fromJson != null) return fromJson(value);

    if (value is T) return value;

    if (0.0 is T) return toDoubleOrNull(value) as T?;
    if (0 is T) return toIntOrNull(value) as T?;
    if ('' is T) return toStringOrNull(value) as T?;
    if (false is T) return toBoolOrNull(value) as T?;
    if ([] is T) return toListOrNull(value) as T?;
    if (<String, dynamic>{} is T) return toMapOrNull(value) as T?;
    if (DateTime.now() is T) return toDateTimeOrNull(value) as T?;
  } catch (_) {
    return null;
  }
  return null;
}

T asTOr<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson, required T fallback}) {
  return asTOrNull(json, key, fromJson: fromJson) ?? fallback;
}

T asT<T>(dynamic json, String key, {T Function(dynamic json)? fromJson}) {
  return asTOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid <$T> value for key: $key'));
}
