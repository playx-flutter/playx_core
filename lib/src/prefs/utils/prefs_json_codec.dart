import 'dart:convert';

import '../../utils/safe_convert.dart';

/// Encodes values stored as JSON strings by the `Playx*Prefs` helpers.
///
/// Throws a [JsonUnsupportedObjectError] if [value] (or anything it contains)
/// can't be encoded, e.g. a custom class without a `toJson` conversion.
String encodePrefsJson(Object? value) => jsonEncode(value);

/// Decodes a JSON string stored by the `Playx*Prefs` helpers.
///
/// Returns `null` if [raw] is `null` or isn't valid JSON.
dynamic decodePrefsJson(String? raw) {
  if (raw == null) return null;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

/// Decodes a stored map. Returns `null` if missing or not a JSON object.
Map<String, dynamic>? decodePrefsMap(String? raw) =>
    toMapOrNull<String, dynamic>(decodePrefsJson(raw));

/// Encodes [value], converting each item with [toJson] if provided.
String encodePrefsList<T>(List<T> value, Object? Function(T item)? toJson) =>
    encodePrefsJson(toJson == null ? value : value.map(toJson).toList());

/// Decodes a stored list, converting each item with [fromJson] if provided.
///
/// Returns `null` if missing, not a JSON array, or if an item can't be
/// converted.
List<T>? decodePrefsList<T>(
  String? raw, {
  T Function(dynamic json)? fromJson,
}) => toListOrNull<T>(decodePrefsJson(raw), fromJson: fromJson);

/// Decodes a stored object with [fromJson].
///
/// Returns `null` if missing, not valid JSON, or if [fromJson] throws.
T? decodePrefsObject<T>(
  String? raw, {
  required T Function(dynamic json) fromJson,
}) {
  final json = decodePrefsJson(raw);
  if (json == null) return null;
  return toTOrNull<T>(json, fromJson: fromJson);
}
