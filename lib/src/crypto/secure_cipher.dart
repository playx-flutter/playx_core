import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;

/// AES-256-GCM encryption and keyed hashing bound to one key.
abstract class SecureCipher {
  /// Returns the ciphertext followed by the 16-byte authentication tag.
  Future<Uint8List> encrypt(Uint8List nonce, Uint8List plainText);

  /// Throws if the data was tampered with or encrypted with another key.
  Future<Uint8List> decrypt(Uint8List nonce, Uint8List cipherText);

  /// HMAC-SHA256 of [data] with a key derived from (or generated alongside)
  /// the encryption key. Used to hide key names.
  Future<Uint8List> keyedHash(Uint8List data);
}

/// Length of an AES-256 key in bytes.
const secureKeyLength = 32;

/// Length of an AES-GCM nonce in bytes.
const secureNonceLength = 12;

final _random = Random.secure();

/// Returns [length] cryptographically secure random bytes.
Uint8List secureRandomBytes(int length) =>
    Uint8List.fromList(List.generate(length, (_) => _random.nextInt(256)));

/// [SecureCipher] using raw key bytes, implemented with `pointycastle`.
class RawKeySecureCipher implements SecureCipher {
  final Uint8List _key;

  /// Separate key for [keyedHash], so the encryption key is never used twice.
  late final Uint8List _hashKey = _hmac(
    _key,
    utf8.encode('playx_secure_prefs_key_names'),
  );

  RawKeySecureCipher(this._key) {
    if (_key.length != secureKeyLength) {
      throw ArgumentError.value(_key.length, 'key', 'Must be 32 bytes');
    }
  }

  static Uint8List _hmac(Uint8List key, List<int> data) => (pc.HMac(
    pc.SHA256Digest(),
    64,
  )..init(pc.KeyParameter(key))).process(Uint8List.fromList(data));

  @override
  Future<Uint8List> keyedHash(Uint8List data) async => _hmac(_hashKey, data);

  pc.GCMBlockCipher _cipher(bool forEncryption, Uint8List nonce) =>
      pc.GCMBlockCipher(pc.AESEngine())..init(
        forEncryption,
        pc.AEADParameters(pc.KeyParameter(_key), 128, nonce, Uint8List(0)),
      );

  @override
  Future<Uint8List> encrypt(Uint8List nonce, Uint8List plainText) async =>
      _cipher(true, nonce).process(plainText);

  @override
  Future<Uint8List> decrypt(Uint8List nonce, Uint8List cipherText) async =>
      _cipher(false, nonce).process(cipherText);
}
