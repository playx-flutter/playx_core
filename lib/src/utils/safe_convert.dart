import 'dart:developer';

import 'package:flutter/foundation.dart';

// ----------------------- INT -----------------------

/// Safely converts [value] to an [int], or returns null if conversion fails.
int? toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

/// Converts [value] to [int] or returns [fallback] if conversion fails.
int toIntOr(dynamic value, {int fallback = 0}) =>
    toIntOrNull(value) ?? fallback;

/// Converts [value] to [int] or throws [FormatException] if conversion fails.
int toInt(dynamic value) =>
    toIntOrNull(value) ?? (throw FormatException('Invalid int value: $value'));

// ----------------------- NUM -----------------------

/// Safely converts [value] to [num], or returns null if conversion fails.
num? toNumOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return num.tryParse(value);
  return null;
}

/// Converts [value] to [num] or returns [fallback] if conversion fails.
num toNumOr(dynamic value, {num fallback = 0}) =>
    toNumOrNull(value) ?? fallback;

/// Converts [value] to [num] or throws [FormatException] if conversion fails.
num toNum(dynamic value) =>
    toNumOrNull(value) ?? (throw FormatException('Invalid num value: $value'));

// --------------------- DOUBLE ---------------------

/// Safely converts [value] to [double], or returns null if conversion fails.
double? toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is bool) return value ? 1.0 : 0.0;
  if (value is String) return double.tryParse(value);
  return null;
}

/// Converts [value] to [double] or returns [fallback] if conversion fails.
double toDoubleOr(dynamic value, {double fallback = 0.0}) =>
    toDoubleOrNull(value) ?? fallback;

/// Converts [value] to [double] or throws [FormatException] if conversion fails.
double toDouble(dynamic value) =>
    toDoubleOrNull(value) ??
    (throw FormatException('Invalid double value: $value'));

// ---------------------- BOOL ----------------------

/// Safely converts [value] to [bool], or returns null if conversion fails.
bool? toBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    return value == 1
        ? true
        : value == 0
            ? false
            : null;
  }
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    final numVal = num.tryParse(lower);
    return numVal == 1
        ? true
        : numVal == 0
            ? false
            : null;
  }
  return null;
}

/// Converts [value] to [bool] or returns [fallback] if conversion fails.
bool toBoolOr(dynamic value, {bool fallback = false}) =>
    toBoolOrNull(value) ?? fallback;

/// Converts [value] to [bool] or throws [FormatException] if conversion fails.
bool toBool(dynamic value) =>
    toBoolOrNull(value) ??
    (throw FormatException('Invalid bool value: $value'));

// --------------------- STRING ---------------------

/// Safely converts [value] to [String], or returns null if conversion fails.
String? toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return value.toString();
  return null;
}

/// Converts [value] to [String] or returns [fallback] if conversion fails.
String toStringOr(dynamic value, {String fallback = ''}) =>
    toStringOrNull(value) ?? fallback;

/// Converts [value] to [String] or throws [FormatException] if conversion fails.
String toString(dynamic value) =>
    toStringOrNull(value) ??
    (throw FormatException('Invalid String value: $value'));

// --------------------- DATETIME ---------------------

/// Safely converts [value] to [DateTime], or returns null if conversion fails.
DateTime? toDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

/// Converts [value] to [DateTime] or returns [fallback] if conversion fails.
DateTime toDateTimeOr(dynamic value, {required DateTime fallback}) =>
    toDateTimeOrNull(value) ?? fallback;

/// Converts [value] to [DateTime] or throws [FormatException] if conversion fails.
DateTime toDateTime(dynamic value) =>
    toDateTimeOrNull(value) ??
    (throw FormatException('Invalid DateTime value: $value'));

// --------------------- LOCAL DATETIME ---------------------

/// Safely converts [value] to [DateTime] in local time zone, or returns null if conversion fails.
///
/// [utcOffset] is the zone of values without zone information, e.g. a server
/// sending `2024-05-01 10:00:00` in Saudi time: `Duration(hours: 3)`. Values
/// with a zone (`Z`, `+03:00`) and epoch integers are absolute and unaffected.
/// Without it, values without zone information are read as local time.
DateTime? toLocalDateTimeOrNull(dynamic value, {Duration? utcOffset}) {
  final parsed = toDateTimeOrNull(value);
  if (parsed == null) return null;
  if (utcOffset != null && !parsed.isUtc && value is! int) {
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).subtract(utcOffset).toLocal();
  }
  return parsed.toLocal();
}

/// Converts [value] to [DateTime] in local time zone or returns [fallback] if conversion fails.
///
/// See [toLocalDateTimeOrNull] for [utcOffset].
DateTime toLocalDateTimeOr(dynamic value,
        {required DateTime fallback, Duration? utcOffset}) =>
    toLocalDateTimeOrNull(value, utcOffset: utcOffset) ?? fallback;

/// Converts [value] to [DateTime] in local time zone or throws [FormatException] if conversion fails.
///
/// See [toLocalDateTimeOrNull] for [utcOffset].
DateTime toLocalDateTime(dynamic value, {Duration? utcOffset}) =>
    toLocalDateTimeOrNull(value, utcOffset: utcOffset) ??
    (throw FormatException('Invalid DateTime value: $value'));

