import '../../../utils/safe_convert.dart';
import '../../../utils/safe_json_convert.dart';

/// Bookkeeping that lets [AutoSecureStorageBackend] move data written to a
/// fallback backend back to the preferred one without resurrecting stale,
/// removed or cleared values.
///
/// Stored as JSON in preferences. It only contains key names and backend
/// names, never values. When key names are hidden
/// ([PlayxSecurePrefsSettings.encryptKeys]), it is encrypted with a
/// per-device key kept in preferences, which obfuscates the names.
class SecureStorageJournal {
  /// Fallback backends that may hold values to move to the preferred backend,
  /// oldest first.
  final List<String> pendingStores;

  /// Backends that missed a `clear()` and must be cleared once reachable.
  final Set<String> pendingClear;

  /// Backend holding the latest value of each key touched while the journal
  /// is active, or `null` if the latest operation removed it.
  final Map<String, String?> lastWriter;

  SecureStorageJournal({
    List<String>? pendingStores,
    Set<String>? pendingClear,
    Map<String, String?>? lastWriter,
  }) : pendingStores = pendingStores ?? [],
       pendingClear = pendingClear ?? {},
       lastWriter = lastWriter ?? {};

  bool get isEmpty =>
      pendingStores.isEmpty && pendingClear.isEmpty && lastWriter.isEmpty;

  factory SecureStorageJournal.fromJson(dynamic json) => SecureStorageJournal(
    pendingStores: asListString(json, 'pendingStores'),
    pendingClear: asListString(json, 'pendingClear').toSet(),
    lastWriter: asMap<String, dynamic>(
      json,
      'lastWriter',
    ).map((key, value) => MapEntry(key, toStringOrNull(value))),
  );

  Map<String, dynamic> toJson() => {
    'pendingStores': pendingStores,
    'pendingClear': pendingClear.toList(),
    'lastWriter': lastWriter,
  };
}
