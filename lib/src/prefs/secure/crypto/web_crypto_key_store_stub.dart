import '../../../crypto/secure_cipher.dart';

/// Reads the non-extractable WebCrypto key. Only supported on web.
Future<SecureCipher?> readWebCryptoKey() =>
    throw UnsupportedError('WebCrypto is only available on web.');

/// Creates and stores a non-extractable WebCrypto key. Only supported on web.
Future<SecureCipher> createWebCryptoKey() =>
    throw UnsupportedError('WebCrypto is only available on web.');
