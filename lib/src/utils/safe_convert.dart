/// Convert any dynamic value to int or null safely.
int? toIntOrNull(value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

/// Convert any dynamic value to double or null safely.
double? toDoubleOrNull(value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is bool) return value ? 1.0 : 0.0;
  if (value is String) return double.tryParse(value);
  return null;
}

/// Convert any dynamic value to bool or null safely.
bool? toBoolOrNull(value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 0 ? false : true;
  if (value is double) return value == 0 ? false : true;
  if (value is String) {
    if (value == "1" || value.toLowerCase() == "true") return true;
    if (value == "0" || value.toLowerCase() == "false") return false;
  }
  return null;
}

/// Convert any dynamic value to String or null safely.
String? toStringOrNull(value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is bool) return value ? "true" : "false";
  return null;
}

/// Convert any dynamic value to Map<String, dynamic> or null safely.
Map<String, dynamic>? toMapOrNull(value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  return null;
}

/// Convert any dynamic value to List or null safely.
List? toListOrNull(value) {
  if (value == null) return null;
  if (value is List) return value;
  return null;
}

/// Convert any dynamic value to List<T> or null safely.
List<T>? toListOrNullT<T>(value) {
  if (value == null) return null;
  if (value is List<T>) return value;
  return null;
}

/// Convert any dynamic value to List<T> or null safely.
/// As it converts each item to T using [fromJson] function.
List<T>? toListOrNullFromJson<T>(value, T Function(dynamic json) fromJson) {
  if (value == null) return null;
  if (value is List) return value.map((e) => fromJson(e)).toList();
  return null;
}

/// Convert any map value with [key] to int or null safely.
int? asIntOrNull(Map<String, dynamic>? json, String key) {
  if (json == null || !json.containsKey(key)) return null;
  return toIntOrNull(json[key]);
}

/// Convert any map value with [key] to double or null safely.
double? asDoubleOrNull(Map<String, dynamic>? json, String key) {
  if (json == null || !json.containsKey(key)) return null;
  return toDoubleOrNull(json[key]);
}

/// Convert any map value with [key] to bool or null safely.
bool? asBoolOrNull(
  Map<String, dynamic>? json,
  String key,
) {
  if (json == null || !json.containsKey(key)) return null;
  return toBoolOrNull(json[key]);
}

/// Convert any map value with [key] to String or null safely.
String? asStringOrNull(
  Map<String, dynamic>? json,
  String key,
) {
  if (json == null || !json.containsKey(key)) return null;
  return toStringOrNull(json[key]);
}

/// Convert any map value with [key] to Map<String, dynamic> or null safely.
Map<String, dynamic>? asMapOrNull(
  Map<String, dynamic>? json,
  String key,
) {
  if (json == null || !json.containsKey(key)) {
    return null;
  }
  return toMapOrNull(json[key]);
}

/// Convert any map value with [key] to List or null safely.
List? asListOrNull(Map<String, dynamic>? json, String key) {
  if (json == null || !json.containsKey(key)) return null;
  return toListOrNull(json[key]);
}

/// Convert any map value with [key] to List<int> or null safely.
List<int>? asListIntOrNull(
  Map<String, dynamic>? json,
  String key,
) {
  return asListOrNull(
    json,
    key,
  )?.map((e) => toIntOrNull(e)).whereType<int>().toList();
}

/// Convert any map value with [key] to List<T> or null safely.
List<String>? asListStringOrNull(
  Map<String, dynamic>? json,
  String key,
) {
  return asListOrNull(
    json,
    key,
  )?.map((e) => toStringOrNull(e)).whereType<String>().toList();
}

/// Convert any map value with [key] to List<T> or null safely.
List<T>? asListOrNullT<T>(Map<String, dynamic>? json, String key,
    {required T Function(dynamic json) fromJson}) {
  return asListOrNull(
    json,
    key,
  )?.map((e) => fromJson(e)).toList();
}

/// Convert any map value with [key] to List<T> or null safely.
List<T>? asListOrNullFromJson<T>(Map<String, dynamic>? json, String key,
    {required T Function(dynamic json) fromJson}) {
  return asListOrNull(
    json,
    key,
  )?.map((e) => fromJson(e)).toList();
}

