import 'dart:typed_data';

import '../env_log.dart';
import '../playx_env_exception.dart';
import '../playx_env_settings.dart';
import 'secure_env_codec.dart';

/// Decrypts the secure values of [PlayxEnvSettings.secureEnv] and the
/// `PLAYX_SECURE_DEFINES` define.
abstract final class SecureEnvLoader {
  /// `--dart-define=PLAYX_ENV_KEY=<key>`, used when the generated file has no key.
  static const _keyDefine = String.fromEnvironment('PLAYX_ENV_KEY');

  /// `--dart-define=PLAYX_SECURE_DEFINES=<ciphertext>`.
  static const _secureDefines = String.fromEnvironment('PLAYX_SECURE_DEFINES');

  /// Returns the decrypted secure values; define values override generated ones.
  ///
  /// Throws a [PlayxEnvException] if encrypted values are present but there is
  /// no key, the key is wrong, or the data was tampered with.
  static Future<Map<String, String>> load(
    PlayxEnvSettings settings, {
    String? environment,
    String? secureDefines,
    String? keyDefine,
  }) async {
    final secureEnv = settings.secureEnv;
    final data = secureEnv?.data ?? const <int>[];
    final defines = settings.useSecureDefines
        ? (secureDefines ?? _secureDefines).trim()
        : '';
    if (data.isEmpty && defines.isEmpty) return {};

    final generatedFor = secureEnv?.environment;
    if (data.isNotEmpty &&
        generatedFor != null &&
        generatedFor != environment) {
      envLogWarning(
        'Secure env was generated for "$generatedFor" but the environment is '
        '"${environment ?? 'none'}".',
      );
    }

    final key = _resolveKey(settings, keyDefine ?? _keyDefine);
    final values = <String, String>{};
    try {
      if (data.isNotEmpty) values.addAll(await decryptSecureEnv(data, key));
      if (defines.isNotEmpty) {
        values.addAll(await decryptSecureEnv(decodeSecureDefine(defines), key));
      }
    } catch (_) {
      // Never include the error: it could carry decrypted content.
      throw const PlayxEnvException(
        'Secure env values could not be decrypted: wrong key or corrupted '
        'data. Regenerate them with `dart run playx:secure_env` (or '
        '`dart run playx_core:secure_env`).',
      );
    }
    return values;
  }

  static Uint8List _resolveKey(PlayxEnvSettings settings, String keyDefine) {
    try {
      final embedded = settings.secureEnv?.key;
      if (embedded != null) return embedded.bytes;
      if (keyDefine.trim().isNotEmpty) return decodeSecureEnvKey(keyDefine);
    } on FormatException {
      throw const PlayxEnvException('The secure env key is malformed.');
    }
    throw const PlayxEnvException(
      'Secure env values are present but there is no key: generate them with '
      'an embedded key, or pass --dart-define=PLAYX_ENV_KEY=<key>.',
    );
  }
}
