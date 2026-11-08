import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/crypto/secure_cipher.dart';

void main() {
  final key = Uint8List.fromList(List.generate(32, (i) => i));
  final nonce = Uint8List.fromList(List.generate(12, (i) => i + 1));
  final plain = Uint8List.fromList(utf8.encode('secret value'));

  test('secureRandomBytes returns the requested number of random bytes', () {
    final a = secureRandomBytes(16);
    final b = secureRandomBytes(16);
    expect(a, hasLength(16));
    expect(a, isNot(b));
    expect(secureRandomBytes(0), isEmpty);
  });

  test('rejects keys that are not 32 bytes', () {
    expect(() => RawKeySecureCipher(Uint8List(16)), throwsArgumentError);
    expect(() => RawKeySecureCipher(Uint8List(33)), throwsArgumentError);
    expect(RawKeySecureCipher(Uint8List(32)), isA<SecureCipher>());
  });

  group('encryption', () {
    test('round-trips and appends a 16 byte authentication tag', () async {
      final cipher = RawKeySecureCipher(key);
      final encrypted = await cipher.encrypt(nonce, plain);
      expect(encrypted, hasLength(plain.length + 16));
      expect(encrypted.sublist(0, plain.length), isNot(plain));
      expect(await cipher.decrypt(nonce, encrypted), plain);
    });

    test('is deterministic for the same key, nonce and data', () async {
      final cipher = RawKeySecureCipher(key);
      expect(
        await cipher.encrypt(nonce, plain),
        await cipher.encrypt(nonce, plain),
      );
    });

    test('a different nonce changes the ciphertext', () async {
      final cipher = RawKeySecureCipher(key);
      final other = Uint8List.fromList(List.filled(12, 9));
      expect(
        await cipher.encrypt(nonce, plain),
        isNot(await cipher.encrypt(other, plain)),
      );
    });

    test(
      'decrypting fails for tampering, wrong keys and wrong nonces',
      () async {
        final cipher = RawKeySecureCipher(key);
        final encrypted = await cipher.encrypt(nonce, plain);

        final tampered = Uint8List.fromList(encrypted)..[0] ^= 1;
        await expectLater(cipher.decrypt(nonce, tampered), throwsA(anything));

        final otherKey = Uint8List.fromList(List.filled(32, 7));
        await expectLater(
          RawKeySecureCipher(otherKey).decrypt(nonce, encrypted),
          throwsA(anything),
        );

        final otherNonce = Uint8List.fromList(List.filled(12, 9));
        await expectLater(
          cipher.decrypt(otherNonce, encrypted),
          throwsA(anything),
        );
      },
    );
  });

  group('keyedHash', () {
    final data = Uint8List.fromList(utf8.encode('access_token'));

    test('is a deterministic 32 byte HMAC', () async {
      final cipher = RawKeySecureCipher(key);
      final hash = await cipher.keyedHash(data);
      expect(hash, hasLength(32));
      expect(await cipher.keyedHash(data), hash);
    });

    test('depends on the key and on the data', () async {
      final hash = await RawKeySecureCipher(key).keyedHash(data);
      final otherKey = Uint8List.fromList(List.filled(32, 7));
      expect(await RawKeySecureCipher(otherKey).keyedHash(data), isNot(hash));
      expect(
        await RawKeySecureCipher(
          key,
        ).keyedHash(Uint8List.fromList(utf8.encode('refresh_token'))),
        isNot(hash),
      );
    });

    test('is not the encryption key or an encryption of the data', () async {
      final cipher = RawKeySecureCipher(key);
      final hash = await cipher.keyedHash(data);
      expect(hash, isNot(key));
      expect(await cipher.keyedHash(Uint8List(0)), hasLength(32));
    });
  });
}
