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
  return toInt(asTOrNull(json, key));
}

/// Returns an int for the value at [key], or [fallback] if conversion fails.
int asIntOr(dynamic json, String key, {int fallback = 0}) {
  return toIntOr(asTOrNull(json, key), fallback: fallback);
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
  return toDouble(asTOrNull(json, key));
}

/// Returns a double for the value at [key], or [fallback] if conversion fails.
double asDoubleOr(dynamic json, String key, {double fallback = 0.0}) {
  return toDoubleOr(asTOrNull(json, key), fallback: fallback);
}

/// ====================
/// num conversions
/// ====================

/// Returns a num (int or double) if the value at [key] can be converted, otherwise null.
num? asNumOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  final intValue = toIntOrNull(value);
  if (intValue != null) return intValue;
  return toDoubleOrNull(value);
}

/// Returns a num (int or double) for the value at [key].
/// Throws a [FormatException] if the value cannot be converted.
num asNum(dynamic json, String key) {
  final val = asTOrNull<num>(json, key);
  if (val != null) return val;
  throw FormatException('Invalid num value for key: $key');
}

/// Returns a num (int or double) for the value at [key], or [fallback] if conversion fails.
num asNumOr(dynamic json, String key, {num fallback = 0}) {
  final val = asTOrNull<num>(json, key);
  if (val != null) return val;
  return fallback;
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
  return toBool(asTOrNull(json, key));
}

/// Returns a bool for the value at [key], or [fallback] if conversion fails.
bool asBoolOr(dynamic json, String key, {bool fallback = false}) {
  return toBoolOr(asTOrNull(json, key), fallback: fallback);
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
  return toString(asTOrNull(json, key));
}

/// Returns a String for the value at [key], or [fallback] if conversion fails.
String asStringOr(dynamic json, String key, {String fallback = ''}) {
  return toStringOr(asTOrNull(json, key), fallback: fallback);
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
  return toDateTime(asTOrNull(json, key));
}

/// Returns a DateTime for the value at [key], or [fallback] if parsing fails.
DateTime asDateTimeOr(dynamic json, String key, {required DateTime fallback}) {
  return toDateTimeOr(asTOrNull(json, key), fallback: fallback);
}

/// ====================
/// Map<String, dynamic> conversions
/// ====================

/// Returns a Map<String, dynamic> if the value at [key] is a map, otherwise null.
Map<String, dynamic>? asMapOrNull(dynamic json, String key) {
  final value = _getJsonValueOrNull(json, key);
  return toMapOrNull(value);
}

/// Returns a Map<String, dynamic> for the value at [key].
/// Throws a [FormatException] if the value is not a map.
Map<String, dynamic> asMap(dynamic json, String key) {
  return toMap(asTOrNull(json, key));
}

/// Returns a Map<String, dynamic> for the value at [key], or [fallback] if conversion fails.
Map<String, dynamic> asMapOr(dynamic json, String key,
    {Map<String, dynamic> fallback = const {}}) {
  return toMapOr(asTOrNull(json, key), fallback: fallback);
}

/// ====================
/// List<int> conversions
/// ====================

/// Returns a List<int> if the value at [key] is a list of ints, otherwise null.
List<int>? asListIntOrNull(dynamic json, String key,
    {int Function(dynamic json)? fromJson}) {
  final list = asListOrNull<int>(json, key, fromJson: fromJson)
      ?.map(toIntOrNull)
      .toList();
  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<int>().toList();
}

/// ====================
/// List<String> conversions
/// ====================

/// Returns a List<String> if the value at [key] is a list of strings, otherwise null.
List<String>? asListStringOrNull(dynamic json, String key,{String Function(dynamic json)? fromJson}) {
  final list = asListOrNull(json, key,fromJson: fromJson)?.map(toStringOrNull).toList();
  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<String>().toList();
}

/// Returns a List<String> for the value at [key].
/// Throws a [FormatException] if the value is not a list of strings.
List<String> asListString(dynamic json, String key) {
  final list = asListOrNull(json, key)?.map(toStringOrNull).toList();
  if (list == null || list.any((element) => element == null)) {
    throw FormatException('Invalid List<String> value for key: $key');
  }
  return list.whereType<String>().toList();
}

/// Returns a List<String> for the value at [key], or [fallback] if conversion fails.
List<String> asListStringOr(dynamic json, String key,
    {List<String> fallback = const [], String Function(dynamic json)? fromJson}) {
  final list = asListOrNull(json, key,fromJson: fromJson)?.map(toStringOrNull).toList();
  if (list == null || list.any((element) => element == null)) return fallback;
  return list.whereType<String>().toList();
}

/// ====================
/// List<T> conversions (generic)
/// ====================

/// Converts the value at [key] to a List<T>.
List<T> asList<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson}) {
  return toListT(asTOrNull(
    json,
    key,
  ));
}

/// Converts the value at [key] to a List<T>.
List<T> asListOr<T>(dynamic json, String key,
    {List<T> fallback = const [], T Function(dynamic json)? fromJson}) {
  return toListTOr(asTOrNull(json, key), fallback: fallback);
}

/// Converts the value at [key] to a List<T>? using [fromJson].
/// Returns null if conversion fails or any element cannot be converted.
List<T>? asListOrNull<T>(dynamic json, String key,
    {T Function(dynamic json)? fromJson}) {
  final list = asListOrNull(json, key, fromJson: fromJson)?.map((e) {
    try {
      return fromJson?.call(e);
    } catch (_) {
      return null;
    }
  }).toList();

  if (list == null || list.any((element) => element == null)) return null;
  return list.whereType<T>().toList();
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
    if ([] is T) return toListOrNullT(value) as T?;
    if (<String, dynamic>{} is T) return toMapOrNull(value) as T?;
    if (DateTime.now() is T) return toDateTimeOrNull(value) as T?;
  } catch (_) {
    return null;
  }
  return null;
}
