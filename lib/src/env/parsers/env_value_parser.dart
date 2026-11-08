import '../../utils/json_value_codec.dart';
import '../../utils/safe_convert.dart';

final _durationPattern = RegExp(r'^(\d+(?:\.\d+)?)\s*(ms|s|m|h|d)?$');

const _microsecondsPerUnit = {
  'ms': Duration.microsecondsPerMillisecond,
  's': Duration.microsecondsPerSecond,
  'm': Duration.microsecondsPerMinute,
  'h': Duration.microsecondsPerHour,
  'd': Duration.microsecondsPerDay,
};

/// Parses a number with an optional unit (`ms`, `s`, `m`, `h`, `d`), e.g.
/// `250ms`, `30s` or `1.5h`. A number without a unit is in milliseconds.
///
/// Returns `null` if [value] is `null` or doesn't match.
Duration? parseEnvDuration(String? value) {
  if (value == null) return null;
  final match = _durationPattern.firstMatch(value.trim().toLowerCase());
  if (match == null) return null;
  final amount = double.parse(match.group(1)!);
  final unit = _microsecondsPerUnit[match.group(2) ?? 'ms']!;
  return Duration(microseconds: (amount * unit).round());
}

/// Parses a JSON array (`[1, 2, 3]`) or [separator]-separated values
/// (`a, b, c`; items are trimmed and empty ones skipped).
///
/// Items are converted with [fromJson] if provided. Otherwise `String`, `int`,
/// `double`, `num`, `bool` and `Uri` items are parsed.
///
/// Returns `null` if [value] is `null`, isn't a valid list, or an item can't
/// be converted.
List<T>? parseEnvList<T>(
  String? value, {
  T Function(dynamic json)? fromJson,
  String separator = ',',
}) {
  if (value == null) return null;
  final trimmed = value.trim();
  final List<dynamic>? items = trimmed.startsWith('[')
      ? toListOrNull<dynamic>(decodeJsonOrNull(trimmed))
      : [
          for (final item in trimmed.split(separator))
            if (item.trim().isNotEmpty) item.trim(),
        ];
  if (items == null) return null;

  final result = <T>[];
  for (final item in items) {
    final T? converted;
    try {
      converted = fromJson != null ? fromJson(item) : _convertItem<T>(item);
    } catch (_) {
      return null;
    }
    if (converted == null) return null;
    result.add(converted);
  }
  return result;
}

T? _convertItem<T>(dynamic item) {
  final Object? converted = switch (T) {
    const (String) => toStringOrNull(item),
    const (int) => toIntOrNull(item),
    const (double) => toDoubleOrNull(item),
    const (num) => toNumOrNull(item),
    const (bool) => toBoolOrNull(item),
    const (Uri) => toUriOrNull(item),
    _ => item,
  };
  return converted is T ? converted : null;
}
