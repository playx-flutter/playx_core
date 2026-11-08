import 'dart:convert';

import 'safe_convert.dart';

/// Encodes [value] as a JSON string.
///
/// Throws a [JsonUnsupportedObjectError] if [value] (or anything it contains)
/// can't be encoded, e.g. a custom class without a `toJson` conversion.
String encodeJsonValue(Object? value) => jsonEncode(value);

/// Decodes a JSON string.
///
/// Returns `null` if [raw] is `null` or isn't valid JSON.
dynamic decodeJsonOrNull(String? raw) {
  if (raw == null) return null;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

/// Decodes a JSON object. Returns `null` if missing or not a JSON object.
Map<String, dynamic>? decodeJsonMapOrNull(String? raw) =>
    toMapOrNull<String, dynamic>(decodeJsonOrNull(raw));

/// Encodes [value], converting each item with [toJson] if provided.
String encodeJsonList<T>(List<T> value, Object? Function(T item)? toJson) =>
    encodeJsonValue(toJson == null ? value : value.map(toJson).toList());

/// Decodes a JSON array, converting each item with [fromJson] if provided.
///
/// Returns `null` if missing, not a JSON array, or if an item can't be
/// converted.
List<T>? decodeJsonListOrNull<T>(
  String? raw, {
  T Function(dynamic json)? fromJson,
}) => toListOrNull<T>(decodeJsonOrNull(raw), fromJson: fromJson);

/// Decodes JSON and converts it with [fromJson].
///
/// Returns `null` if missing, not valid JSON, or if [fromJson] throws.
T? decodeJsonObjectOrNull<T>(
  String? raw, {
  required T Function(dynamic json) fromJson,
}) {
  final json = decodeJsonOrNull(raw);
  if (json == null) return null;
  return toTOrNull<T>(json, fromJson: fromJson);
}
