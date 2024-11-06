// Convert any dynamic value to int or null safely.
import 'dart:developer';

import 'package:flutter/foundation.dart';

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
  if (value is int) {
    return value == 0
        ? false
        : value == 1
            ? true
            : null;
  }
  if (value is double) {
    return value == 0
        ? false
        : value == 1
            ? true
            : null;
  }
  if (value is String) {
    if (value.toLowerCase() == "true") return true;
    if (value.toLowerCase() == "false") return false;
    if (toDoubleOrNull(value) == 1) return true;
    if (toDoubleOrNull(value) == 0) return false;
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
  if (value is Map && value.isEmpty) return <String, dynamic>{};
  if (value is Map<String, dynamic>) return value;
  return null;
}

/// Convert any dynamic value to Map<String, dynamic> or null safely.
Map<T, S>? toMapOrNullAny<T, S>(value) {
  if (value == null) return null;
  if (value is Map<T, S>) return value;
  if (value is Map && value.isEmpty) return <T, S>{};
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
  if (value is List && value.isEmpty) return [];
  if (value is List<T>) return value;
  return null;
}

/// Convert any dynamic value to List<T> or null safely.
/// As it converts each item to T using [fromJson] function.
List<T>? toListOrNullFromJson<T>(value, T Function(dynamic json) fromJson) {
  if (value == null) return null;
  if (value is List) {
    if (value.isEmpty) return [];
    try {
      return value.map((e) => fromJson(e)).toList();
    } catch (e, s) {
      if (kDebugMode) {
        log('ERROR IN toListOrNullFromJson', error: e, stackTrace: s);
      }
      return null;
    }
  }
  return null;
}

T? toTOrNull<T>(value, {required T Function(dynamic json) fromJson}) {
  if (value == null) return null;
  if (value is T) return value;
  try {
    return fromJson(value);
  } catch (e, s) {
    if (kDebugMode) {
      log('ERROR IN toTOrNull', error: e, stackTrace: s);
    }
    return null;
  }
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
T toTOr<T>(value,
    {required T Function(dynamic json) fromJson, required T fallback}) {
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
