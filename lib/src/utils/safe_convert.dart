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

T? toTOrNull<T>(value, {required T Function(dynamic json) fromJson}) {
  if (value == null) return null;
  if (value is T) return value;
  return fromJson(value);
}

/// Convert any dynamic value to int or [fallback] safely.
int toIntOr(value, {int fallback = 0}) {
  return toIntOrNull(value) ?? fallback;
}

/// Convert any dynamic value to double or [fallback] safely.
double toDoubleOr(value, {double fallback = 0.0}) {
  return toDoubleOrNull(value) ?? fallback;
}

/// Convert any dynamic value to bool or [fallback] safely.
bool toBoolOr(value, {bool fallback = false}) {
  return toBoolOrNull(value) ?? fallback;
}

/// Convert any dynamic value to String or [fallback] safely.
String toStringOr(value, {String fallback = ''}) {
  return toStringOrNull(value) ?? fallback;
}

/// Convert any dynamic value to Map<String, dynamic> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty map.
Map<String, dynamic> toMapOr(value,
    {Map<String, dynamic> fallback = const <String, dynamic>{}}) {
  return toMapOrNull(value) ?? fallback;
}

/// Convert any dynamic value to List or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List toListOr(value, {List fallback = const []}) {
  return toListOrNull(value) ?? fallback;
}

/// Convert any dynamic value to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> toListTOr<T>(value, {List<T> fallback = const []}) {
  return toListOrNullT(value) ?? fallback;
}

/// Convert any dynamic value to List<T> or [fallback] safely .
/// As it converts each item to T using [fromJson] function.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> toListFromJsonOr<T>(value, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListOrNullFromJson(value, fromJson) ?? fallback;
}

/// Convert any dynamic value to T or [fallback] safely.
T toTOr<T>(value, T Function(dynamic json) fromJson, {required T fallback}) {
  return toTOrNull(value, fromJson: fromJson) ?? fallback;
}

/// Convert any dynamic value to int.
/// If the conversion fails, it throws a [FormatException].
int toInt(value) {
  return toIntOrNull(value) ?? (throw FormatException('Invalid int value'));
}

/// Convert any dynamic value to double.
/// If the conversion fails, it throws a [FormatException].
double toDouble(value) {
  return toDoubleOrNull(value) ??
      (throw FormatException('Invalid double value :$value'));
}

/// Convert any dynamic value to bool.
/// If the conversion fails, it throws a [FormatException].
bool toBool(value) {
  return toBoolOrNull(value) ??
      (throw FormatException('Invalid bool value :$value'));
}

/// Convert any dynamic value to String.
/// If the conversion fails, it throws a [FormatException].
String toString(value) {
  return toStringOrNull(value) ??
      (throw FormatException('Invalid String value :$value'));
}

/// Convert any dynamic value to Map<String, dynamic>.
/// If the conversion fails, it throws a [FormatException].
Map<String, dynamic> toMap(value) {
  return toMapOrNull(value) ??
      (throw FormatException('Invalid Map value :$value'));
}

/// Convert any dynamic value to List.
/// If the conversion fails, it throws a [FormatException].
List toList(value) {
  return toListOrNull(value) ??
      (throw FormatException('Invalid List value :$value'));
}

/// Convert any dynamic value to List<T>.
/// If the conversion fails, it throws a [FormatException].
List<T> toListT<T>(value) {
  return toListOrNullT(value) ??
      (throw FormatException('Invalid List<$T> value :$value'));
}

/// Convert any dynamic value to List<T>.
/// If the conversion fails, it throws a [FormatException].
List<T> toListFromJson<T>(value, T Function(dynamic json) fromJson) {
  return toListOrNullFromJson(value, fromJson) ??
      (throw FormatException('Invalid List<$T> value :$value'));
}

/// Convert any dynamic value to T.
/// If the conversion fails, it throws a [FormatException].
T toT<T>(value, {required T Function(dynamic json) fromJson}) {
  return toTOrNull(value, fromJson: fromJson) ??
      (throw FormatException('Invalid $T value :$value'));
}

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

/// Convert any map value with [key] to Map<String, dynamic> or null safely.
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

/// Convert any map value with [key] to List<int> or null safely.
List<int>? asListIntOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }

  return asListOrNull(
    json,
    key,
  )?.map((e) => toIntOrNull(e)).whereType<int>().toList();
}