/// Convert any map value with [key] to T or null safely.
T? asTOrNull<T>(
  Map<String, dynamic>? json,
  String key,
) {
  if (json == null || !json.containsKey(key)) {
    if (0 is T) return 0 as T;
    if (0.0 is T) return 0.0 as T;
    if ('' is T) return '' as T;
    if (false is T) return false as T;
    if ([] is T) return [] as T;
    if (<String, dynamic>{} is T) return <String, dynamic>{} as T;
    return '' as T;
  }
  dynamic value = json[key];
  if (value is T) return value;

  if (0 is T) {
    return toIntOrNull(value) as T;
  } else if (0.0 is T) {
    return toDoubleOrNull(value) as T;
  } else if ('' is T) {
    return toStringOrNull(
      value,
    ) as T;
  } else if (false is T) {
    return toBoolOrNull(
      value,
    ) as T;
  } else if ([] is T) {
    return toListOrNull(
      value,
    ) as T;
  } else if (<String, dynamic>{} is T) {
    return toMapOrNull(
      value,
    ) as T;
  }
  return null;
}

/// Convert any dynamic value to int or [fallback] safely.
int toInt(value, {int fallback = 0}) {
  return toIntOrNull(value) ?? fallback;
}

/// Convert any dynamic value to double or [fallback] safely.
double toDouble(value, {double fallback = 0.0}) {
  return toDoubleOrNull(value) ?? fallback;
}

/// Convert any dynamic value to bool or [fallback] safely.
bool toBool(value, {bool fallback = false}) {
  return toBoolOrNull(value) ?? fallback;
}

/// Convert any dynamic value to String or [fallback] safely.
String toString(value, {String fallback = ''}) {
  return toStringOrNull(value) ?? fallback;
}

/// Convert any dynamic value to Map<String, dynamic> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty map.
Map<String, dynamic> toMap(value,
    {Map<String, dynamic> fallback = const <String, dynamic>{}}) {
  return toMapOrNull(value) ?? fallback;
}

/// Convert any dynamic value to List or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List toList(value, {List fallback = const []}) {
  return toListOrNull(value) ?? fallback;
}

/// Convert any dynamic value to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> toListT<T>(value, {List<T> fallback = const []}) {
  return toListOrNullT(value) ?? fallback;
}

/// Convert any dynamic value to List<T> or [fallback] safely .
/// As it converts each item to T using [fromJson] function.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> toListFromJson<T>(value, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListOrNullFromJson(value, fromJson) ?? fallback;
}

/// Convert any map value with [key] to int or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
int asInt(Map<String, dynamic>? json, String key, {int fallback = 0}) {
  return toInt(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to double or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.0.
double asDouble(Map<String, dynamic>? json, String key,
    {double fallback = 0.0}) {
  return toDouble(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to bool or [fallback] safely.
/// If [fallback] is not provided, it defaults to false.
bool asBool(Map<String, dynamic>? json, String key, {bool fallback = false}) {
  return toBool(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to String or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty string.
String asString(Map<String, dynamic>? json, String key,
    {String fallback = ''}) {
  return toString(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to Map<String, dynamic> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty map.
Map<String, dynamic> asMap(Map<String, dynamic>? json, String key,
    {Map<String, dynamic> fallback = const <String, dynamic>{}}) {
  return toMap(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List asList(Map<String, dynamic>? json, String key,
    {List fallback = const []}) {
  return toList(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListT<T>(Map<String, dynamic>? json, String key,
    {List<T> fallback = const []}) {
  return toListT(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListFromJson<T>(
    Map<String, dynamic>? json, String key, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListFromJson(
      asTOrNull(
        json,
        key,
      ),
      fromJson,
      fallback: fallback);
}

/// Convert any map value with [key] to List<int> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<int> asListInt(Map<String, dynamic>? json, String key,
    {List<int> fallback = const []}) {
  return asListT(json, key, fallback: fallback);
}

/// Convert any map value with [key] to List<String> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<String> asListString(Map<String, dynamic>? json, String key,
    {List<String> fallback = const []}) {
  return asListT(json, key, fallback: fallback);
}

/// Convert any map value with [key] to T or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
T asT<T>(Map<String, dynamic>? json, String key, {required T fallback}) {
  return asTOrNull(
        json,
        key,
      ) ??
      fallback;
}