// --------------------- MAP ---------------------

/// Safely converts [value] to a Map, or returns null if conversion fails.
Map<T, S>? toMapOrNull<T, S>(dynamic value) {
  if (value == null) return null;
  if (value is Map<T, S>) return value;
  if (value is Map && value.isEmpty) return <T, S>{};
  return null;
}

/// Converts [value] to Map or returns [fallback] if conversion fails.
Map<T, S> toMapOr<T, S>(dynamic value, {Map<T, S> fallback = const {}}) =>
    toMapOrNull(value) ?? fallback;

/// Converts [value] to Map or throws [FormatException] if conversion fails.
Map<T, S> toMap<T, S>(dynamic value) =>
    toMapOrNull(value) ?? (throw FormatException('Invalid Map value: $value'));

// --------------------- LIST ---------------------

/// Safely converts [value] to List, or returns null if conversion fails.
List<T>? toListOrNull<T>(dynamic value, {T Function(dynamic json)? fromJson}) {
  if (value == null) return null;
  if (value is List<T>) return value;
  if (value is List && value.isEmpty) return <T>[];
  if (value is List && fromJson != null) {
    try {
      return value.map((e) => fromJson(e)).toList();
    } catch (e, s) {
      if (kDebugMode) {
        log('ERROR in converting list', error: e, stackTrace: s);
      }
    }
  } else if (value is List) {
    try {
      return List<T>.from(value);
    } catch (e, s) {
      if (kDebugMode) {
        log('ERROR in casting list', error: e, stackTrace: s);
      }
    }
  }
  return null;
}

/// Converts [value] to List or returns [fallback] if conversion fails.
List<T> toListOr<T>(dynamic value,
        {List<T> fallback = const [], T Function(dynamic json)? fromJson}) =>
    toListOrNull<T>(value, fromJson: fromJson) ?? fallback;

/// Converts [value] to List or throws [FormatException] if conversion fails.
List<T> toList<T>(dynamic value, {T Function(dynamic json)? fromJson}) =>
    toListOrNull<T>(value, fromJson: fromJson) ??
    (throw FormatException('Invalid List<$T> value: $value'));

// --------------------- ENUM ---------------------

/// Safely converts [value] to an enum of type [T], or returns null if conversion fails.
/// Requires the list of all enum [values] (e.g., MyEnum.values).
T? toEnumOrNull<T extends Enum>(dynamic value, List<T> values) {
  if (value == null) return null;
  if (value is T) return value;
  final stringValue = toStringOrNull(value)?.toLowerCase();
  if (stringValue == null) return null;
  try {
    return values.firstWhere(
      (e) => e.name.toLowerCase() == stringValue,
    );
  } catch (_) {
    return null;
  }
}

/// Converts [value] to an enum or returns [fallback] if conversion fails.
T toEnumOr<T extends Enum>(dynamic value, List<T> values,
        {required T fallback}) =>
    toEnumOrNull(value, values) ?? fallback;

/// Converts [value] to an enum or throws [FormatException] if conversion fails.
T toEnum<T extends Enum>(dynamic value, List<T> values) =>
    toEnumOrNull(value, values) ??
    (throw FormatException('Invalid enum value: $value'));

// --------------------- URI ---------------------

/// Safely converts [value] to [Uri], or returns null if conversion fails.
Uri? toUriOrNull(dynamic value) {
  if (value == null) return null;
  if (value is Uri) return value;
  final stringValue = toStringOrNull(value);
  if (stringValue == null) return null;
  return Uri.tryParse(stringValue);
}

/// Converts [value] to [Uri] or returns [fallback] if conversion fails.
Uri toUriOr(dynamic value, {required Uri fallback}) =>
    toUriOrNull(value) ?? fallback;

/// Converts [value] to [Uri] or throws [FormatException] if conversion fails.
Uri toUri(dynamic value) =>
    toUriOrNull(value) ?? (throw FormatException('Invalid Uri value: $value'));

// --------------------- GENERIC ---------------------

/// Safely converts [value] to type [T] using the [fromJson] function, or returns null if conversion fails.
T? toTOrNull<T>(dynamic value, {required T Function(dynamic json) fromJson}) {
  if (value == null) return null;
  if (value is T) return value;
  try {
    return fromJson(value);
  } catch (e, s) {
    if (kDebugMode) {
      log('ERROR in toTOrNull', error: e, stackTrace: s);
    }
    return null;
  }
}

/// Converts [value] to [T] using [fromJson] or returns [fallback] if conversion fails.
T toTOr<T>(
  dynamic value, {
  required T Function(dynamic json) fromJson,
  required T fallback,
}) =>
    toTOrNull(value, fromJson: fromJson) ?? fallback;

/// Converts [value] to [T] using [fromJson] or throws [FormatException] if conversion fails.
T toT<T>(dynamic value, {required T Function(dynamic json) fromJson}) =>
    toTOrNull(value, fromJson: fromJson) ??
    (throw FormatException('Invalid value for type $T: $value'));