/// Convert any map value with [key] to List<T> or null safely.
List<String>? asListStringOrNull(
  dynamic json,
  String key,
) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }
  return asListOrNull(
    json,
    key,
  )?.map((e) => toStringOrNull(e)).whereType<String>().toList();
}

/// Convert any map value with [key] to List<T> or null safely.
List<T>? asListOrNullT<T>(dynamic json, String key,
    {required T Function(dynamic json)? fromJson}) {
  if (json == null || json is! Map<String, dynamic> || !json.containsKey(key)) {
    return null;
  }

  return asListOrNull(
    json,
    key,
  )?.map((e) => fromJson?.call(e)).whereType<T>().toList();
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
  dynamic value = json[key];

  if (fromJson != null) {
    return fromJson(value);
  }

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

/// Convert any map value with [key] to int or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
int asInt(
  Map<String, dynamic>? json,
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
  Map<String, dynamic>? json,
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
  Map<String, dynamic>? json,
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
  Map<String, dynamic>? json,
  String key,
) {
  return toString(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to Map<String, dynamic> or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
Map<String, dynamic> asMap(
  Map<String, dynamic>? json,
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
  Map<String, dynamic>? json,
  String key,
) {
  return toList(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<T> asListT<T>(
  Map<String, dynamic>? json,
  String key,
) {
  return toListT(
    asTOrNull(
      json,
      key,
    ),
  );
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<T> asListFromJson<T>(
    Map<String, dynamic>? json, String key, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListFromJson(
    asTOrNull(
      json,
      key,
    ),
    fromJson,
  );
}

/// Convert any map value with [key] to List<int> or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<int> asListInt(
  Map<String, dynamic>? json,
  String key,
) {
  return asListT(
    json,
    key,
  );
}

/// Convert any map value with [key] to List<String> or [fallback] safely.
/// Throws a [FormatException] if the conversion fails.
List<String> asListString(
  Map<String, dynamic>? json,
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
  Map<String, dynamic>? json,
  T Function(dynamic json)? fromJson,
  String key,
) {
  return asTOrNull(json, key, fromJson: fromJson) ??
      (throw FormatException('Invalid $T value :$key'));
}

/// Convert any map value with [key] to int or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
int asIntOr(Map<String, dynamic>? json, String key, {int fallback = 0}) {
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
double asDoubleOr(Map<String, dynamic>? json, String key,
    {double fallback = 0.0}) {
  return toDoubleOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to bool or [fallback] safely.
/// If [fallback] is not provided, it defaults to false.
bool asBoolOr(Map<String, dynamic>? json, String key, {bool fallback = false}) {
  return toBoolOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to String or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty string.
String asStringOr(Map<String, dynamic>? json, String key,
    {String fallback = ''}) {
  return toStringOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to Map<String, dynamic> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty map.
Map<String, dynamic> asMapOr(Map<String, dynamic>? json, String key,
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
List asListOr(Map<String, dynamic>? json, String key,
    {List fallback = const []}) {
  return toListOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListTOr<T>(Map<String, dynamic>? json, String key,
    {List<T> fallback = const []}) {
  return toListTOr(
      asTOrNull(
        json,
        key,
      ),
      fallback: fallback);
}

/// Convert any map value with [key] to List<T> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<T> asListFromJsonOr<T>(
    Map<String, dynamic>? json, String key, T Function(dynamic json) fromJson,
    {List<T> fallback = const []}) {
  return toListFromJsonOr(
      asTOrNull(
        json,
        key,
      ),
      fromJson,
      fallback: fallback);
}

/// Convert any map value with [key] to List<int> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<int> asListIntOr(Map<String, dynamic>? json, String key,
    {List<int> fallback = const []}) {
  return asListTOr(json, key, fallback: fallback);
}

/// Convert any map value with [key] to List<String> or [fallback] safely.
/// If [fallback] is not provided, it defaults to an empty list.
List<String> asListStringOr(Map<String, dynamic>? json, String key,
    {List<String> fallback = const []}) {
  return asListTOr(json, key, fallback: fallback);
}

/// Convert any map value with [key] to T or [fallback] safely.
/// If [fallback] is not provided, it defaults to 0.
T asTOr<T>(
    Map<String, dynamic>? json, String key, T Function(dynamic json)? fromJson,
    {required T fallback}) {
  return asTOrNull(
        json,
        key,
        fromJson: fromJson,
      ) ??
      fallback;
}
