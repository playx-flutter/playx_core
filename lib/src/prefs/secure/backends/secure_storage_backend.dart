import 'dart:convert';
import 'dart:math';

import '../settings/secure_storage_type.dart';

/// Key used by write/read health checks. Never returned by [readAll].
const secureHealthCheckKey = '_playx_secure_storage_health_check_';

/// A key/value string store used by `PlayxSecurePrefs`.
abstract class PlayxSecureStorageBackend {
  /// The type of this backend.
  PlayxSecureStorageType get type;

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  /// Removes every value written through this backend.
  ///
  /// Internal keys (such as an encryption key kept in this store) are preserved.
  Future<void> clear();

  /// Returns every value written through this backend, without internal keys.
  Future<Map<String, String>> readAll();
}

/// Writes, reads back and deletes a random value. Throws if anything fails.
Future<void> runSecureHealthCheck({
  required Future<void> Function(String key, String value) write,
  required Future<String?> Function(String key) read,
  required Future<void> Function(String key) delete,
}) async {
  // Random bytes rather than `nextInt(1 << 32)`, which is 0 on web.
  final random = Random.secure();
  final value = base64Encode(List.generate(16, (_) => random.nextInt(256)));
  try {
    await write(secureHealthCheckKey, value);
    final readValue = await read(secureHealthCheckKey);
    if (readValue != value) {
      throw StateError(
        'Secure storage health check failed: '
        'read value does not match written value.',
      );
    }
  } finally {
    await delete(secureHealthCheckKey);
  }
}
