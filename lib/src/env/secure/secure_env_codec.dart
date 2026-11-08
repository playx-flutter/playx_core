import 'dart:convert';
import 'dart:typed_data';

import '../../crypto/secure_cipher.dart';

// Pure Dart (no Flutter imports): used by the app and by the `secure_env`
// command-line tool.

/// Current version of the encrypted format.
const secureEnvFormatVersion = 1;

const _definePrefix = 'v$secureEnvFormatVersion:';

/// Creates a new random 256-bit key.
Uint8List generateSecureEnvKey() => secureRandomBytes(secureKeyLength);

/// Decodes a base64 key, throwing a [FormatException] unless it is 32 bytes.
Uint8List decodeSecureEnvKey(String encoded) {
  final key = base64Decode(encoded.trim());
  if (key.length != secureKeyLength) {
    throw FormatException(
      'The key must be $secureKeyLength bytes, got ${key.length}.',
    );
  }
  return key;
}

/// Encrypts [values] as the nonce followed by AES-256-GCM ciphertext and tag.
Future<Uint8List> encryptSecureEnv(
  Map<String, String> values,
  Uint8List key,
) async {
  final nonce = secureRandomBytes(secureNonceLength);
  final cipherText = await RawKeySecureCipher(
    key,
  ).encrypt(nonce, Uint8List.fromList(utf8.encode(jsonEncode(values))));
  return Uint8List.fromList([...nonce, ...cipherText]);
}

/// Decrypts data produced by [encryptSecureEnv].
///
/// Throws if the data was tampered with, encrypted with another key, or
/// isn't a JSON object of strings.
Future<Map<String, String>> decryptSecureEnv(
  List<int> data,
  Uint8List key,
) async {
  if (data.length <= secureNonceLength) {
    throw const FormatException('Secure env data is too short.');
  }
  final bytes = Uint8List.fromList(data);
  final plainText = await RawKeySecureCipher(key).decrypt(
    bytes.sublist(0, secureNonceLength),
    bytes.sublist(secureNonceLength),
  );
  final json = jsonDecode(utf8.decode(plainText));
  if (json is! Map) throw const FormatException('Expected a JSON object.');
  return {
    for (final MapEntry(:key, :value) in json.entries)
      key.toString(): value.toString(),
  };
}

/// Encodes encrypted data as the value of the `PLAYX_SECURE_DEFINES` define.
String encodeSecureDefine(List<int> data) =>
    '$_definePrefix${base64Encode(data)}';

/// Decodes the value of the `PLAYX_SECURE_DEFINES` define.
Uint8List decodeSecureDefine(String value) {
  final trimmed = value.trim();
  if (!trimmed.startsWith(_definePrefix)) {
    throw const FormatException('Unsupported PLAYX_SECURE_DEFINES format.');
  }
  return base64Decode(trimmed.substring(_definePrefix.length));
}
