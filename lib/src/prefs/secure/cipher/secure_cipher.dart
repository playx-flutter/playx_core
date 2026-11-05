import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;

/// AES-256-GCM encryption bound to one key.
abstract class SecureCipher {
  /// Returns the ciphertext followed by the 16-byte authentication tag.
  Future<Uint8List> encrypt(Uint8List nonce, Uint8List plainText);

  /// Throws if the data was tampered with or encrypted with another key.
  Future<Uint8List> decrypt(Uint8List nonce, Uint8List cipherText);
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

  RawKeySecureCipher(this._key) {
    if (_key.length != secureKeyLength) {
      throw ArgumentError.value(_key.length, 'key', 'Must be 32 bytes');
    }
  }

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
