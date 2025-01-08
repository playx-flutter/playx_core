import 'package:playx_core/src/utils/safe_convert.dart';

/// Convert any map value with [key] to int or null safely.
int? asIntOrNull(dynamic json, String key) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toIntOrNull(json[key]);
}

/// Convert any map value with [key] to double or null safely.
double? asDoubleOrNull(dynamic json, String key) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toDoubleOrNull(json[key]);
}

/// Convert any map value with [key] to bool or null safely.
bool? asBoolOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toBoolOrNull(json[key]);
}

/// Convert any map value with [key] to String or null safely.
String? asStringOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toStringOrNull(json[key]);
}

/// Convert any map value with [key] to [Map<String, dynamic>] or null safely.
Map<String, dynamic>? asMapOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toMapOrNull(json[key]);
}

/// Convert any map value with [key] to List or null safely.
List? asListOrNull(dynamic json, String key) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return toListOrNull(json[key]);
}

/// Convert any map value with [key] to [List<int>] or null safely.
/// Returns null if any of the values in the list is not an int.
List<int>? asListIntOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }

  final value = asListOrNull(
    json,
    key,
  )?.map((e) => toIntOrNull(e)).toList();
  if (value == null || value.any((element) => element == null)) {
    return null;
  }

  return value.whereType<int>().toList();
}

/// Convert any map value with [key] to [List<T>] or null safely.
/// Returns null if any of the values in the list couldn't be converted to String.
List<String>? asListStringOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  final value = asListOrNull(
    json,
    key,
  )?.map((e) => toStringOrNull(e)).toList();

  if (value == null || value.any((element) => element == null)) {
    return null;
  }
  return value.whereType<String>().toList();
}

/// Convert any map value with [key] to [List<T>] or null safely.
/// Returns null if any of the values in the list couldn't be converted to T.
List<T>? asListOrNullT<T>(dynamic json, String key,
    {required T Function(dynamic json)? fromJson}) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }

  final value = asListOrNull(
    json,
    key,
  )?.map((e) {
    try {
      return fromJson?.call(e);
    } catch (e) {
      return null;
    }
  }).toList();
  if (value == null || value.any((element) => element == null)) {
    return null;
  }
  return value.whereType<T>().toList();
}

/// Convert any map value with [key] to T or null safely.
T? asTOrNull<T>(
  dynamic json,
  String key, {
  T Function(dynamic json)? fromJson,
}) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  try {
    dynamic value = json[key];

    if (fromJson != null) {
      return fromJson(value);
    }

    if (value is T) return value;

    if (0.0 is T) {
      return toDoubleOrNull(value) as T?;
    } else if (0 is T) {
      return toIntOrNull(value) as T?;
    } else if ('' is T) {
      return toStringOrNull(
        value,
      ) as T?;
    } else if (false is T) {
      return toBoolOrNull(
        value,
      ) as T?;
    } else if ([] is T) {
      return toListOrNull(
        value,
      ) as T?;
    } else if (<String, dynamic>{} is T) {
      return toMapOrNull(
        value,
      ) as T?;
    }
  } catch (e) {
    return null;
  }
  return null;
}

/// Convert any map value with [key] to int or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
int asInt(
  dynamic json,
  String key,
) {
  return toInt(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to double or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
double asDouble(
  dynamic json,
  String key,
) {
  return toDouble(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to bool or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
bool asBool(
  dynamic json,
  String key,
) {
  return toBool(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to String or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
String asString(
  dynamic json,
  String key,
) {
  return toString(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to [Map<String, dynamic>] or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
Map<String, dynamic> asMap(
  dynamic json,
  String key,
) {
  return toMap(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to List or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List asList(
  dynamic json,
  String key,
) {
  return toList(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to [List<T>] or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<T> asListT<T>(
  dynamic json,
  String key,
) {
  return toListT(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to [List<T>] or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<T> asListFromJson<T>(
    dynamic json, String key, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListFromJson(
    asTOrNull(
      json,
      key,
    ),
    fromJson,
  );
}

/// Convert any map value with [key] to [List<int>] or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<int> asListInt(
  dynamic json,
  String key,
) {
  return asListT(
    json,
    key,
  );
}

/// Convert any map value with [key] to [List<String>] or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<String> asListString(
  dynamic json,
  String key,
) {
  return asListT(
    json,
    key,
  );
}

/// Convert any map value with [key] to T or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
T asT<T>(
  dynamic json,
  T Function(dynamic json)? fromJson,
  String key,
) {
  return asTOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid $T value :$key'));
}

/// Convert any map value with [key] to int or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
int asIntOr(dynamic json, String key, {int fallback = 0}) {
  return toIntOr(
    asTOrNull(
      json,
      key,
    ),
    fallback: fallback,
  );
}

/// Convert any map value with [key] to double or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.0.
double asDoubleOr(dynamic json, String key, {double fallback = 0.0}) {
  return toDoubleOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to bool or [fallback] safely.
/// If [fallback] is not provided, it defaults to false.
bool asBoolOr(dynamic json, String key, {bool fallback = false}) {
  return toBoolOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to String or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty string.
String asStringOr(dynamic json, String key, {String fallback = ''}) {
  return toStringOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to [Map<String, dynamic>] or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty map.
Map<String, dynamic> asMapOr(dynamic json, String key,
    {Map<String, dynamic> fallback = const <String, dynamic>{}}) {
  return toMapOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List asListOr(dynamic json, String key, {List fallback = const []}) {
  return toListOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to [List<T>] or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListTOr<T>(dynamic json, String key, {List<T> fallback = const []}) {
  return toListTOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to [List<T>] or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListFromJsonOr<T>(
    dynamic json, String key, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListFromJsonOr(
      asTOrNull(
        json,
        key,
      ),
      fromJson,
      fallback: fallback);
}

/// Convert any map value with [key] to [List<int>] or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<int> asListIntOr(dynamic json, String key,
    {List<int> fallback = const []}) {
  return asListTOr(json, key, fallback: fallback);
}

/// Convert any map value with [key] to [List<String>] or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<String> asListStringOr(dynamic json, String key,
    {List<String> fallback = const []}) {
  return asListTOr(json, key, fallback: fallback);
}

/// Convert any map value with [key] to T or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
T asTOr<T>(dynamic json, String key, T Function(dynamic json)? fromJson,
    {required T fallback}) {
  return asTOrNull(
        json,
        key,
        fromJson: fromJson,
      ) ??
      fallback;
}
